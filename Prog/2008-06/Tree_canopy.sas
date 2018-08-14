/**************************************************************************
 Program:  Tree_canopy.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/25/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read tree canopy data and create summary files for
cluster, ward, and city.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Census )

** Get land area by cluster **;

data area_blk;

  set Census.Cen2000_sf1_dc_blks 
    (keep=arealand geoblk2000);
    
  %Block00_to_cluster_tr00()
  
  if cluster_tr2000 = '99' then delete;

run;

proc summary data=area_blk nway;
  class cluster_tr2000;
  var arealand;
  output out=area_cltr00 (compress=n drop=_type_ _freq_) sum=;
run;

** Read canopy data **;

filename csvFile  "D:\DCData\Libraries\Planning\Raw\Casey Trees\treecanopy_2006.csv" lrecl=256;

data canopy;

  infile csvFile dsd stopover firstobs=2;

  input xcluster canopy_pct : percent3.0; 
  
  ** Convert from proportion to pct. **;
  
  canopy_pct = 100 * canopy_pct;
  
  length cluster_tr2000 $ 2;
  
  cluster_tr2000 = put( xcluster, z2.0 );
  
  drop xcluster;
  
run;

data Planning.Tree_canopy_cltr00;

  length city $ 1;
  retain city '1';

  merge 
    canopy 
    area_cltr00 
    General.Cluster2000 
      (keep=cluster2000 ward2002
       rename=(cluster2000=cluster_tr2000));
  by cluster_tr2000;
  
  canopy_area = canopy_pct * arealand;
  
  label
    canopy_area = "Tree canopy area (sq. meters)";
  
run;

%File_info( data=Planning.Tree_canopy_cltr00 )


** Ward level **;

proc summary data=Planning.Tree_canopy_cltr00 nway;
  class ward2002;
  var canopy_area arealand;
  var canopy_pct / weight=arealand;
  output out=Planning.Tree_canopy_wd02 (drop=_type_ _freq_)
    sum( canopy_area arealand )= mean( canopy_pct )= ;
run;

%File_info( data=Planning.Tree_canopy_wd02 )


** City level **;

proc summary data=Planning.Tree_canopy_cltr00 nway;
  class city;
  var canopy_area arealand;
  var canopy_pct / weight=arealand;
  output out=Planning.Tree_canopy_city (drop=_type_ _freq_)
    sum( canopy_area arealand )= mean( canopy_pct )= ;
run;

%File_info( data=Planning.Tree_canopy_city )

