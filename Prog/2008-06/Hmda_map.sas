/**************************************************************************
 Program:  Hmda_map.sas
 Library:  HsngMon
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/11/06
 Version:  SAS 8.2
 Environment:  Windows
 
 Description:  Create DBF file for HMDA map by clusters.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

data Planning.Hmda_map_2008_06 (compress=no);

  set Planning.dc_nbrhds_2008_06 
       (keep=cluster_tr2000 Pctsubprimeconvorighomepur_2005);
       
  where cluster_tr2000 ~= "99" and not( missing( cluster_tr2000 ) );

  clusnum = 1 * cluster_tr2000;
  
  name = put( cluster_tr2000, $clus00a. );

  rename Pctsubprimeconvorighomepur_2005=pctsubpr05;
  
run;
