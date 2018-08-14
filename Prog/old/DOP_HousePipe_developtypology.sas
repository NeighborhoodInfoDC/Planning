/**************************************************************************
 Program:  DOP_HousePipe_developtypology.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC/School Assignment Policies
 Author:   Jcomey
 Created:  9/18/2008
 Updated:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Categorizing housing development and aggregating by neighbohorhood cluster 

 Modifications:
Notes: 


**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( General );
%DCData_lib( Planning );

proc format data=data Houspipe2008q2_clust_spatjoin;
	value statusid;

	1 = "Completed"  
	2 = "Under Construction"-
	3 =  "Planned" 
	4 = "Conceptual"
	9 = "New Neighborhood";  
 
data Houspipe2008q2_clust_spatjoin;
	set planning.Houspipe2008q2_clust_spatjoin;

 
**********Export geocoded file*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Planning\Raw\HousPipe_2008_geocode.csv" lrecl=2000;

proc export data=planning.HousPipe_2008_geocode
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;



