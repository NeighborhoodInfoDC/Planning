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
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

proc format;
  picture thous 
    . = '-' (noedit)
    low-<500 = "0" (noedit)
    500-high = "000,000,000" (mult=0.001);

/** Macro Output_sheet - Start Definition **/

%macro Output_sheet( var, fmt=best16. );

  ods tagsets.excelxp options( sheet_name="&var");
  
  proc report data=Planning.dc_nbrhds_2008_06 nowd showall;
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

ods tagsets.excelxp file="&_dcdata_path\planning\prog\2008-06\Cluster_charts2_dat.xls" style=minimal
      options( sheet_interval='page' );

ods listing close;

%Output_sheet( PopEst_2005 )
%Output_sheet( AnnPopChg_2000_2005 )
%Output_sheet( Pers_hhld_2000 )

%Output_sheet( PopInCivLaborForce_2000 )

/** Suppress data for cl. 5, 13, 19 **/
%Output_sheet( PctUnemployed_2000 )
%Output_sheet( PctPoorPersons_2000 )
%Output_sheet( r_MedianHshldIncome_2000 )
%Output_sheet( pct_fs_client_2007 )
%Output_sheet( pct_tanf_client_2007 )

%Output_sheet( sales_sf_2007 )
%Output_sheet( sales_condo_2007 )
%Output_sheet( r_mprice_sf_2007, fmt=thous. )
%Output_sheet( r_mprice_condo_2007, fmt=thous. )

%Output_sheet( NumMrtgOrigHomePurch1_4m_2005 )
%Output_sheet( Pctsubprimeconvorighomepur_2005 )
%Output_sheet( Pctmrtgorigpurchowner1_4m_2005 )
%Output_sheet( PctMrtgOrig_hinc_2005 )
%Output_sheet( PctMrtgOrig_mi_2005 )
%Output_sheet( PctMrtgOrig_low_2005 )

%Output_sheet( Pctmrtgorigblack_2005 )
%Output_sheet( Pctmrtgorigwhite_2005 )
%Output_sheet( Pctmrtgorighisp_2005 )

%Output_sheet( forecl_1kpcl_sf_condo_2007 )

%Output_sheet( enroll_pk_5_2006 )
%Output_sheet( enroll_6_8_2006 )
%Output_sheet( enroll_9_12_2006 )

%Output_sheet( pct_frp_pk_5_2006 )
%Output_sheet( pct_frp_6_8_2006 )

%Output_sheet( pct_read_prfadv_2006 )
%Output_sheet( pct_math_prfadv_2006 )

%Output_sheet( Pct_births_low_wt_2005 )
%Output_sheet( Pct_births_teen_2005 )
%Output_sheet( Pct_births_prenat_adeq_2005 )
%Output_sheet( Infant_mort_rate_2005 )

%Output_sheet( Rate_deaths_heart_2005 )
%Output_sheet( Rate_deaths_cancer_2005 )
%Output_sheet( Rate_deaths_violent_2005 )

%Output_sheet( PctMarriedCoupleWKids_2000 )
%Output_sheet( PctSingleParentWKids_2000 )
%Output_sheet( PctNonFamily_2000 )
%Output_sheet( Birth_rate_2005 )

%Output_sheet( PctUnder18Years_2000 )
%Output_sheet( Pct65andOverYears_2000 )
%Output_sheet( PctPoorChildren_2000 )
%Output_sheet( PctPoorElderly_2000 )

%Output_sheet( violent_crime_rate_2006 )
%Output_sheet( property_crime_rate_2006 )

%Output_sheet( canopy_pct_2006 )
%Output_sheet( pct_no_tree_2006 )
%Output_sheet( pct_tree_good_excel_2006 )

%Output_sheet( vacant_prop_2008 )
%Output_sheet( vacant_land_2008 )
%Output_sheet( park_dist_2008 )
%Output_sheet( Green_roofs_2007 )

ods tagsets.excelxp close;

ods listing;

run;
