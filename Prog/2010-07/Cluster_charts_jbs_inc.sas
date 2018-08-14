/**************************************************************************
 Program:  Cluster_charts2.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/09/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Output data in Excel-compatible format (XML) for
 creating histogram charts of indicators by neighborhood cluster.
 
 Note: Need to fill in value of 20 for cluster 38 in subprime table.
 (Repeated values across clusters are blanked by Proc Report.)

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


proc format;
  picture thous 
    . = '-' (noedit)
    low-<500 = "0" (noedit)
    500-high = "000,000,000" (mult=0.001);



/** Macro Output_sheet - Start Definition **/

%macro Output_sheet( var, fmt=best16. );

  ods tagsets.excelxp options( sheet_name="&var");
  
  proc report data=Planning.dc_nbrhds_2010_7 nowd showall;
    *where not missing( cluster_tr2000 ) and not missing( &var );
    where not missing( cluster_tr2000 );
	
    column ward2002 cluster_tr2000 &var;
    define ward2002 / order order=internal descending format=$ward02a.;
    define &var / order order=internal format=&fmt;
    define cluster_tr2000 / 'Neighborhood cluster' format=$clus00a.;
  run;

%mend Output_sheet;

/** End Macro Definition **/


** Export data to XML workbook **;

ods tagsets.excelxp file="&_dcdata_path\planning\prog\2010-07\Cluster Tables\Cluster_charts_jbs_inc_dat.xls" style=styles.minimal_mystyle  
      options( sheet_interval='page' );

ods listing close;

%Output_sheet( PctUnemployed_2000 )
%Output_sheet( PctPoorPersons_2000 )
%Output_sheet( r_MedianHshldIncome_2000 )
%Output_sheet( pct_fs_client_2009 )
%Output_sheet( pct_tanf_client_2009 )


ods tagsets.excelxp close;

ods listing;

run;



