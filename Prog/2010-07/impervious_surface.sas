
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

/*cluster*/
proc means data=planning.impsrf_cluster noprint;
class name;
var interarea;
output out= impsrf_cluster sum=;
run;

proc sort data=impsrf_cluster;
by name;
run;

proc sort data=planning.nbhclusply_full;
by name;
run;

data planning.impsrf_cluster2000;
merge planning.nbhclusply_full impsrf_cluster;
by name;
pct_impsrf=(interarea/totalarea)*100;
if name="" then delete;
keep name pct_impsrf;
run;

/*ward*/
proc means data=planning.impsrf_ward noprint;
class name;
var interarea;
output out= impsrf_ward sum=;
run;

proc sort data=impsrf_ward;
by name;
run;

proc sort data=planning.ward02ply;
by name;
run;

data planning.impsrf_ward2002;
merge planning.ward02ply impsrf_ward;
by name;
pct_impsrf=(interarea/totalarea)*100;
if name="" then delete;
keep name pct_impsrf;
run;

/*city*/
data impsrf_city;
merge planning.nbhclusply_full impsrf_cluster;
by name;
if name="" then delete;
keep name totalarea interarea;
run;

data impsrf_city (compress=no);

  length city $ 1;

  retain city '1';

  set impsrf_city;
  
  label city = "Washington, D.C.";
  
run;

proc summary data=impsrf_city;
  by city;
  var totalarea interarea;
  output 
    out=impsrf_city 
      (label="Impervious Surface, 2008, DC, City total"
       sortedby=city
       drop=_type_ _freq_)
    sum= ;
run;

data planning.impsrf_city;
set impsrf_city;
pct_impsrf=(interarea/totalarea)*100;
keep city pct_impsrf;
run;


	

	
