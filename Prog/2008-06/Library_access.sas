/**************************************************************************
 Program:  Library_access.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/05/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Calculate population weighted average distance to a
 DC public library for wards, clusters, and the city.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Census )

data Block_dist;

  set Planning.librarypt_block_dist;
  
  %Octo_GeoBlk2000()
  
  %Block00_to_ward02()
  %Block00_to_cluster_tr00()
  %Block00_to_city()
  
  distance_mi = distance / 1609.344;

  format distance ;
  informat distance ;

  keep geoblk2000 ward2002 cluster_tr2000 city distance distance_mi; 
  
  rename distance=library_dist_2008 distance_mi=library_dist_mi_2008;

run;

proc sort data=Block_dist;
  by geoblk2000;

** Merge with pop totals **;

data Block_dist_pop;

  merge
    Block_dist
    Census.Cen2000_sf1_dc_blks (keep=geoblk2000 p1i1);
  by geoblk2000;

  rename p1i1=Pop_2000;

run;

%File_info( data=Block_dist_pop )

proc summary data=Block_dist_pop nway;
  class ward2002;
  var library_dist_2008 library_dist_mi_2008 / weight=Pop_2000;
  output out=Planning.Library_access_wd02 (drop=_type_ _freq_) mean= ;
run;

proc print;
run;


proc summary data=Block_dist_pop nway;
  class cluster_tr2000;
  var library_dist_2008 library_dist_mi_2008 / weight=Pop_2000;
  output out=Planning.Library_access_cltr00 (drop=_type_ _freq_) mean= ;
run;

proc print;
run;


proc summary data=Block_dist_pop nway;
  class city;
  var library_dist_2008 library_dist_mi_2008 / weight=Pop_2000;
  output out=Planning.Library_access_city (drop=_type_ _freq_) mean= ;
run;

proc print;
run;


