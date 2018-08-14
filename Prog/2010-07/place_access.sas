/**************************************************************************
 Program:  Park_access.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/30/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Calculate population weighted average distance to a
 park or recreation area for wards, clusters, and the city.

 Modifications: CJN-&site.
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%let site = metro;
%let year = 2007;
/*
"Avg. distance to public park (miles)", var3=Park_dist_mi, years3=2007
"Avg. distance to recreation center (miles)", var4=Rec_dist_mi, years4=2007
"Avg. distance to library (miles)", var5=Library_dist_mi, years5=2009
"Average Distance to Grocery Store(miles)", var2=grocery_dist_mi, years2=2009
"Average Distance to Fast Food Establishment(miles)", var4=fastfood_dist_mi, years4=2009
"Average Distance to Metrobus Stop(miles)", var2=bus_dist_mi, years2=2006
"Average Distance to Metro Station(miles)", var4= metro_dist_mi, years4=2007,
*/

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Census )

data Block_dist;

  set Planning.&site._block_dist;
  
  %Octo_GeoBlk2000()
  
  %Block00_to_ward02()
  %Block00_to_cluster_tr00()
  %Block00_to_city()
  
  
  distance_yd = distance * 1.0936133;

  format distance ;
  informat distance ;

  keep geoblk2000 ward2002 cluster_tr2000 city distance distance_yd; 
  
  rename distance=&site._dist_&year. distance_yd=&site._dist_yd_&year.;

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
  var &site._dist_&year. &site._dist_yd_&year. / weight=Pop_2000;
  output out=Planning.&site._access_wd02 (drop=_type_ _freq_) mean= ;
run;

proc print;
run;


proc summary data=Block_dist_pop nway;
  class cluster_tr2000;
  var &site._dist_&year. &site._dist_yd_&year. / weight=Pop_2000;
  output out=Planning.&site._access_cltr00 (drop=_type_ _freq_) mean= ;
run;

proc print;
run;


proc summary data=Block_dist_pop nway;
  class city;
  var &site._dist_&year. &site._dist_yd_&year. / weight=Pop_2000;
  output out=planning.&site._access_city (drop=_type_ _freq_) mean= ;
run;

proc print;
run;


