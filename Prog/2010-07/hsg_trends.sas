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

ods tagsets.excelxp file="&_dcdata_path\planning\prog\2010-07\Hsg_trends.xls" style=styles.minimal_mystyle
      options( sheet_interval='page' );

%Output_sheet( sales_sf_2000-sales_sf_2009 )
%Output_sheet( sales_condo_2000-sales_condo_2009 )
%Output_sheet( r_mprice_sf_2000-r_mprice_sf_2009 )
%Output_sheet( r_mprice_condo_2000-r_mprice_condo_2009 )

%Output_sheet( NumMrtgOrigHomePurch1_4m_1997-NumMrtgOrigHomePurch1_4m_2008 )
%Output_sheet( Pcthighcostconvorigpurch_2004-Pcthighcostconvorigpurch_2008 )
%Output_sheet( Pctmrtgorigpurchowner1_4m_1997-Pctmrtgorigpurchowner1_4m_2008 )

%Output_sheet( PctMrtgOrig_hinc_1997-PctMrtgOrig_hinc_2008 )
%Output_sheet( PctMrtgOrig_mi_1997-PctMrtgOrig_mi_2008 )
%Output_sheet( PctMrtgOrig_low_1997-PctMrtgOrig_low_2008 )
%Output_sheet( PctMrtgOrig_li_1997-PctMrtgOrig_li_2008 )
%Output_sheet( PctMrtgOrig_vli_1997-PctMrtgOrig_vli_2008 )



%Output_sheet( Pctmrtgorigblack_1997-Pctmrtgorigblack_2008 )
%Output_sheet( Pctmrtgorigwhite_1997-Pctmrtgorigwhite_2008 )
%Output_sheet( Pctmrtgorighisp_1997-Pctmrtgorighisp_2008 )
%Output_sheet( forecl_1kpcl_sf_condo_1990-forecl_1kpcl_sf_condo_2009 )

ods tagsets.excelxp close;

ods listing;

run;
