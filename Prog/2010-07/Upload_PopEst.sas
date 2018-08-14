/**************************************************************************
 Program:  Upload_PopEst.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/08
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Upload OP population estimates.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Planning )

rsubmit;

/** Macro Upload_dat - Start Definition **/

%macro Upload_dat( lib=, data=, revisions=New file. );

  proc upload status=no
    data=&lib..&data 
    out=&lib..&data;
  run;
  
  x "purge [DCData.General.data]&data..*";
  
  run;
  
  %Dc_update_meta_file(
    ds_lib=&lib,
    ds_name=&data,
    creator_process=&data..sas,
    restrictions=None,
    revisions=%str(&revisions)
  )
  
  run;

%mend Upload_dat;

/** End Macro Definition **/
%Upload_dat( lib=Planning, data=PopEst_08_cltr00 )

/*
%Upload_dat( lib=Planning, data=PopEst_2008_tr00 )
%Upload_dat( lib=Planning, data=PopEst_08_wd02 )

%Upload_dat( lib=Planning, data=PopEst_08_city )
*/
run;

endrsubmit;

signoff;

