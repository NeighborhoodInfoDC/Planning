/**************************************************************************
 Program:  Cluster_charts.sas
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

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

/** Macro Output_sheet - Start Definition **/

%macro Output_sheet( var );

  ods tagsets.excelxp options( sheet_name="&var" );

  proc report data=Planning.dc_nbrhds_2010_7 nowd;
    where not missing( cluster_tr2000 ) and not missing( &var );
    column cluster_tr2000 &var;
    define &var / order order=internal;
    define cluster_tr2000 / 'Neighborhood cluster' format=$clus00a.;
  run;

%mend Output_sheet;

/** End Macro Definition **/


** Export data to XML workbook **;

ods tagsets.excelxp file="&_dcdata_path\Planning\Prog\2010-07\Cluster_charts_dat.xls" style=brown
      options( sheet_interval='page' );

%Output_sheet( PctUnemployed_2000 )
%Output_sheet( r_MedianHshldIncome_2000 )
%Output_sheet( pct_fs_client_2009 )
%Output_sheet( r_mprice_sf_2009 )
%Output_sheet( Pctmrtgorigpurchowner1_4m_2008 )
%Output_sheet( PctMrtgOrig_hinc_2008 )
/*%Output_sheet( Pct_births_low_wt_2005 )*/

ods tagsets.excelxp close;



run;
