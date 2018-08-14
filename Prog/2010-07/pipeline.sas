
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )


/*simple sum of joins*/
/*cluster*/
data pipeline_cltr;
set planning.clustertracts;
if objectid = "552" then cluster_cl="36";
if objectid = "663" then cluster_cl=".";
if objectid = "540" then cluster_cl="37";
if objectid = "1061" then cluster_cl=".";
keep objectid affunits units cluster_cl ;
run;

proc sort data=pipeline_cltr;
by objectid;
run;

proc means data=pipeline_cltr noprint;
class cluster_cl;
var affunits units; 
     output out=pipeline_cltr sum=;
run;

data planning.pipeline_cltr (label="Pipeline, 2009, DC, Neighborhood Cluster (2000)");
set pipeline_cltr;
if cluster_cl=" " then delete;
label 
    affunits = "Affordable Units, 2009"
	units = "Units, 2009"
    cluster_cl = "Neighborhood cluster";
	drop _type_ _freq_;
run;
	
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[Pipeline_09.xls]cluster!R2C1:R40C3" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.pipeline_cltr;
put cluster_cl '09'x units '09'x affunits '09'x ;
run;
filename xout clear;

/*ward*/
data pipeline_wd;
set planning.wards;
keep objectid affunits units ward_id;
if objectid = "879" then ward_id="5";
run;

proc sort data=pipeline_wd;
by objectid;
run;

proc means data=pipeline_wd noprint;
class ward_id;
var affunits units; 
     output out=pipeline_wd sum=;
run;

data planning.pipeline_wd (label="Pipeline, 2009, DC, Ward (2002)");
set pipeline_wd;
if ward_id=" " then delete;
label 
    affunits = "Affordable Units, 2009"
	units = "Units, 2009"
    ward_id = "Ward 2002";
	drop _type_ _freq_;
run;
	
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[Pipeline_09.xls]ward!R2C1:R9C3" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.pipeline_wd;
put ward_id '09'x units '09'x affunits '09'x ;
run;
filename xout clear;
