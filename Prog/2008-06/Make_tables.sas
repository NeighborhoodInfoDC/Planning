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

***%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "C:\DCData\SAS\Inc\Stdhead.sas";

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
    lbl = '\b Washington, DC';
    output;
  end;
  
  if inWard then do;
    geo = '1' || ward2002 || '00';
    if ward2002 ~= 5 then 
      lbl = '\i ' || put( ward2002, $ward02a. );
    else 
      lbl = '\pagebb\i ' || put( ward2002, $ward02a. );
  end;
  else if inCluster then do;
    geo = '1' || ward2002 || cluster2000;
    lbl = '\~\~ ' || put( cluster2000, $clus00a. );
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
  
  proc report data=Planning.dc_nbrhds_2008_06 nowd split='^';
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
    title1 height=8pt "\b0\i State of Washington, D.C.'s Neighborhoods";
    title2 &title;
    footnote1 height=8pt "Data compiled by NeighborhoodInfo DC (updated &fdate).";
    footnote2 height=8pt j=r '{Page}\~{\field{\*\fldinst{\pard\b\i0\chcbpat8\qc\f1\fs19\cf1{PAGE }\cf0\chcbpat0}}}';

  run;

%mend Table;

/** End Macro Definition **/



options nodate nonumber orientation=landscape missing='n';

ods rtf file="&_dcdata_path\planning\prog\2008-06\Tables.rtf" style=Styles.Rtf_arial_8_5pt;
ods listing close;

%Table( 
  title="Demographics", autolabel=N,
  sec1="Population (census)", var1=totpop, years1=1980 1990 2000, fmt1=comma10.0,
  sec2="Population (estimates)", var2=PopEst, years2=2005, fmt2=comma10.0,
  sec3="Annual pop. change (%)", var3=AnnPopChg, years3=1980_1990 1990_2000 2000_2005,
  sec4="Households", var4=NumHshlds, years4=1980 1990 2000, fmt4=comma10.0,
  sec5="Persons per household", var5=Pers_hhld, years5=1980 1990 2000
)

%Table( 
  title="Economy - Jobs and Income",
  sec1="Persons in labor force", var1=PopInCivLaborForce, years1=1980 1990 2000, fmt1=comma10.0,
  sec2="Unemployment rate (%)", var2=PctUnemployed, years2=1980 1990 2000,
  sec3="% persons below poverty", var3=PctPoorPersons, years3=1980 1990 2000,
  sec4="Median HH income ($\~1999)", var4=r_MedianHshldIncome, years4=1990 2000, fmt4=comma10.0,
  sec5="% persons receiving food stamps", var5=pct_fs_client, years5=2000 2001 2002 2003 2004 2005 2006 2007,
  sec6="% persons receiving TANF", var6=pct_tanf_client, years6=2000 2001 2002 2003 2004 2005 2006 2007
)

%Table( 
  title="Economy - Housing (Sales)",
  sec1="No. SF home sales", var1=sales_sf, years1=2000 2001 2002 2003 2004 2005 2006 2007, fmt1=comma10.0,
  sec2="No. condo sales", var2=sales_condo, years2=2000 2001 2002 2003 2004 2005 2006 2007, fmt2=comma10.0
)

%Table( 
  title="Economy - Housing (Prices)",
  sec1="Med. price SF homes ($ 2007)", var1=r_mprice_sf, years1=2000 2001 2002 2003 2004 2005 2006 2007, fmt1=comma10.0,
  sec2="Med. price condos ($ 2007)", var2=r_mprice_condo, years2=2000 2001 2002 2003 2004 2005 2006 2007, fmt2=comma10.0
)
  
%Table( 
  title="Economy - Housing (Home Purchase Mortgages)",
  sec1="No. mortgages originated", var1=nummrtgorighomepurch1_4m, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005, fmt1=comma10.0,
  sec2="% mortgages from subprime lenders", var2=Pctsubprimeconvorighomepur, years2=1997 1998 1999 2000 2001 2002 2003 2004 2005,
  sec3="% mortgages to owner-occupants", var3=Pctmrtgorigpurchowner1_4m, years3=1997 1998 1999 2000 2001 2002 2003 2004 2005
)

%Table( 
  title="Economy - Housing (Home Purchase Mortgages by Income)",
  sec1="% high income borrowers", var1=PctMrtgOrig_hinc, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005,
  sec2="% middle income borrowers", var2=PctMrtgOrig_mi, years2=1997 1998 1999 2000 2001 2002 2003 2004 2005,
  sec3="% very low/low income borrowers", var3=PctMrtgOrig_low, years3=1997 1998 1999 2000 2001 2002 2003 2004 2005
)

%Table( 
  title="Economy - Housing (Home Purchase Mortgages by Race/Ethnicity)",
  sec1="% black non-Hispanic borrowers", var1=Pctmrtgorigblack, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005,
  sec2="% white non-Hispanic borrowers", var2=Pctmrtgorigwhite, years2=1997 1998 1999 2000 2001 2002 2003 2004 2005,
  sec3="% Hispanic borrowers", var3=Pctmrtgorighisp, years3=1997 1998 1999 2000 2001 2002 2003 2004 2005
)

%Table( 
  title="Economy - Housing (Foreclosures)",
  sec1="Foreclosure rate per 1,000 SF homes & condominiums", var1=forecl_1kpcl_sf_condo, years1=1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007
)

%Table( 
  title="Education", autolabel=N,
  sec1="DCPS/public charter school enrollment, 2006/07", var1=enroll, years1=pk_5_2006 6_8_2006 9_12_2006, fmt1=comma10.0,
  sec2="% enrolled, free/reduced price lunch, 2006/07", var2=pct_frp, years2=pk_5_2006 6_8_2006,
  sec3="% proficient or above, reading", var3=pct_read_prfadv, years3=2006,
  sec4="% proficient or above, math", var4=pct_math_prfadv, years4=2006
)

%Table( 
  title="Health (Births)",
  sec1="% low weight births", var1=Pct_births_low_wt, years1=1998 1999 2000 2001 2002 2003 2004 2005,
  sec2="% births to mothers under 20 years old", var2=Pct_births_teen, years2=1998 1999 2000 2001 2002 2003 2004 2005,
  sec3="% births with adequate prenatal care", var3=Pct_births_prenat_adeq, years3=1999 2000 2001 2002 2003 2004 2005,
  sec4="Infant deaths per 1,000 births (3-yr avg)", var4=Infant_mort_rate, years4=2000 2001 2002 2003 2004 2005
)

/** NOTE: Death rate from violent causes not available in 1998 **/

%Table( 
  title="Health (Death Rates by Major Causes)",
  sec1="Deaths from heart disease per 1,000\~pop.", var1=Rate_deaths_heart, years1=1998 1999 2000 2001 2002 2003 2004 2005,
  sec2="Deaths from cancer per 1,000\~pop.", var2=Rate_deaths_cancer, years2=1998 1999 2000 2001 2002 2003 2004 2005,
  sec3="Deaths from violent causes (accidents, homicide, suicide) per 1,000\~pop.", var3=Rate_deaths_violent, years3=1999 2000 2001 2002 2003 2004 2005
)

%Table(
  title="Family, Youth, and Seniors (Households by Type)",
  sec1="% married couples w/children", var1=PctMarriedCoupleWKids, years1=1980 1990 2000,
  sec2="% single parents w/children", var2=PctSingleParentWKids, years2=1980 1990 2000,
  sec3="% other families", var3=PctOtherFamily, years3=1980 1990 2000,
  sec4="% non-family households", var4=PctNonFamily, years4=1980 1990 2000,
  sec5="Birth rate per 1,000 pop.", var5=Birth_rate, years5=1998 1999 2000 2001 2002 2003 2004 2005
)

%Table(
  title="Family, Youth, and Seniors (Children & Elderly)",
  sec1="%\~children under 18", var1=PctUnder18Years, years1=1980 1990 2000,
  sec2="%\~elderly 65 and older", var2=Pct65andOverYears, years2=1980 1990 2000,
  sec3="%\~children below poverty", var3=PctPoorChildren, years3=1990 2000,
  sec4="%\~elderly below poverty", var4=PctPoorElderly, years4=1990 2000
)

%Table(
  title="Safety and Security",
  sec1="Violent crimes reported per 1,000\~pop.", var1=violent_crime_rate, years1=2000 2001 2002 2003 2004 2005 2006,
  sec2="Property crimes reported per 1,000\~pop.", var2=property_crime_rate, years2=2000 2001 2002 2003 2004 2005 2006
)

%Table(
  title="Environment (Tree Coverage and Health)",
  sec1="%\~area with tree\~canopy", var1=canopy_pct, years1=2006,
  sec2="%\~sites with no\~tree/dead\~tree/ trunk/stump", var2=pct_no_tree, years2=2006,
  sec3="%\~trees good/excellent condition", var3=pct_tree_good_excel, years3=2006
)  

%Table(
  title="Environment (Property and public spaces)",
  sec1="Vacant/abandoned properties (per\~10,000\~parcels)", var1=vacant_prop, years1=2008,
  sec2="% vacant, unimproved land", var2=vacant_land, years2=2008,
  sec3="Properties with green\~roofs", var3=Green_roofs, years3=2007, fmt3=comma10.0,
  sec4="Avg.\~distance\~to public\~park (meters)", var4=Park_dist, years4=2008, fmt4=comma10.0
)  

ods rtf close;
ods listing;

