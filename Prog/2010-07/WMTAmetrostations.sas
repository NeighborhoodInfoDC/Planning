/**************************************************************************
 Program:  WMTAmetrostations.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   J. Comey
 Created:  07/20/10
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Merge average weekday metro entries by block, tract, cluster, and ward altogether.

 Modifications:
**************************************************************************/


%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( transit )
;
*metrostnpt_spatialjoin1 is metro stops with entries from FY2010 and tracts
metrostnpt_spatialjoin2 is with clusters, metrostnpt_spatialjoin3 is with wards, and metrostnpt_spatialjoin4
is with blocks;
data tract;
	set transit.metrostnpt_spatialjoin1 ;
	drop Join_Count OBJECTID WEB_URL;run;
data cluster;
	set transit.metrostnpt_spatialjoin2 ;
	drop Join_Count OBJECTID WEB_URL;run;
data ward;
	set transit.metrostnpt_spatialjoin4 ;
	drop Join_Count OBJECTID WEB_URL;run;
data block;
	set transit.metrostnpt_spatialjoin4 ;
	drop Join_Count OBJECTID WEB_URL;run;
proc sort data=tract ;
by GIS_ID;
run;
proc sort data=cluster ;
by GIS_ID;
run;
proc sort data=ward;
by GIS_ID;
run;
proc sort data=block ;
by GIS_ID;
run;
data test;
	merge tract cluster ward block;
	by GIS_ID;
	run;

proc contents data=test;
run;

