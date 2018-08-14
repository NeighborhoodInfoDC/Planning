
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

/*Macro vars*/
%let set= green;
%let var= building;
%let year= 2010;

/*Create Dataset with Site Variable*/
data &set._dc;
set planning.&set.;
&var._&year.=1;
run;

/*Cluster*/
proc sort data=&set._dc;
by cluster_tr2000;
run;

data &set._cltr00;
set &set._dc;
if &var._&year.=. then &var._&year.=0; 
keep cluster_tr2000 &var._&year.;
run;

proc means data=&set._cltr00 noprint;
class cluster_tr2000;
var &var._&year.; 
     output out=&set._cltr00 sum=;
run;

data planning.&set._cltr00 (label="&set., &year., DC, Neighborhood Cluster (2000)");
set &set._cltr00;
if cluster_tr2000=" " then delete;
label 
    
    cluster_tr2000 = "Neighborhood cluster (tract-based, 2000)";
	drop _type_ _freq_;
run;

/*Ward*/
proc sort data=&set._dc;
by ward2002;
run;
 
proc sort data=general.ward2002;
by ward2002;
run;

data &set._wd02;
merge  general.ward2002 &set._dc;
by ward2002;
if &var._&year.=. then &var._&year.=0; 
keep ward2002 &var._&year.;
run;

proc means data=&set._wd02 noprint;
class ward2002;
var &var._&year.; 
     output out=&set._wd02 sum=;
run;

data planning.&set._wd02 (label="&set., &year., DC, Ward (2002)");
set &set._wd02;
if ward2002=" " then delete;
label 
    
    ward2002 = "Ward (2002)";
	drop _type_ _freq_;
run;

/*City*/

data &set._city (compress=no);

  length city $ 1;

  retain city '1';

  set &set._dc;
  
  label city = "Washington, D.C.";
  
run;

proc summary data=&set._city;
  by city;
  var &var._&year. ;
  output 
    out=planning.&set._city 
      (label="&set., &year., DC, City total"
       sortedby=city
       drop=_type_ _freq_)
    sum= ;
run;





	

	
