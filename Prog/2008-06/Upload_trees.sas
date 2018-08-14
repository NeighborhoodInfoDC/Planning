/**************************************************************************
 Program:  Upload_trees.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/25/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Upload Casey trees data to Alpha.
 
 NB: Files are not registered.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Planning )

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=Planning 
  outlib=Planning memtype=(data);
  select Tree_canopy_: Casey_trees_: ;

run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
