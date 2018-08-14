/**************************************************************************
 Program:  Pop_forecast_r9_dc_taz10.sas
 Library:  Planning
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  08/14/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create data set DC OP round 9 population, household,
and employment forecasts by TAZ. 

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Planning )

filename fimport "L:\Libraries\Planning\Maps\TAZ shape\DC_Final_Round_9_Forecast_TAZ.csv" lrecl=2000;

proc import out=Pop_forecast_r9_dc_taz10_in
    datafile=fimport
    dbms=csv replace;
  datarow=2;
  getnames=yes;
  guessingrows=max;
run;

filename fimport clear;

data Pop_forecast_r9_dc_taz10;

  set Pop_forecast_r9_dc_taz10_in;
  
  length Taz2010 $ 8;
  
  Taz2010 = put( fipsstco, z5. ) || put( taz, z3. );
  
  format _all_ ;
  informat _all_ ;
  
  label
    ACRES = "TAZ area in acres"
    CNTY_FIPS = "County FIPS code"
    EMP2010 = "Employed persons, 2010"
    EMP2015 = "Employed persons, 2015"
    EMP2020 = "Employed persons, 2020"
    EMP2025 = "Employed persons, 2025"
    EMP2030 = "Employed persons, 2030"
    EMP2035 = "Employed persons, 2035"
    EMP2040 = "Employed persons, 2040"
    EMP2045 = "Employed persons, 2045"
    FIPSSTCO = "State + county FIPS codes"
    GQ2010 = "Group quarters population, 2010"
    GQ2015 = "Group quarters population, 2015"
    GQ2020 = "Group quarters population, 2020"
    GQ2025 = "Group quarters population, 2025"
    GQ2030 = "Group quarters population, 2030"
    GQ2035 = "Group quarters population, 2035"
    GQ2040 = "Group quarters population, 2040"
    GQ2045 = "Group quarters population, 2045"
    HH2010 = "Households, 2010"
    HH2015 = "Households, 2015"
    HH2020 = "Households, 2020"
    HH2025 = "Households, 2025"
    HH2030 = "Households, 2030"
    HH2035 = "Households, 2035"
    HH2040 = "Households, 2040"
    HH2045 = "Households, 2045"
    HHPOP2010 = "Population in households, 2010"
    HHPOP2015 = "Population in households, 2015"
    HHPOP2020 = "Population in households, 2020"
    HHPOP2025 = "Population in households, 2025"
    HHPOP2030 = "Population in households, 2030"
    HHPOP2035 = "Population in households, 2035"
    HHPOP2040 = "Population in households, 2040"
    HHPOP2045 = "Population in households, 2045"
    JUR
    NAME
    OBJECTID
    OBJECTID_1
    REGION
    SQMI
    STATE_FIPS
    STATE_NAME
    Shape_Area
    Shape_Le_1
    Shape_Leng
    TAZ = "Traffic analysis zone (2010)"
    TAZ_1
    TPOP2010 = "Total population, 2010"
    TPOP2015 = "Total population, 2015"
    TPOP2020 = "Total population, 2020"
    TPOP2025 = "Total population, 2025"
    TPOP2030 = "Total population, 2030"
    TPOP2035 = "Total population, 2035"
    TPOP2040 = "Total population, 2040"
    TPOP2045 = "Total population, 2045"

    Taz2010 = "Traffic analysis zone (2010): ssccczzz";
  
  drop 
    
    emp10_15 emp10_15p gq10_15 gq10_15p hh10_15 hh10_15pct hpop10_15 hpop10_15p tpop10_15 tpop10_15p;

run;

%File_info( data=Pop_forecast_r9_dc_taz10, printobs=5 )

run;
