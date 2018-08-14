/**************************************************************************
 Program:  Temp.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/24/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:

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



options nodate nonumber orientation=landscape;

ods rtf file="&_dcdata_path\planning\prog\2008-06\Infant_deaths.rtf" style=Styles.Rtf_arial_8_5pt;
ods listing close;

%Table( 
  title="Health (Births)",
  sec1="Infant deaths (3-yr avg)", var1=deaths_infant_3yr, years1=2000 2001 2002 2003 2004 2005, fmt1=comma10.0,
  sec2="Births (3-yr avg)", var2=births_total_3yr, years2=2000 2001 2002 2003 2004 2005, fmt2=comma10.0,
  sec3="Infant deaths per 1,000 births (3-yr avg)", var3=Infant_mort_rate, years3=2000 2001 2002 2003 2004 2005
)

ods rtf close;
ods listing;

