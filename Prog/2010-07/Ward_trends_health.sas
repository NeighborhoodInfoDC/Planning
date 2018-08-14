/**************************************************************************
 Program:  Ward_trends.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/09/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Ward trend line charts

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
proc template;

define style styles.minimal_mystyle;

parent=styles.minimal;

style _r from Data/

htmlclass = '_r';

style pagebreak from Data/

htmlclass = 'pagebreak';

style parskip from Data/

htmlclass = 'parskip';

end;

run;
/** Macro Output_sheet - Start Definition **/

%macro Output_sheet( vars );

  ods tagsets.excelxp options( sheet_name="%scan( &vars, 1 )" );

  proc report data=Planning.dc_nbrhds_2010_7 nowd;
    where missing( cluster_tr2000 );
    column ward2002 &vars;
    define ward2002 / 'Wards' format=$wardx.;
  run;

%mend Output_sheet;

/** End Macro Definition **/

proc format;
  value $wardx
    ' ' = 'Washington, DC'
    '1' = 'Ward 1'
    '2' = 'Ward 2'
    '3' = 'Ward 3'
    '4' = 'Ward 4'
    '5' = 'Ward 5'
    '6' = 'Ward 6'
    '7' = 'Ward 7'
    '8' = 'Ward 8'
   ;    

** Export data to XML workbook **;

ods listing close;

ods tagsets.excelxp file="&_dcdata_path\planning\prog\2010-07\Ward_trends_health.xls" style=styles.minimal_mystyle
      options( sheet_interval='page' );

%Output_sheet( Birth_rate_1998-Birth_rate_2007 )
%Output_sheet( Pct_births_prenat_adeq_1999-Pct_births_prenat_adeq_2007 )
%Output_sheet( Pct_births_low_wt_1998-Pct_births_low_wt_2007 )
%Output_sheet( Pct_births_teen_1998-Pct_births_teen_2007 )
%Output_sheet( Infant_mort_rate_2000-Infant_mort_rate_2007 )
%Output_sheet( Rate_deaths_heart_1998-Rate_deaths_heart_2007 )

ods tagsets.excelxp close;

ods listing;

run;
