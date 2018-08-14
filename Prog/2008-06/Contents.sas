/**************************************************************************
 Program:  Contents.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/26/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Police )

%File_info( data=Police.juvenile_arrests_2006, freqvars=WARD NEIGHBORHOODCLUSTER )


run;
