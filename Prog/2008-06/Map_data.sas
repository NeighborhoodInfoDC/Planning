/**************************************************************************
 Program:  Map_data.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/13/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Export data for neighborhood cluster maps.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

data Planning.dc_nbrhds_map_2008_06 (compress=no);

  set Planning.dc_nbrhds_2008_06;
  where not( missing( cluster_tr2000 ) );
  
  ** Income change **;
  
  ChInc90_00 = %pctchg( r_MedianHshldIncome_1990, r_MedianHshldIncome_2000 );
  
  ChMLo97_05 = PctMrtgOrig_low_2005 - PctMrtgOrig_low_1997;
  
  keep cluster_tr2000 AnnPopChg_2000_2005 ChInc90_00 ChMLo97_05 forecl_1kpcl_sf_condo_2007;
  
  rename AnnPopChg_2000_2005=ChPop00_05 forecl_1kpcl_sf_condo_2007=Forecl07;

run;
