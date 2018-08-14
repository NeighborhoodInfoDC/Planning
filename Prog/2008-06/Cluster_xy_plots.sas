/**************************************************************************
 Program:  Cluster_xy_plots.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/09/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Output data in Excel-compatible format (XML) for
 creating histogram charts of indicators by neighborhood cluster.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

/** Macro Output_sheet - Start Definition **/

%macro Output_sheet( var1, var2 );

  ods tagsets.excelxp options( sheet_name="&var1-&var2" );

  proc report data=Cluster_xy_plots nowd;
    where not missing( cluster_tr2000 ) and not missing( &var1 ) and not missing( &var2 );
    column cluster_tr2000 &var1 &var2;
    *define &var / order order=internal;
    define cluster_tr2000 / 'Neighborhood cluster' format=$clus00a.;
  run;

%mend Output_sheet;

/** End Macro Definition **/

data Cluster_xy_plots;

  set Planning.dc_nbrhds_2008_06;
  
  price_chg = 100 * %annchg( r_mprice_sf_2000, r_mprice_sf_2006, 2006-2000 );
  
  if cluster_tr2000 = '08' then delete;

run;

** Export data to XML workbook **;

ods tagsets.excelxp file="&_dcdata_path\planning\prog\2008-06\Cluster_xy_plots_dat.xls" style=minimal
      options( sheet_interval='page' );

%Output_sheet( price_chg, Pctmrtgorigpurchowner1_4m_2005 )

ods tagsets.excelxp close;



run;
