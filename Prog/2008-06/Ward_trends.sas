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

/** Macro Output_sheet - Start Definition **/

%macro Output_sheet( vars );

  ods tagsets.excelxp options( sheet_name="%scan( &vars, 1 )" );

  proc report data=Planning.dc_nbrhds_2008_06 nowd;
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

ods tagsets.excelxp file="&_dcdata_path\planning\prog\2008-06\Ward_trends_dat.xls" style=minimal
      options( sheet_interval='page' );

%Output_sheet( Birth_rate_1998-Birth_rate_2005 )
%Output_sheet( PctMrtgOrig_hinc_1997-PctMrtgOrig_hinc_2005 )
%Output_sheet( Pct_births_prenat_adeq_1999-Pct_births_prenat_adeq_2005 )
%Output_sheet( violent_crime_rate_2000-violent_crime_rate_2006 )
%Output_sheet( property_crime_rate_2000-property_crime_rate_2006 )

%Output_sheet( pct_fs_client_2000-pct_fs_client_2007 )
%Output_sheet( pct_tanf_client_2000-pct_tanf_client_2007 )

ods tagsets.excelxp close;

ods listing;

run;
