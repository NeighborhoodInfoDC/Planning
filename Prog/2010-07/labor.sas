%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

data planning.labor_cltr00(label="Labor, Dec 2009, DC, Cluster (2000)");
set planning.grocery_cltr00;
pct_unemp_2009=.;
labor_force_2009=.;
drop store_2010;
run;

data labor;
merge planning.labor general.ward2002;
by ward_label;
run;

data labor_wd02;
set labor (rename=(labor_force=labor_force_2009 pct_unemp=pct_unemp_2009));
keep ward2002 labor_force_2009 no_unemp pct_unemp_2009;
run;

proc summary data=labor_wd02;
class ward2002 /preloadfmt order=data;
format ward2002$WARD02A6.;
var labor_force_2009 no_unemp pct_unemp_2009;
  output 
    out=labor_wd02
    sum= ;
run;

data planning.labor_wd02 (label="Labor, Dec 2009, DC, Ward (2002)");
set labor_wd02;
if ward2002=" " then delete;
label 
    labor_force_2009 = "Labor Force, Dec 2009"
	pct_unemp_2009 ="Unemployment Rate, Dec 2009"
    ward2002 = "Ward (2002)";
drop no_unemp _type_ _freq_ ;
run;

/*City*/
data labor_city (compress=no);

  length city $ 1;

  retain city '1';

  set labor_wd02;
  
  label city = "Washington, D.C.";
  
run;

proc summary data=labor_city;
  by city;
  var labor_force_2009 no_unemp;
  output 
    out=labor_city 
      (label="Labor, Dec 2009, DC, City total"
       sortedby=city
       drop=_type_ _freq_)
    sum= ;
run;

data planning.labor_city;
set labor_city;
pct_unemp_2009=(no_unemp/labor_force_2009)*100;
drop no_unemp;
run;
