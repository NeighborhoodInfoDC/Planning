/**************************************************************************
 Program:  Download_data.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/08/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Download data needed for State of DC Neighborhoods
 report.  June 2008.
 
 NOVEMBER 2008 UPDATE.

 Modifications:
  06/20/08 PAT Added 2007 sales data. Foreclosures 2000-2007.
  07/29/08 PAT Added OP population estimates.
  07/30/08 PAT Added infant mortality rates.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Ncdb )
%DCData_lib( TANF )
%DCData_lib( HMDA )
%DCData_lib( Police )
%DCData_lib( RealProp )
%DCData_lib( Vital )
%DCData_lib( ROD )

%let out_ds = DC_nbrhds_2008_11;

%syslput out_ds=&out_ds;

** Start submitting commands to remote server **;

rsubmit;

** Vacant/abandoned properties from Parcel_base file **;

data Vacant_prop;

  merge
    Realprop.Parcel_base 
      (keep=ssl usecode in_last_ownerpt landarea ui_proptype
       where=(in_last_ownerpt)
       in=in1)
    Realprop.Parcel_geo
      (keep=ssl cluster_tr2000 ward2002 city);
  by ssl;
  
  if in1;
  
  if usecode = '097' then vacant_prop_2008 = 10000;
  else vacant_prop_2008 = 0;
  
  if ui_proptype = '50' then vacant_land_2008 = 100;
  else vacant_land_2008 = 0;
  
  label
    vacant_prop_2008 = '2008'
    vacant_land_2008 = '2008';
  
run;

proc summary data=Vacant_prop nway;
  var vacant_prop_2008;
  var vacant_land_2008 / weight=landarea;
  class ward2002;
  output out=Vacant_prop_wd02 (drop=_type_ _freq_) mean= ;
run;

proc summary data=Vacant_prop nway;
  var vacant_prop_2008;
  var vacant_land_2008 / weight=landarea;
  class cluster_tr2000;
  output out=Vacant_prop_cltr00 (drop=_type_ _freq_) mean= ;
run;

proc summary data=Vacant_prop nway;
  var vacant_prop_2008;
  var vacant_land_2008 / weight=landarea;
  class city;
  output out=Vacant_prop_city (drop=_type_ _freq_) mean= ;
run;

** Upload schools data from Elizabeth, create city summary **;

proc upload status=no
  data=Planning.op_stu_file_ward (where=(ward2002~='M'))
  out=Op_stu_file_wd02;
run;

proc upload status=no
  data=Planning.op_stu_file_cluster (where=(cluster_tr2000~='M'))
  out=Op_stu_file_cltr00;
run;

proc summary data=Op_stu_file_cltr00 (where=(cluster_tr2000~='M'));
  var math_proficient_advanced reading_proficient_advanced
   grade_: frp_:;
  output out=Op_stu_file_city mean(math_proficient_advanced reading_proficient_advanced)=
   sum(grade_: frp_:)=;
run;

data Op_stu_file_city;

  set Op_stu_file_city;
  
  city = '1';
  
run;

*options mprint symbolgen mlogic;


/** Macro Data_sets - Start Definition **/

%macro Data_sets( suffix );

  Ncdb.Ncdb_sum_&suffix
  Tanf.Tanf_sum_&suffix
  Tanf.Fs_sum_&suffix
  Hmda.Hmda_sum_&suffix
  Police.Crimes_sum_&suffix
  Realprop.Sales_sum_&suffix
/*  Realprop.Num_units_&suffix */
  Vital.Births_sum_&suffix
  Vital.Deaths_sum_&suffix
  Rod.Foreclosures_sum_&suffix
  Op_stu_file_&suffix
  Planning.Tree_canopy_&suffix
  Planning.Casey_trees_&suffix
  Planning.Green_roofs_&suffix
  Planning.PopEst_2005_&suffix
  Planning.Park_access_&suffix
  Planning.Library_access_&suffix
  Planning.Rec_access_&suffix
  Planning.CoStar_sum_&suffix
  Vacant_prop_&suffix

%mend Data_sets;

/** End Macro Definition **/

/** Macro Dollar_adjust_all - Start Definition **/

%macro Dollar_adjust_all( var=, prefix=r_, cons_yr=, years=, offset=0 );

  %let j = 1;
  %let y = %scan( &years, &j );
  
  %do %while( &y ~= );
  
    %dollar_convert( &var._&y, &prefix.&var._&y, %eval( &y + (&offset) ), &cons_yr )
  
    %let j = %eval( &j + 1 );
    %let y = %scan( &years, &j );
  
  %end;

%mend Dollar_adjust_all;

/** End Macro Definition **/

/** Macro Suppress_data - Start Definition **/
/** Set VAR to MISSVAL where TESTVAR < MIN **/

%macro Suppress_data( from=, to=, testvar=, min=, var=, missval=.i );

  %** Sequential years **;

  %do y = &from %to &to;
  
    if &testvar._&y < ( &min ) then &var._&y = &missval;

  %end;

%mend Suppress_data;

/** End Macro Definition **/


%** Variables to retain in input data sets **;

%let keep_vars =
  /** Planning **/
  PopEst_: Green_roofs_: Park_dist_: Library_dist_: Rec_dist_:
  RentableBuildingArea_: DirectAvailableSpace_:
  /** NCDB **/
  TotPop_: PopUnder18Years_: PopUnder5Years_: Pop65andOverYears_:
  PopWithRace_: PopWhiteNonHispBridge_: PopBlackNonHispBridge_: PopHisp_:
  AggHshldIncome_: ChildrenPovertyDefined_: PersonsPovertyDefined_: PopBelow200PctPoverty_:
  PopPoorPersons_: PopPoorChildren_: PopPoorElderly_: ElderlyPovertyDefined_:
  NumHshlds_: NumHshldSingleParentWKids_: NumHshldMarriedCoupleWKids_: NumHshldOtherFamily_:
  NumHshldNonFamily_:
  NumHsgUnits_: NumOccupiedHsgUnits_: NumOwnerOccupiedHsgUnits_:
  PopWorkers_: PopInCivLaborForce_: PopUnemployed_: PopNotInArmedForces_:
  Pop25andOverWoutHS_: Pop25andOverYears_:
  MedianHshldIncome_:
  /** TANF **/
  tanf_client_2000-tanf_client_2007 fs_client_2000-fs_client_2007
  /** HMDA **/
  nummrtgorighomepurch1_4m_1997-nummrtgorighomepurch1_4m_2006
  numconvmrtgorighomepurch_1997-numconvmrtgorighomepurch_2006 
  numsubprimeconvorighomepur_1997-numsubprimeconvorighomepur_2006 
  mrtgorigpurchowner1_4m_1997-mrtgorigpurchowner1_4m_2006
  /*numconvmrtgorigrefin_1997-numconvmrtgorigrefin_2006 numsubprimeconvorigrefin_2006*/
  NumMrtgOrig_vli_1997-NumMrtgOrig_vli_2006 
  NumMrtgOrig_li_1997-NumMrtgOrig_li_2006 
  NumMrtgOrig_mi_1997-NumMrtgOrig_mi_2006 
  NumMrtgOrig_hinc_1997-NumMrtgOrig_hinc_2006 
  NumMrtgOrig_Inc_1997-NumMrtgOrig_Inc_2006
  nummrtgorigwhite_1997-nummrtgorigwhite_2006
  nummrtgorigblack_1997-nummrtgorigblack_2006
  nummrtgorighisp_1997-nummrtgorighisp_2006
  nummrtgorigwithrace_1997-nummrtgorigwithrace_2006
  /** Police **/
  crime_rate_pop_: crimes_pt1_violent_: crimes_pt1_property_: 
  /** RealProp **/
  sales_tot_2000-sales_tot_2007 sales_sf_2000-sales_sf_2007 sales_condo_2000-sales_condo_2007
  mprice_sf_2000-mprice_sf_2007 mprice_condo_2000-mprice_condo_2007 
  /** Vital **/
  births_total_1998-births_total_2005
  births_low_wt_1998-births_low_wt_2005 births_w_weight_1998-births_w_weight_2005
  births_teen_1998-births_teen_2005 births_w_age_1998-births_w_age_2005
  births_prenat_adeq_1999-births_prenat_adeq_2005 births_w_prenat_1999-births_w_prenat_2005
  deaths_heart_1998-deaths_heart_2005 deaths_cancer_1998-deaths_cancer_2005
  deaths_violent_1999-deaths_violent_2005 
  births_total_3yr_2000-births_total_3yr_2005 
  deaths_infant_3yr_2000-deaths_infant_3yr_2005
  /** ROD **/
  forecl_1kpcl_sf_condo_: 
  /*forecl_ntc_sale_sf_ssl_: forecl_ntc_sale_condo_ssl_: parcel_sf_: parcel_condo_:*/
  /** Schools **/
  reading_proficient_advanced math_proficient_advanced grade_: frp_:
  /** Casey trees **/
  canopy_area canopy_pct 
  totals dead No_tree_trunk_stump excellent good fair poor
  /** Vacant property **/
  vacant_prop_: vacant_land_:
  ;

** Combine files by geo level **;

data city_level;

  merge 
    %Data_sets( city )
  ;
  by city;
  
  keep city &keep_vars;

run;

data ward_level;

  merge 
    %Data_sets( wd02 )
  ;
  by ward2002;
  
  keep ward2002 &keep_vars;

run;

data cluster_level;

  merge 
    %Data_sets( cltr00 )
  ;
  by cluster_tr2000;
  
  if cluster_tr2000 = '99' then delete;
  
  length ward2002 $ 1;
  
  ward2002 = put( cluster_tr2000, $cl0wd2f. );
  
  keep cluster_tr2000 ward2002 &keep_vars;

run;

data all_levels;

  set 
    city_level (in=inCity)
    ward_level (in=inWard)
    cluster_level (in=inCluster);
    
  length geo $ 4;
  
  if inCity then geo = '1000';
  else if inWard then geo = '1' || ward2002 || '00';
  else if inCluster then geo = '1' || ward2002 || cluster_tr2000;
  
  **** Create rates ****;
  
  %let ncdb_years = 1980 1990 2000;
  
  ** Demographics **;
  
  %Pct_calc( var=Pers_hhld, num=TotPop, den=NumHshlds, years=&ncdb_years, year_only_lbl=Y, mult=1 )
  
  AnnPopChg_1980_1990 = 100 * %annchg( TotPop_1980, TotPop_1990, 1990 - 1980 );
  AnnPopChg_1990_2000 = 100 * %annchg( TotPop_1990, TotPop_2000, 2000 - 1990 );
  AnnPopChg_2000_2005 = 100 * %annchg( TotPop_2000, PopEst_2005, 2005 - 2000 );
  
  label 
    TotPop_1980 = '1980'
    TotPop_1990 = '1990'
    TotPop_2000 = '2000'
    PopEst_2000 = '2000'
    PopEst_2005 = '2005'
    AnnPopChg_1980_1990 = '1980-1990'
    AnnPopChg_1990_2000 = '1990-2000'
    AnnPopChg_2000_2005 = '2000-2005'
    NumHshlds_1980 = '1980'
    NumHshlds_1990 = '1990'
    NumHshlds_2000 = '2000'
  ;
  
  ** Economy - jobs and income **;
  
  %Pct_calc( var=PctUnemployed, num=PopUnemployed, den=PopInCivLaborForce, years=&ncdb_years, year_only_lbl=Y )
  %Pct_calc( var=PctPoorPersons, num=PopPoorPersons, den=PersonsPovertyDefined, years=&ncdb_years, year_only_lbl=Y )
  
  %Pct_calc( var=pct_tanf_client, num=tanf_client, cons_den=TotPop_2000, from=2000, to=2007, year_only_lbl=Y )
  %Pct_calc( var=pct_fs_client, num=fs_client, cons_den=TotPop_2000, from=2000, to=2007, year_only_lbl=Y )
  
  %Dollar_adjust_all( var=MedianHshldIncome, cons_yr=1999, years=1990 2000, offset=-1 )
  
  if DirectAvailableSpace_2008 = . then DirectAvailableSpace_2008 = 0;
  if RentableBuildingArea_2008 = . then RentableBuildingArea_2008 = 0;
  
  %Pct_calc( var=Pct_comm_vacant, num=DirectAvailableSpace, den=RentableBuildingArea, years=2008, year_only_lbl=Y )
  
  ** Economy - housing **;
  
  %Dollar_adjust_all( var=mprice_sf, cons_yr=2007, years=2000 2001 2002 2003 2004 2005 2006 2007 )
  %Dollar_adjust_all( var=mprice_condo, cons_yr=2007, years=2000 2001 2002 2003 2004 2005 2006 2007 )
  
  %Suppress_data( from=2000, to=2007, testvar=sales_sf, min=10, var=r_mprice_sf )
  %Suppress_data( from=2000, to=2007, testvar=sales_condo, min=10, var=r_mprice_condo )
  
  %Pct_calc( var=Pctsubprimeconvorighomepur, num=numsubprimeconvorighomepur, den=numconvmrtgorighomepurch, from=1997, to=2006, year_only_lbl=Y )
  %Pct_calc( var=Pctmrtgorigpurchowner1_4m, num=mrtgorigpurchowner1_4m, den=nummrtgorighomepurch1_4m, from=1997, to=2006, year_only_lbl=Y )
  
  %Pct_calc( var=PctMrtgOrig_hinc, num=NumMrtgOrig_hinc, den=NumMrtgOrig_inc, from=1997, to=2006, year_only_lbl=Y )
  %Pct_calc( var=PctMrtgOrig_mi, num=NumMrtgOrig_mi, den=NumMrtgOrig_inc, from=1997, to=2006, year_only_lbl=Y )
  
  NumMrtgOrig_low_1997 = sum( NumMrtgOrig_li_1997, NumMrtgOrig_vli_1997 );
  NumMrtgOrig_low_1998 = sum( NumMrtgOrig_li_1998, NumMrtgOrig_vli_1998 );
  NumMrtgOrig_low_1999 = sum( NumMrtgOrig_li_1999, NumMrtgOrig_vli_1999 );
  NumMrtgOrig_low_2000 = sum( NumMrtgOrig_li_2000, NumMrtgOrig_vli_2000 );
  NumMrtgOrig_low_2001 = sum( NumMrtgOrig_li_2001, NumMrtgOrig_vli_2001 );
  NumMrtgOrig_low_2002 = sum( NumMrtgOrig_li_2002, NumMrtgOrig_vli_2002 );
  NumMrtgOrig_low_2003 = sum( NumMrtgOrig_li_2003, NumMrtgOrig_vli_2003 );
  NumMrtgOrig_low_2004 = sum( NumMrtgOrig_li_2004, NumMrtgOrig_vli_2004 );
  NumMrtgOrig_low_2005 = sum( NumMrtgOrig_li_2005, NumMrtgOrig_vli_2005 );
  NumMrtgOrig_low_2006 = sum( NumMrtgOrig_li_2006, NumMrtgOrig_vli_2006 );
  
  %Pct_calc( var=PctMrtgOrig_low, num=NumMrtgOrig_low, den=NumMrtgOrig_inc, from=1997, to=2006, year_only_lbl=Y )
    
  %Pct_calc( var=Pctmrtgorigblack, num=nummrtgorigblack, den=nummrtgorigwithrace, from=1997, to=2006, year_only_lbl=Y )
  %Pct_calc( var=Pctmrtgorigwhite, num=nummrtgorigwhite, den=nummrtgorigwithrace, from=1997, to=2006, year_only_lbl=Y )
  %Pct_calc( var=Pctmrtgorighisp, num=nummrtgorighisp, den=nummrtgorigwithrace, from=1997, to=2006, year_only_lbl=Y )
  
  ** Foreclosures **;
  
  label
    forecl_1kpcl_sf_condo_1997 = '1997'
    forecl_1kpcl_sf_condo_1998 = '1998'
    forecl_1kpcl_sf_condo_1999 = '1999'
    forecl_1kpcl_sf_condo_2000 = '2000'
    forecl_1kpcl_sf_condo_2001 = '2001'
    forecl_1kpcl_sf_condo_2002 = '2002'
    forecl_1kpcl_sf_condo_2003 = '2003'
    forecl_1kpcl_sf_condo_2004 = '2004'
    forecl_1kpcl_sf_condo_2005 = '2005'
    forecl_1kpcl_sf_condo_2006 = '2006'
    forecl_1kpcl_sf_condo_2007 = '2007'
  ;
  
  ** Health **;
  
  %Pct_calc( var=Pct_births_low_wt, num=births_low_wt, den=births_w_weight, from=1998, to=2005, year_only_lbl=Y )
  %Pct_calc( var=Pct_births_teen, num=births_teen, den=births_w_age, from=1998, to=2005, year_only_lbl=Y )
  %Pct_calc( var=Pct_births_prenat_adeq, num=births_prenat_adeq, den=births_w_prenat, from=1999, to=2005, year_only_lbl=Y )

  %Pct_calc( var=Birth_rate, num=births_total, cons_den=TotPop_2000, from=1998, to=2005, year_only_lbl=Y, mult=1000 )

  %Pct_calc( var=Infant_mort_rate, num=deaths_infant_3yr, den=births_total_3yr, from=2000, to=2005, year_only_lbl=Y, mult=1000 )
    
  %Pct_calc( var=Rate_deaths_heart, num=deaths_heart, cons_den=TotPop_2000, from=1998, to=2005, year_only_lbl=Y, mult=1000 )
  %Pct_calc( var=Rate_deaths_cancer, num=deaths_cancer, cons_den=TotPop_2000, from=1998, to=2005, year_only_lbl=Y, mult=1000 )
  %Pct_calc( var=Rate_deaths_violent, num=deaths_violent, cons_den=TotPop_2000, from=1999, to=2005, year_only_lbl=Y, mult=1000 )
  
  ** Family, Youth, and Seniors **;
  
  %Pct_calc( var=PctMarriedCoupleWKids, num=NumHshldMarriedCoupleWKids, den=NumHshlds, years=&ncdb_years, year_only_lbl=Y )
  %Pct_calc( var=PctSingleParentWKids, num=NumHshldSingleParentWKids, den=NumHshlds, years=&ncdb_years, year_only_lbl=Y )
  %Pct_calc( var=PctOtherFamily, num=NumHshldOtherFamily, den=NumHshlds, years=&ncdb_years, year_only_lbl=Y )
  %Pct_calc( var=PctNonFamily, num=NumHshldNonFamily, den=NumHshlds, years=&ncdb_years, year_only_lbl=Y )
  
  %Pct_calc( var=PctUnder18Years, num=PopUnder18Years, den=TotPop, years=&ncdb_years, year_only_lbl=Y )
  %Pct_calc( var=Pct65andOverYears, num=Pop65andOverYears, den=TotPop, years=&ncdb_years, year_only_lbl=Y )

  %Pct_calc( var=PctPoorChildren, num=PopPoorChildren, den=ChildrenPovertyDefined, years=1990 2000, year_only_lbl=Y )
  %Pct_calc( var=PctPoorElderly, num=PopPoorElderly, den=ElderlyPovertyDefined, years=1990 2000, year_only_lbl=Y )
  
  label 
    Library_dist_2008 = '2008'
    Rec_dist_2008 = '2008';
  
  ** Safety and security **;

  %Pct_calc( var=violent_crime_rate, num=crimes_pt1_violent, den=crime_rate_pop, from=2000, to=2007, mult=1000, year_only_lbl=Y )
  %Pct_calc( var=property_crime_rate, num=crimes_pt1_property, den=crime_rate_pop, from=2000, to=2007, mult=1000, year_only_lbl=Y )

  ** Schools **;
  
  enroll_pk_5_2006 = sum( grade_PK, grade_1, grade_2, grade_3, grade_4, grade_5 );
  enroll_6_8_2006 = sum( grade_6, grade_7, grade_8 );
  enroll_9_12_2006 = sum( grade_9, grade_10, grade_11, grade_12 );
  
  pct_frp_pk_5_2006 = 100 * sum( frp_PK, frp_1, frp_2, frp_3, frp_4, frp_5 ) / enroll_pk_5_2006;
  pct_frp_6_8_2006 = 100 * sum( frp_6, frp_7, frp_8 ) / enroll_6_8_2006;
  pct_frp_9_12_2006 = 100 * sum( frp_9, frp_10, frp_11, frp_12 ) / enroll_9_12_2006;
  
  label
    enroll_pk_5_2006 = "PK\~-\~5"
    enroll_6_8_2006 = "6\~-\~8"
    enroll_9_12_2006 = "9\~-\~12"
    pct_frp_pk_5_2006 = "PK\~-\~5"
    pct_frp_6_8_2006 = "6\~-\~8"
    pct_frp_9_12_2006 = "9\~-\~12"
    reading_proficient_advanced = "2006/07"
    math_proficient_advanced = "2006/07"
  ;
  
  rename 
    math_proficient_advanced=pct_math_prfadv_2006
    reading_proficient_advanced=pct_read_prfadv_2006;
  
  ** Environment **;
  
  pct_no_tree = 100 * sum( dead, No_tree_trunk_stump ) / totals;
  pct_tree_good_excel = 100 * sum( good, excellent ) / sum( good, excellent, fair, poor );
  
  label 
    pct_no_tree = "2006"
    pct_tree_good_excel = "2006"
    canopy_pct = "2006";
    
  rename
    pct_no_tree = pct_no_tree_2006
    pct_tree_good_excel = pct_tree_good_excel_2006
    canopy_pct = canopy_pct_2006;
    
  if Green_roofs_2007 = . then Green_roofs_2007 = 0;
    
  label
    Green_roofs_2007 = "2007";
    
run;

proc sort data=all_levels;
  by geo;

proc download status=no
  data=all_levels 
  out=Planning.&out_ds;

run;

endrsubmit;

** End submitting commands to remote server **;

%File_info( data=Planning.&out_ds, printobs=0, freqvars=geo )

run;

signoff;

