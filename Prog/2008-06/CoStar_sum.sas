/**************************************************************************
 Program:  CoStar_sum.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/05/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Summarize CoStar data by city, ward, cluster.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Planning )

** Start submitting commands to remote server **;

rsubmit;

%let sum_vars = RentableBuildingArea DirectAvailableSpace;

proc summary data=Planning.CoStar_2008 nway;
  var &sum_vars;
  var AverageWeightedRent / weight=DirectAvailableSpace;
  class city;
  output out=Planning.CoStar_sum_city (drop=_type_ _freq_) 
    sum(&sum_vars)=RentableBuildingArea_2008 DirectAvailableSpace_2008
    mean(AverageWeightedRent)=AverageWeightedRent_2008;
run;

proc print;
run;

proc summary data=Planning.CoStar_2008 nway;
  var &sum_vars;
  var AverageWeightedRent / weight=DirectAvailableSpace;
  class ward2002;
  output out=Planning.CoStar_sum_wd02 (drop=_type_ _freq_) 
    sum(&sum_vars)=RentableBuildingArea_2008 DirectAvailableSpace_2008
    mean(AverageWeightedRent)=AverageWeightedRent_2008;
run;

proc print;
run;

proc summary data=Planning.CoStar_2008 nway;
  var &sum_vars;
  var AverageWeightedRent / weight=DirectAvailableSpace;
  class cluster_tr2000;
  output out=Planning.CoStar_sum_cltr00 (drop=_type_ _freq_) 
    sum(&sum_vars)=RentableBuildingArea_2008 DirectAvailableSpace_2008
    mean(AverageWeightedRent)=AverageWeightedRent_2008;
run;

proc print;
run;


endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
