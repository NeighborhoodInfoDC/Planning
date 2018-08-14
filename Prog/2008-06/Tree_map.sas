/**************************************************************************
 Program:  Tree_map.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/06/08
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create DBF file for Tree Canopy map by clusters.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

data Planning.Tree_map_2008_06 (compress=no);

  set Planning.dc_nbrhds_2008_06 
       (keep=cluster_tr2000 Canopy_area canopy_pct_2006);
       
  where cluster_tr2000 ~= "99" and not( missing( cluster_tr2000 ) );

  clusnum = 1 * cluster_tr2000;
  
  name = put( cluster_tr2000, $clus00a. );

  rename canopy_pct_2006=canopy_pct;
  
run;
