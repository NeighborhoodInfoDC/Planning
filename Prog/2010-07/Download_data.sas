/**************************************************************************
 Program:  Download_data.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/08/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Download data needed for State of DC Neighborhoods
 report.  May 2008.
 
 NOVEMBER 2008 UPDATE.
 MAY 2010 UPDATE.
	
 Modifications:
  06/20/08 PAT Added 2007 sales data. Foreclosures 2000-2007.
  07/29/08 PAT Added OP population estimates.
  07/30/08 PAT Added infant mortality rates.
  05/20/10 CJN Update for 2010 SODC Report.	

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

%let out_ds = DC_nbrhds_2010_7;

%syslput out_ds=&out_ds;

** Start submitting commands to remote server **;

rsubmit;


%macro Data_sets( suffix );

  Ncdb.Ncdb_sum_&suffix
  Tanf.Tanf_sum_&suffix
  Tanf.Fs_sum_&suffix
  Hmda.Hmda_sum_&suffix
  Police.Crimes_sum_&suffix
  Realprop.Sales_sum_&suffix
  Realprop.Num_units_&suffix 
  Vital.Births_sum_&suffix
  Vital.Deaths_sum_&suffix
  Rod.Foreclosures_sum_&suffix

  Planning.Tree_canopy_&suffix
  Planning.Casey_trees_&suffix

  Planning.labor_&suffix
  Planning.DMV_&suffix
  Planning.metrobus_&suffix
  Planning.metrorail_&suffix
  Planning.grocery_&suffix
  Planning.fastfood_&suffix
  Planning.pipeline_&suffix
  Planning.Grnst_grnrfs_2_&suffix
  Planning.green_&suffix
  Planning.trees_&suffix

/*
  Planning.Grnst_grn_other_&suffix
  Planning.Grnst_aqua_&suffix
  Planning.Grnst_altenergy_&suffix
  Planning.grnst_frmsmkts_&suffix
*/
  Planning.PopEst_08_&suffix
  Planning.Park_access_&suffix
  Planning.Librarypt_access_&suffix
  Planning.Recpt_access_&suffix
  Planning.metro_access_&suffix 
  Planning.bus_access_&suffix 
  Planning.metroboardings_&suffix
  Planning.grocery_access_&suffix 
  Planning.fastfood_access_&suffix
  Planning.vacant_&suffix

  PLANNING.TESTSCORES_&suffix
  PLANNING.ENROLMENT_&suffix

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
  PopEst_: Park_dist_yd_: Librarypt_dist_yd_: Recpt_dist_yd_: Numv_:
  grocery_dist_yd_: fastfood_dist_yd_: store_: fastfood_:
  bus_stop_: metro_: metro_dist_yd_: bus_dist_yd_: metro_boardings_: 
  units  affunits
  pct_unemp_: labor_force_: vacant_prop_: grnrfs_2_:
  building_:
  trees_: tree_hlth_:
  /* grn_other_: frmsmkts_:  aqua_: altenergy_: mrktunits_: */

  /*Schools*/
   DCPS_pct_prof_math_0607                    
   DCPS_pct_prof_math_0708                    
   DCPS_pct_prof_math_0809                    
   DCPS_pct_prof_reading_0607                 
   DCPS_pct_prof_reading_0708                 
   DCPS_pct_prof_reading_0809                 
   
   PCSB_pct_prof_math_0607                    
   PCSB_pct_prof_math_0708                    
   PCSB_pct_prof_math_0809                    
   PCSB_pct_prof_reading_0607                 
   PCSB_pct_prof_reading_0708                 
   PCSB_pct_prof_reading_0809                 
                                 
   city_pct_prof_math_0607                    
   city_pct_prof_math_0708                    
   city_pct_prof_math_0809                    
   city_pct_prof_reading_0607                 
   city_pct_prof_reading_0708                 
   city_pct_prof_reading_0809

   DCPS_total_rep_0102                               
   DCPS_total_rep_0203                               
   DCPS_total_rep_0304                               
   DCPS_total_rep_0405                               
   DCPS_total_rep_0506                               
   DCPS_total_rep_0607                               
   DCPS_total_rep_0708                               
   DCPS_total_rep_0809                               
   DCPS_total_rep_0910                               
   
   PCSB_total_rep_0102                               
   PCSB_total_rep_0203                               
   PCSB_total_rep_0304                               
   PCSB_total_rep_0405                               
   PCSB_total_rep_0506                               
   PCSB_total_rep_0607                               
   PCSB_total_rep_0708                               
   PCSB_total_rep_0809                               
   PCSB_total_rep_0910    
   
   allsch_rep_0102                                   
   allsch_rep_0203                                   
   allsch_rep_0304                                   
   allsch_rep_0405                                   
   allsch_rep_0506                                   
   allsch_rep_0607                                   
   allsch_rep_0708                                   
   allsch_rep_0809                                   
   allsch_rep_0910  

  /** NCDB **/
  TotPop_: PopUnder18Years_: PopUnder5Years_: Pop65andOverYears_: 
  PopWithRace_: PopWhiteNonHispBridge_: PopBlackNonHispBridge_: PopHisp_:
  AggHshldIncome_: ChildrenPovertyDefined_: PersonsPovertyDefined_: PopBelow200PctPoverty_:
  PopPoorPersons_: PopPoorChildren_: PopPoorElderly_: ElderlyPovertyDefined_:
  NumHshlds_: NumHshldSingleParentWKids_: NumHshldMarriedCoupleWKids_: NumHshldOtherFamily_:
  NumHshldNonFamily_: Popgroupquarters_:
  NumHsgUnits_: NumOccupiedHsgUnits_: NumOwnerOccupiedHsgUnits_:
  PopWorkers_: PopInCivLaborForce_: PopUnemployed_: PopNotInArmedForces_:
  Pop25andOverWoutHS_: Pop25andOverYears_:
  MedianHshldIncome_:

  /** TANF **/
  tanf_client_2000-tanf_client_2009 fs_client_2000-fs_client_2009

  /** HMDA **/
  nummrtgorighomepurch1_4m_1997-nummrtgorighomepurch1_4m_2008
  numconvmrtgorighomepurch_1997-numconvmrtgorighomepurch_2008 
  mrtgorigpurchowner1_4m_1997-mrtgorigpurchowner1_4m_2008
  numhighcostconvorigpurch_2004-numhighcostconvorigpurch_2008
  denhighcostconvorigpurch_2004-denhighcostconvorigpurch_2008 
  NumMrtgOrig_vli_1997-NumMrtgOrig_vli_2008 
  NumMrtgOrig_li_1997-NumMrtgOrig_li_2008
  NumMrtgOrig_mi_1997-NumMrtgOrig_mi_2008 
  NumMrtgOrig_hinc_1997-NumMrtgOrig_hinc_2008 
  NumMrtgOrig_Inc_1997-NumMrtgOrig_Inc_2008
  nummrtgorigwhite_1997-nummrtgorigwhite_2008
  nummrtgorigblack_1997-nummrtgorigblack_2008
  nummrtgorighisp_1997-nummrtgorighisp_2008
  nummrtgorigwithrace_1997-nummrtgorigwithrace_2008

  /** Police **/
  crime_rate_pop_: crimes_pt1_violent_: 
  crimes_pt1_homicide_:
  crimes_pt1_robbery_: 
  crimes_pt1_sexual_:
  crimes_pt1_assault_: 

  crimes_pt1_property_: 
  crimes_pt1_arson_:
  crimes_pt1_auto_:
  crimes_pt1_burglary_:
  crimes_pt1_theft_:

  /** RealProp **/
  sales_tot_2000-sales_tot_2009 sales_sf_2000-sales_sf_2009 sales_condo_2000-sales_condo_2009
  mprice_sf_2000-mprice_sf_2009 mprice_condo_2000-mprice_condo_2009 
  units_sf_condo_2000-units_sf_condo_2009 

  /** Vital **/
  births_total_1998-births_total_2007
  births_low_wt_1998-births_low_wt_2007 births_w_weight_1998-births_w_weight_2007
  births_teen_1998-births_teen_2007 births_w_age_1998-births_w_age_2007
  births_prenat_adeq_1999-births_prenat_adeq_2007 births_w_prenat_1999-births_w_prenat_2007
  births_total_3yr_2000-births_total_3yr_2007 
  deaths_infant_3yr_2000-deaths_infant_3yr_2007
  deaths_heart_1998-deaths_heart_2007 
  deaths_cancer_1998-deaths_cancer_2007
  deaths_violent_1999-deaths_violent_2007 
   
  /** ROD **/
  forecl_1kpcl_sf_condo_1995-forecl_1kpcl_sf_condo_2009 
  
 
  /** Casey trees **/

  canopy_area canopy_pct 
  totals dead No_tree_trunk_stump excellent good fair poor


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
  
  AnnPopChg_1980_1990 = 100 * ((TotPop_1990-TotPop_1980)/TotPop_1980) ;
  AnnPopChg_1990_2000 = 100 * ((TotPop_2000-TotPop_1990)/TotPop_1990) ;
  AnnPopChg_2000_2008 = 100 * ((PopEst_2008-TotPop_2000)/TotPop_2000) ;

  label 
    TotPop_1980 = '1980'
    TotPop_1990 = '1990'
    TotPop_2000 = '2000'
    PopEst_2008 = '2008'
    AnnPopChg_1980_1990 = '1980-1990'
    AnnPopChg_1990_2000 = '1990-2000'
    AnnPopChg_2000_2008 = '2000-2008'
    NumHshlds_1980 = '1980'
    NumHshlds_1990 = '1990'
    NumHshlds_2000 = '2000'
  ;
  
  ** Economy - jobs and income **;
  
  %Pct_calc( var=PctUnemployed, num=PopUnemployed, den=PopInCivLaborForce, years=&ncdb_years, year_only_lbl=Y )
  %Pct_calc( var=PctPoorPersons, num=PopPoorPersons, den=PersonsPovertyDefined, years=&ncdb_years, year_only_lbl=Y )
  
  %Pct_calc( var=pct_tanf_client, num=tanf_client, cons_den=TotPop_2000, from=2000, to=2009, year_only_lbl=Y )
  %Pct_calc( var=pct_fs_client, num=fs_client, cons_den=TotPop_2000, from=2000, to=2009, year_only_lbl=Y )
  
  %Dollar_adjust_all( var=MedianHshldIncome, cons_yr=1999, years=1990 2000, offset=-1 )
  
   
  ** Economy - housing **;
  
  %Dollar_adjust_all( var=mprice_sf, cons_yr=2009, years=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 )
  %Dollar_adjust_all( var=mprice_condo, cons_yr=2009, years=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009)
  
  %Suppress_data( from=2000, to=2009, testvar=sales_sf, min=10, var=r_mprice_sf )
  %Suppress_data( from=2000, to=2009, testvar=sales_condo, min=10, var=r_mprice_condo )

  %Pct_calc( var=Pct_sales, num=sales_tot, den=units_sf_condo, from=2000, to=2009, year_only_lbl=Y )
 
  %Pct_calc( var=Pcthighcostconvorigpurch, num=numhighcostconvorigpurch, den=denhighcostconvorigpurch, from=2004, to=2008, year_only_lbl=Y )
  %Pct_calc( var=Pctmrtgorigpurchowner1_4m, num=mrtgorigpurchowner1_4m, den=nummrtgorighomepurch1_4m, from=1997, to=2008, year_only_lbl=Y )
  
  %Pct_calc( var=PctMrtgOrig_hinc, num=NumMrtgOrig_hinc, den=NumMrtgOrig_inc, from=1997, to=2008, year_only_lbl=Y )
  %Pct_calc( var=PctMrtgOrig_mi, num=NumMrtgOrig_mi, den=NumMrtgOrig_inc, from=1997, to=2008, year_only_lbl=Y )
  
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
  NumMrtgOrig_low_2007 = sum( NumMrtgOrig_li_2007, NumMrtgOrig_vli_2007 );
  NumMrtgOrig_low_2008 = sum( NumMrtgOrig_li_2008, NumMrtgOrig_vli_2008 );

  %Pct_calc( var=PctMrtgOrig_low, num=NumMrtgOrig_low, den=NumMrtgOrig_inc, from=1997, to=2008, year_only_lbl=Y )
  %Pct_calc( var=PctMrtgOrig_vli, num=NumMrtgOrig_vli, den=NumMrtgOrig_inc, from=1997, to=2008, year_only_lbl=Y )  
  %Pct_calc( var=PctMrtgOrig_li, num=NumMrtgOrig_li, den=NumMrtgOrig_inc, from=1997, to=2008, year_only_lbl=Y )

  %Pct_calc( var=Pctmrtgorigblack, num=nummrtgorigblack, den=nummrtgorigwithrace, from=1997, to=2008, year_only_lbl=Y )
  %Pct_calc( var=Pctmrtgorigwhite, num=nummrtgorigwhite, den=nummrtgorigwithrace, from=1997, to=2008, year_only_lbl=Y )
  %Pct_calc( var=Pctmrtgorighisp, num=nummrtgorighisp, den=nummrtgorigwithrace, from=1997, to=2008, year_only_lbl=Y )
  

  ** Health **;
 
  %Pct_calc( var=Pct_births_low_wt, num=births_low_wt, den=births_w_weight, from=1998, to=2007, year_only_lbl=Y )
  %Pct_calc( var=Pct_births_teen, num=births_teen, den=births_w_age, from=1998, to=2007, year_only_lbl=Y )
  %Pct_calc( var=Pct_births_prenat_adeq, num=births_prenat_adeq, den=births_w_prenat, from=1999, to=2007, year_only_lbl=Y )

  %Pct_calc( var=Birth_rate, num=births_total, cons_den=TotPop_2000, from=1998, to=2007, year_only_lbl=Y, mult=1000 )

  %Pct_calc( var=Infant_mort_rate, num=deaths_infant_3yr, den=births_total_3yr, from=2000, to=2007, year_only_lbl=Y, mult=1000 )
 
  %Pct_calc( var=Rate_deaths_heart, num=deaths_heart, cons_den=TotPop_2000, from=1998, to=2007, year_only_lbl=Y, mult=1000 )
  %Pct_calc( var=Rate_deaths_cancer, num=deaths_cancer, cons_den=TotPop_2000, from=1998, to=2007, year_only_lbl=Y, mult=1000 )
  %Pct_calc( var=Rate_deaths_violent, num=deaths_violent, cons_den=TotPop_2000, from=1999, to=2007, year_only_lbl=Y, mult=1000 )
  
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
    Library_dist_2010 = '2010'
    Rec_dist_2010 = '2010';
  
  ** Safety and security **;

%Pct_calc( var=violent_crime_rate, num=crimes_pt1_violent, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=homicide_crime_rate, num= crimes_pt1_homicide, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=sexual_crime_rate, num=crimes_pt1_sexual, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=assault_crime_rate, num=crimes_pt1_assault, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=robbery_crime_rate, num=crimes_pt1_robbery, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )

%Pct_calc( var=property_crime_rate, num=crimes_pt1_property, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=arson_crime_rate, num=crimes_pt1_arson, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=auto_crime_rate, num=crimes_pt1_auto, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=burglary_crime_rate, num=crimes_pt1_burglary, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )
%Pct_calc( var=theft_crime_rate, num=crimes_pt1_theft, den=crime_rate_pop, from=2000, to=2009, mult=1000, year_only_lbl=Y )

  **Calculate Percent Proficient**;
DCPS_pct_prof_math_0607=DCPS_pct_prof_math_0607*100;         
DCPS_pct_prof_math_0708=DCPS_pct_prof_math_0708*100;         
DCPS_pct_prof_math_0809=DCPS_pct_prof_math_0809*100;        
DCPS_pct_prof_reading_0607=DCPS_pct_prof_reading_0607*100;   
DCPS_pct_prof_reading_0708=DCPS_pct_prof_reading_0708*100;   
DCPS_pct_prof_reading_0809=DCPS_pct_prof_reading_0809*100;   

PCSB_pct_prof_math_0607=PCSB_pct_prof_math_0607*100;         
PCSB_pct_prof_math_0708=PCSB_pct_prof_math_0708*100;         
PCSB_pct_prof_math_0809=PCSB_pct_prof_math_0809*100;         
PCSB_pct_prof_reading_0607=PCSB_pct_prof_reading_0607*100;   
PCSB_pct_prof_reading_0708=PCSB_pct_prof_reading_0708*100;   
PCSB_pct_prof_reading_0809=PCSB_pct_prof_reading_0809*100;   
                                                            
city_pct_prof_math_0607=city_pct_prof_math_0607*100;        
city_pct_prof_math_0708=city_pct_prof_math_0708*100;         
city_pct_prof_math_0809=city_pct_prof_math_0809*100;         
city_pct_prof_reading_0607=city_pct_prof_reading_0607*100;   
city_pct_prof_reading_0708=city_pct_prof_reading_0708*100;   
city_pct_prof_reading_0809=city_pct_prof_reading_0809*100;

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
    canopy_pct = canopy_pct_2006
    units = units_2009
	affunits = affunits_2009;

  label	

    bus_stop_2006 = "2006"
    metro_2007 = "2007"
	metro_boardings_2009= "2009"
    Numv_2010 = "2010"
    Store_2009 = "2009" 

    grnrfs_2_2009 = "2009"

	/*
    natsite_2009 = "2009"
    grn_other_2009 = "2009" 
    frmsmkts_2009 = "2009" 
   */
 

	pct_unemp_2009="2009"
	labor_force_2009="2009"  
    vacant_prop_2009="2009"
;

hh_size_1980=(TotPop_1980-Popgroupquarters_1980)/Numhshlds_1980;
hh_size_1990=(TotPop_1990-Popgroupquarters_1990)/Numhshlds_1990;
hh_size_2000=(TotPop_2000-Popgroupquarters_2000)/Numhshlds_2000;

label
hh_size_1980="1980"
hh_size_1990="1990"
hh_size_2000="2000"
;

/*Census to LAUS conversion*/
pct_unemp_census_1980=PctUnemployed_1980*1.05882352941176;
pct_unemp_census_1990=PctUnemployed_1990*0.820601851851852;
pct_unemp_census_2000=PctUnemployed_2000*0.527006172839506;

/*Yards to feet conversion*/
Park_dist_ft_2007=Park_dist_yd_2007*3;
Recpt_dist_ft_2007=Recpt_dist_yd_2007*3;
Librarypt_dist_ft_2009=Librarypt_dist_yd_2009*3;
grocery_dist_ft_2009=grocery_dist_yd_2009*3;
fastfood_dist_ft_2009=fastfood_dist_yd_2009*3;
bus_dist_ft_2006=bus_dist_yd_2006*3;
metro_dist_ft_2007=metro_dist_yd_2007*3;

pct_vreg18_2010=numv_2010/(((TotPop_2000-PopUnder18Years_2000)/TotPop_2000)*PopEst_2008)*100 ; 
pct_tree_2010= (tree_hlth_2010/trees_2010)*100;
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

proc contents data=planning.DC_nbrhds_2010_7;
run;
