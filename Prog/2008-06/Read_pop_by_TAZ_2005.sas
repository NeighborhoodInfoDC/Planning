/**************************************************************************
 Program:  Read_pop_by_TAZ_2005.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/26/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Read population estimated by Transportation Analysis
Zones (TAZ) provided by OP/State Data Center.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )

filename csvFile  "D:\DCData\Libraries\Planning\Raw\Pop by TAZ00-05.csv" lrecl=256;

data Planning.PopEst_2005_Taz00 (label="Population estimates from OP/State Data Center, 2005, DC, TAZ (2000)");

  length Taz2000 $ 3;
  
  retain Sum_PopEst_2000 Sum_PopEst_2005 City_PopEst_2000 City_PopEst_2005 0;

  infile csvFile dsd stopover firstobs=3 obs=322 end=eof;

  input Taz PopEst_2000 PopEst_2005;
  
  if _n_ = 1 then do;
    City_PopEst_2000 = PopEst_2000;
    City_PopEst_2005 = PopEst_2005;
  end;
  else do;
    Sum_PopEst_2000 = Sum_PopEst_2000 + PopEst_2000;
    Sum_PopEst_2005 = Sum_PopEst_2005 + PopEst_2005;
  end;
  
  if Taz > 0 then do;
    Taz2000 = put( Taz, z3. );
    output;
  end;
  
  if eof then do;
  
    if Sum_PopEst_2000 ~= City_PopEst_2000 then do;
      %Err_put( msg=Sum_PopEst_2000= City_PopEst_2000= )
    end;
    
    if Sum_PopEst_2005 ~= City_PopEst_2005 then do;
      %Err_put( msg=Sum_PopEst_2005= City_PopEst_2005= )
    end;
    
  end;
  
  label 
    PopEst_2000 = "Population estimate, 2000"
    PopEst_2005 = "Population estimate, 2005"
    Taz2000 = "Transportation analysis zone (TAZ, 2000)"
    Taz = "Transportation analysis zone [numeric] (TAZ, 2000)";
  
  drop sum_: city_: ;
  
run;

proc sort data=Planning.PopEst_2005_Taz00;
  by Taz2000;
run;

%File_info( data=Planning.PopEst_2005_Taz00, freqvars=Taz2000 )

