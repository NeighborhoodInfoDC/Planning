/**************************************************************************
 Program:  Store_locations_2010.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  05/01/11
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create file with store locations obtained from DC
Office of Planning.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

%let DISTANCE_CUTOFF = 50;

data Planning.Store_locations_2010 (label="Store locations, DC, 2010");

  set Planning.storelocations_w_block;
  
  %Octo_GeoBlk2000()
  
  if distance > &DISTANCE_CUTOFF then GeoBlk2000 = '';
  
  length Geo2000 $ 11;
  
  Geo2000 = GeoBlk2000;

run;

%File_info( data=Planning.Store_locations_2010, freqvars=Type Geo2000 )

