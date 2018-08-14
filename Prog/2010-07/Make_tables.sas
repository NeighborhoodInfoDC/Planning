/**************************************************************************
 Program:  Make_tables.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/08/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Make tables of indicators for State of DC's
Neighborhoods report.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";


** Define libraries **;
%DCData_lib( Planning )

data fmt;

  set 
    General.Ward2002 (in=inWard)
    General.Cluster2000 (in=inCluster);
    
  if cluster2000 = '99' then delete;

  length geo $ 4;
  
  if _n_ = 1 then do;
    geo = '1000';
    lbl = 'Washington, DC';
    output;
  end;
  
  if inWard then do;
    geo = '1' || ward2002 || '00';
    if ward2002 ~= 5 then 
      lbl = ' ' || put( ward2002, $ward02a. );
    else 
      lbl = ' ' || put( ward2002, $ward02a. );
  end;
  else if inCluster then do;
    geo = '1' || ward2002 || cluster2000;
    lbl = ' ' || put( cluster2000, $clus00a. );
  end;  
  
  output;
  
  keep geo lbl ward2002 cluster2000;
  
  format cluster2000 $clus00a.;

run;

%Data_to_format(
  FmtLib=work,
  FmtName=$geo,
  Desc=,
  Data=fmt,
  Value=geo,
  Label=lbl,
  OtherLabel=,
  DefaultLen=.,
  MaxLen=.,
  MinLen=.,
  Print=Y,
  Contents=N
  )

/** Macro List_vars - Start Definition **/

%macro List_vars( var=, label=N, years= );

  %let i = 1;
  %let y = %scan( &years, &i );
  
  %do %while ( &y ~= );
  
    &var._&y 
    %if %upcase( &label ) = Y %then %do;
      ="&y" 
    %end;
  
    %let i = %eval( &i + 1 );
    %let y = %scan( &years, &i );
    
  %end;

%mend List_vars;

/** End Macro Definition **/


/** Macro Table - Start Definition **/

%macro Table( Sec1=, var1=, years1=, fmt1=comma10.1, 
              Sec2=, var2=, years2=, fmt2=comma10.1,
              Sec3=, var3=, years3=, fmt3=comma10.1,
              Sec4=, var4=, years4=, fmt4=comma10.1,
              Sec5=, var5=, years5=, fmt5=comma10.1,
              Sec6=, var6=, years6=, fmt6=comma10.1,
              title=, autolabel=Y );
              
  %let autolabel = %upcase( &autolabel );
  
  %fdate()
  
  proc report data=Planning.dc_nbrhds_2010_7 nowd split='^';
    column geo 
      ( &Sec1 %List_vars( var=&var1, years=&years1 ) )
      %if &Sec2 ~= %then %do;
        ( &Sec2 %List_vars( var=&var2, years=&years2 ) )
      %end;      
      %if &Sec3 ~= %then %do;
        ( &Sec3 %List_vars( var=&var3, years=&years3 ) )
      %end;      
      %if &Sec4 ~= %then %do;
        ( &Sec4 %List_vars( var=&var4, years=&years4 ) )
      %end;      
      %if &Sec5 ~= %then %do;
        ( &Sec5 %List_vars( var=&var5, years=&years5 ) )
      %end;      
      %if &Sec6 ~= %then %do;
        ( &Sec6 %List_vars( var=&var6, years=&years6 ) )
      %end;      
    ;
    define geo / format=$geo. ' ';
    format 
      %if &Sec1 ~= %then %do;
        %List_vars( var=&var1, years=&years1 ) &fmt1
      %end;
      %if &Sec2 ~= %then %do;
        %List_vars( var=&var2, years=&years2 ) &fmt2
      %end;
      %if &Sec3 ~= %then %do;
        %List_vars( var=&var3, years=&years3 ) &fmt3
      %end;
      %if &Sec4 ~= %then %do;
        %List_vars( var=&var4, years=&years4 ) &fmt4
      %end;
      %if &Sec5 ~= %then %do;
        %List_vars( var=&var5, years=&years5 ) &fmt5
      %end;
      %if &Sec6 ~= %then %do;
        %List_vars( var=&var6, years=&years6 ) &fmt6
      %end;
    ;
    %if &autolabel = Y %then %do;
      label 
        %List_vars( var=&var1, years=&years1, label=y )
        %List_vars( var=&var2, years=&years2, label=y )
        %List_vars( var=&var3, years=&years3, label=y )
        %List_vars( var=&var4, years=&years4, label=y )
        %List_vars( var=&var5, years=&years5, label=y )
        %List_vars( var=&var6, years=&years6, label=y )
      ; 
    %end;
    title1 height=8pt "State of Washington, D.C.'s Neighborhoods";
    title2 &title;
    footnote1 height=8pt "Data compiled by NeighborhoodInfo DC (updated &fdate).";
    footnote2 height=8pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

  run;

%mend Table;

/** End Macro Definition **/

options nodate nonumber orientation=landscape missing='n';

ods rtf file="&_dcdata_path\planning\prog\2010-07\Tables.rtf" style=Styles.Rtf_arial_8_5pt;
ods listing close;

%Table( 
  title="Demographics", autolabel=N,
  sec1="Population (census)", var1=totpop, years1=1980 1990 2000, fmt1=comma10.0,
  sec2="Population (estimates)", var2=PopEst, years2=2008, fmt2=comma10.0,
  sec3="Annual pop. change (%)", var3=AnnPopChg, years3=1980_1990 1990_2000 2000_2008,
  sec4="Households", var4=NumHshlds, years4=1980 1990 2000, fmt4=comma10.0,
  sec5="Persons per household", var5=hh_size, years5=1980 1990 2000, fmt5=comma10.2
)

%Table( 
  title="Economy - Jobs",
  sec1="Persons in labor force (Census)", var1=PopInCivLaborForce, years1=1980 1990 2000, fmt1=comma10.0,
  sec2="Persons in labor force, Dec. 2009 (LAUS)", var2=labor_force, years2=2009, fmt2=comma10.0,
  sec3="Unemployment rate (%)(Census)", var3=pct_unemp_census, years3=1980 1990 2000,
  sec4="Unemployment rate (%), Dec. 2009 (LAUS)", var4=Pct_unemp, years4=2009
)

%Table( 
  title="Economy - Income",
  sec1="% persons below poverty", var1=PctPoorPersons, years1=1980 1990 2000,
  sec2="Median HH income ($\~1999)", var2=r_MedianHshldIncome, years2=1990 2000, fmt2=comma10.0
)

%Table( 
  title="Economy - Income",
  sec1="% persons receiving food stamps", var1=pct_fs_client, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009,
  sec2="% persons receiving TANF", var2=pct_tanf_client, years2=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
)

%Table( 
  title="Economy - Housing (Sales)",
  sec1="No. SF home sales", var1=sales_sf, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009, fmt1=comma10.0,
  sec2="No. condo sales", var2=sales_condo, years2=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009, fmt2=comma10.0
)

%Table( 
  title="Economy - Housing (Sales)",
  sec1="Percent Single Family and Condominium Sales of Total Units", var1=pct_sales, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
)

%Table( 
  title="Economy - Housing (Prices)",
  sec1="Med. price SF homes ($ 2009)", var1=r_mprice_sf, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009, fmt1=comma10.0
)

 %Table( 
  title="Economy - Housing (Prices)",
  sec1="Med. price condos ($ 2009)", var1=r_mprice_condo, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009, fmt1=comma10.0
) 

%Table( 
  title="Economy - Housing (Home Purchase Mortgages)",
  sec1="No. mortgages originated", var1=nummrtgorighomepurch1_4m, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008, fmt1=comma10.0,
  sec2="% high cost mortgages", var2=Pcthighcostconvorigpurch, years2=2004 2005 2006 2007 2008
  )

%Table( 
  title="Economy - Housing (Home Purchase Mortgages)",
  sec1="% mortgages to owner-occupants", var1=Pctmrtgorigpurchowner1_4m, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008
)

%Table( 
  title="Economy - Housing (Home Purchase Mortgages by Income)",
  sec1="% high income borrowers", var1=PctMrtgOrig_hinc, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008,
  sec2="% middle income borrowers", var2=PctMrtgOrig_mi, years2=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008
  )

%Table( 
  title="Economy - Housing (Home Purchase Mortgages by Income)",
  sec1="% very low/low income borrowers", var1=PctMrtgOrig_low, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008
)

%Table( 
  title="Economy - Housing (Home Purchase Mortgages by Race/Ethnicity)",
  sec1="% black non-Hispanic borrowers", var1=Pctmrtgorigblack, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008,
  sec2="% white non-Hispanic borrowers", var2=Pctmrtgorigwhite, years2=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008
  )

%Table( 
  title="Economy - Housing (Home Purchase Mortgages by Race/Ethnicity)",
  sec1="% Hispanic borrowers", var1=Pctmrtgorighisp, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008
)

%Table( 
  title="Economy - Housing Pipeline",
  sec1="# Total units in development", var1=units, years1=2009, fmt1=comma10.0,
  sec2="# Affordable units in development", var2=affunits, years2=2009, fmt2=comma10.0
)

%Table( 
  title="Economy - Housing (Foreclosures)",
  sec1="No. of Notices of Foreclosure Sale per 1000 SF Homes & Condominiums", var1= forecl_1kpcl_sf_condo, years1=1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 
)

%Table( 
  title="Education - Test Proficiency", autolabel=N,
  sec1="DCPS Percent Proficient Math", var1=DCPS_pct_prof_math, years1=0607 0708 0809,
  sec2="DCPS Percent Proficient Reading", var2=DCPS_pct_prof_reading, years2=0607 0708 0809
  )

%Table( 
  title="Education - Test Proficiency", autolabel=N,
  sec1="PCSB Percent Proficient Math", var1=PCSB_pct_prof_math, years1=0607 0708 0809,
  sec2="PCSB Percent Proficient Reading", var2=PCSB_pct_prof_reading, years2=0607 0708 0809
  )

%Table( 
  title="Education - Test Proficiency", autolabel=N,
  sec1="All Schools Percent Proficient in Math", var1=city_pct_prof_math, years1=0607 0708 0809,
  sec2="All Schools Percent Proficient in Reading", var2=city_pct_prof_reading, years2=0607 0708 0809
  )

%Table( 
  title="Health (Births)",
  sec1="% low weight births", var1=Pct_births_low_wt, years1=1998 1999 2000 2001 2002 2003 2004 2005 2006 2007,
  sec2="% births to mothers under 20 years old", var2=Pct_births_teen, years2=1998 1999 2000 2001 2002 2003 2004 2005 2006 2007
  )

%Table( 
  title="Health (Births)",
  sec1="Mothers who recieved adequate prenatal care per 1,000 births", var1=Pct_births_prenat_adeq, years1=1999 2000 2001 2002 2003 2004 2005 2006 2007,
  sec2="Infant deaths per 1,000 births (3-yr avg)", var2=Infant_mort_rate, years2=2000 2001 2002 2003 2004 2005 2006 2007
)
/** NOTE: Death rate from violent causes not available in 1998 **/

%Table( 
  title="Health (Death Rates by Major Causes)",
  sec1="Deaths from heart disease per 1,000\pop.", var1=Rate_deaths_heart, years1=1998 1999 2000 2001 2002 2003 2004 2005 2006 2007,
  sec2="Deaths from cancer per 1,000\pop.", var2=Rate_deaths_cancer, years2=1998 1999 2000 2001 2002 2003 2004 2005 2006 2007
  )

%Table( 
  title="Health (Death Rates by Major Causes)",
  sec1="Deaths from violent causes (accidents, homicide, suicide) per 1,000\~pop.", var1=Rate_deaths_violent, years1=1999 2000 2001 2002 2003 2004 2005 2006 2007
)

%Table(
  title="Family, Youth, and Seniors (Households by Type)",
  sec1="% married couples w/children", var1=PctMarriedCoupleWKids, years1=1980 1990 2000,
  sec2="% single parents w/children", var2=PctSingleParentWKids, years2=1980 1990 2000,
  sec3="% other families", var3=PctOtherFamily, years3=1980 1990 2000,
  sec4="% non-family households", var4=PctNonFamily, years4=1980 1990 2000,
  sec5="Birth rate per 1,000 pop.", var5=Birth_rate, years5=1998 1999 2000 2001 2002 2003 2004 2005 2006 2007
)

%Table(
  title="Family, Youth, and Seniors (Children & Elderly)",
  sec1="% children under 18", var1=PctUnder18Years, years1=1980 1990 2000,
  sec2="% elderly 65 and older", var2=Pct65andOverYears, years2=1980 1990 2000,
  sec3="% children below poverty", var3=PctPoorChildren, years3=1990 2000,
  sec4="% elderly below poverty", var4=PctPoorElderly, years4=1990 2000
)

%Table(
  title="Safety and Security - All Violent Crime",
  sec1="Violent crimes reported per 1,000 pop.", var1=violent_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
  )

%Table(
  title="Safety and Security - Violent Crime, Homicide and Sexual Assault",
  sec1="Homicides reported per 1,000 pop.", var1=homicide_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009,
  sec2="Sexual Assaults reported per 1,000 pop.", var2=sexual_crime_rate, years2=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
  )

%Table(
  title="Safety and Security - Violent Crime, Assault and Robbery",
  sec1="Assaults reported per 1,000 pop.", var1=assault_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009,
  sec2="Robberies reported per 1,000 pop.", var2=robbery_crime_rate, years2=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
)

%Table(
  title="Safety and Security - Property Crime",
  sec1="Property crimes reported per 1,000 pop.", var1=property_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
)

%Table(
  title="Safety and Security - Property Crime, Arson and Autho Theft",
  sec1="Acts of Arson reported per 1,000 pop.", var1=arson_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009,
  sec2="Auto Theft reported per 1,000 pop.", var2=auto_crime_rate, years2=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
  )

%Table(
  title="Safety and Security - Property Crime, Burglary and Theft",
  sec1="Burglaries reported per 1,000 pop.", var1=burglary_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009,
  sec2="Theft reported per 1,000 pop.", var2=theft_crime_rate, years2=2000 2001 2002 2003 2004 2005 2006 2007 2008 2009
)


%Table(
  title="Environment (Tree Coverage and Health)",
  sec1="% area with tree canopy", var1=canopy_pct, years1=2006,
  sec2="% trees good/excellent condition", var2=pct_tree, years2=2010
)  

%Table(
  title="Environment (Property and public spaces)",
  sec1="Vacant/abandoned properties", var1=vacant_prop, years1=2009,fmt1=comma10.0,
  sec2="Number of Buildings with Green Roofs", var2=grnrfs_2, years2=2009, fmt2=comma10.0,
  sec3="Avg. distance to public park (feet)", var3=Park_dist_ft, years3=2007, fmt3=comma10.0,
  sec4="Avg. distance to recreation center (feet)", var4=Recpt_dist_ft, years4=2007, fmt4=comma10.0,
  sec5="Avg. distance to library (feet)", var5=Librarypt_dist_ft, years5=2009, fmt5=comma10.0
)  

%Table(
  title="Environment (Property and public spaces)",
  sec1="LEED/ Energy Star Certified Buildings", var1=building, years1=2010,fmt1=comma10.0
)

%Table(
  title="Food Access (Grocery Stores and Fast Food Establishments)",
  sec1="# Grocery Stores", var1=store, years1=2009, fmt1=comma10.,
  sec2="Average Distance to Grocery Store(feet)", var2=grocery_dist_ft, years2=2009, fmt2=comma10.0,
  sec3="# Fast Food Establishments", var3=fastfood, years3=2009, fmt3=comma10.0,
  sec4="Average Distance to Fast Food Establishment(feet)", var4=fastfood_dist_ft, years4=2009, fmt4=comma10.0
) 

%Table(
  title="Transportation (Access to Public Transportation)",
  sec1="# Metrobus Stops", var1=bus_stop, years1=2006, fmt1=comma10.,
  sec2="Average Distance to Metrobus Stop(feet)", var2=bus_dist_ft, years2=2006, fmt2=comma10.0,
  sec3="# Metrorail Stops", var3=metro, years3=2007, fmt3=comma10.,
  sec4="Average Distance to Metro Station(feet)", var4= metro_dist_ft, years4=2007, fmt4=comma10.0,
  sec5="Average AM Metrorail Boardings", var5=metro_boardings, years5=2009, fmt5=comma10.
)

%Table(
  title="Transportation (Access to Private Transportation)",
  sec1="# Vehicle Registrations", var1=numv, years1=2010, fmt1=comma10.,
  sec2="Population 18 or above with vehicle registrations (%)", var2=pct_vreg18, years2=2010, fmt2=comma10.
) 


ods rtf close;
ods listing;




