/**************************************************************************
 Program:  Read_casey_trees.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/24/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read data provided by Casey Trees for OP Neighborhood
report.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

filename csvFile "D:\DCData\Libraries\Planning\Raw\Casey Trees\InventoryFindings_060603D_anc.csv" lrecl=2000;

data Planning.Casey_trees_anc;

  infile csvFile dsd stopover firstobs=2 obs=38;

  input
    anc $
    skip1 $
    No_tree
    Dead
    Trunk
    Stump
    Acer
    Quercus
    Ulmus
    Tilia
    Ginkgo
    Zelkova
    Platanus
    Pyrus
    Prunus
    Other
    Unknown
    Totals
    No_tree_trunk_stump
    Excellent
    Good
    Fair
    Poor
    Dead
  ;

  length city ward2002 $ 1;

  city = '1';

  ward2002 = anc;
  
  drop skip1;

run;

%File_info( data=Planning.Casey_trees_anc )

proc summary data=Planning.Casey_trees_anc;
  by city;
  var _numeric_;
  output out=Planning.Casey_trees_city (drop=_type_ _freq_) sum=;
  format city $city.;
run;

%File_info( data=Planning.Casey_trees_city, freqvars=city )

proc summary data=Planning.Casey_trees_anc;
  by ward2002;
  var _numeric_;
  output out=Planning.Casey_trees_wd02 (drop=_type_ _freq_) sum=;
  format ward2002 $ward02a.;
run;

%File_info( data=Planning.Casey_trees_wd02, freqvars=ward2002 )


** Clusters **;

data Planning.Casey_trees_cltr00;

  infile csvFile dsd stopover firstobs=45 obs=84;
  
  length cluster_tr2000 $ 2;

  input
    cluster_tr2000 $
    skip1 $
    No_tree
    Dead
    Trunk
    Stump
    Acer
    Quercus
    Ulmus
    Tilia
    Ginkgo
    Zelkova
    Platanus
    Pyrus
    Prunus
    Other
    Unknown
    Totals
    No_tree_trunk_stump
    Excellent
    Good
    Fair
    Poor
    Dead
  ;

  if cluster_tr2000 = '00' then cluster_tr2000 = '99';

  drop skip1;
     
  format cluster_tr2000 $clus00a.;

run;

%File_info( data=Planning.Casey_trees_cltr00, freqvars=cluster_tr2000 )

