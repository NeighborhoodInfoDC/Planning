
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

data planning.trees1;
set planning.trees;
if TBOX_STAT="Plant";
if Year(MODIFIEDDT) gt 05;
run;

/*Create Dataset with Site Variable*/
data trees_dc;
set planning.trees1;
trees_2010=1;
if condition="Good" or condition="Excellent" then tree_hlth_2010=1;
else tree_hlth_2010=0;
run;

/*Cluster*/
proc sort data=trees_dc;
by cluster_tr2000;
run;

data trees_cltr00;
set trees_dc;
if cluster_tr2000="" then delete;
keep cluster_tr2000 trees_2010 tree_hlth_2010 ;
run;

proc means data=trees_cltr00 noprint;
class cluster_tr2000;
var trees_2010 tree_hlth_2010; 
     output out=trees_cltr00 sum=;
run;

data planning.trees_cltr00 (label="Trees, 2010, DC, Neighborhood Cluster (2000)");
set trees_cltr00;
if cluster_tr2000="" then delete;
label 
    cluster_tr2000 = "Neighborhood cluster (tract-based, 2000)";
	drop _type_ _freq_;
run;

/*Ward*/
proc sort data=trees_dc;
by ward2002;
run;
 
proc sort data=general.ward2002;
by ward2002;
run;

data trees_wd02;
merge  general.ward2002 trees_dc;
by ward2002;
if ward2002="" then delete;
keep ward2002 trees_2010 tree_hlth_2010;
run;

proc means data=trees_wd02 noprint;
class ward2002;
var trees_2010 tree_hlth_2010; 
     output out=trees_wd02 sum=;
run;

data planning.trees_wd02 (label="trees, 2010, DC, Ward (2002)");
set trees_wd02;
if ward2002=" " then delete;
label 
    
    ward2002 = "Ward (2002)";
	drop _type_ _freq_;
run;

/*City*/

data trees_city (compress=no);

  length city $ 1;

  retain city '1';

  set trees_dc;
  
  label city = "Washington, D.C.";
  
run;

proc summary data=trees_city;
  by city;
  var trees_2010 tree_hlth_2010 ;
  output 
    out=planning.trees_city 
      (label="trees, 2010, DC, City total"
       sortedby=city
       drop=_type_ _freq_)
    sum= ;
run;





	

	
