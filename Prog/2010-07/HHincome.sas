/**************************************************************************
 Program:  HHincome.sas
 Library:  OP Programs
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  06/01/10
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  HHincome

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Ipums )

filename uiautos "K:\Metro\PTatian\UISUG\Uiautos";
options sasautos=(uiautos sasautos);

%let keep_vars = year serial pernum hhwt upuma hhincome;

data HHincome;

  set
    Ipums.Ipums_2000_dc (keep=&keep_vars)
    Ipums.Acs_2008_dc (keep=&keep_vars);
  by serial;

  where pernum = 1;

if hhincome=999999 then delete;
else if hhincome lt 0 then delete;


  ** Convert 2000 income to 2008 dollars **;

  if year = 0 then do;
    %Dollar_convert( hhincome, hhincome_adj, 1999, 2008 )
  end;
    
else do;
    hhincome_adj = hhincome;
  end;

  label hhincome_adj = "HH income adjusted to 2008 $";

if hhincome_adj < 10000 then IncCat=1;
else if 10000 <= hhincome_adj <=14999 then IncCat=2;
else if 15000 <= hhincome_adj <=24999 then IncCat=3;
else if 25000 <= hhincome_adj <=34999 then IncCat=4;
else if 35000 <= hhincome_adj <=49999 then IncCat=5;
else if 50000 <= hhincome_adj <=74999 then IncCat=6;
else if 75000 <= hhincome_adj <=99999 then IncCat=7;
else if 100000 <= hhincome_adj <=149999 then IncCat=8;
else if 150000 <= hhincome_adj <=199999 then IncCat=9;
else if hhincome_adj >= 200000  then IncCat=10;
obs=1;
run;


proc means data=hhincome noprint;
class year IncCat;
var obs/ weight=hhwt; 
     output out=hhincome_inccat sum=;
run;

data planning.hhincome_dist_v2;
set hhincome_inccat;
if year = . then delete;
drop _type_;
run;

filename xout dde  "Excel|D:\DCData\Libraries\Planning\Prog\2010-07\[hhincome_v2.xls]Sheet2!R2C1:R23C4" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.hhincome_dist_v2;
put  year '09'x inccat '09'x _freq_ '09'x obs '09'x;
run;
filename xout clear;
