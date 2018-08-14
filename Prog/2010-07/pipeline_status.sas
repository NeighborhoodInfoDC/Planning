
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

/*cluster*/
data pipeline_cltr;
set planning.clustertracts;
if objectid = "552" then cluster_cl="36";
if objectid = "663" then cluster_cl=".";
if objectid = "540" then cluster_cl="37";
if objectid = "1061" then cluster_cl=".";
keep objectid affunits units cluster_cl statusID;
run;

proc sort data=pipeline_cltr;
by objectid;
run;

proc means data=pipeline_cltr noprint;
class cluster_cl statusID;
var affunits units; 
     output out=pipeline_cltr sum=;
run;

data planning.pipeline_cltr (label="Pipeline, 2009, DC, Neighborhood Cluster (2000)");
set pipeline_cltr;
if cluster_cl=" " then delete;
if statusID= " " then delete;
label 
    affunits = "Affordable Units, 2009"
	units = "Units, 2009"
    cluster_cl = "Neighborhood cluster"
	statusID = "Development Status";
	drop _type_ _freq_;
run;
	
/*ward*/
data pipeline_wd;
set planning.wards;
keep objectid affunits units ward_id statusid;
if objectid = "879" then ward_id="5";
run;

proc sort data=pipeline_wd;
by objectid;
run;

proc means data=pipeline_wd noprint;
class ward_id statusid;
var affunits units; 
     output out=pipeline_wd sum=;
run;

data planning.pipeline_wd (label="Pipeline, 2009, DC, Ward (2002)");
set pipeline_wd;
if ward_id=" " then delete;
if statusid= " " then delete;
label 
    affunits = "Affordable Units, 2009"
	units = "Units, 2009"
    ward_id = "Ward 2002"
    statusID = "Development Status";;
	drop _type_ _freq_;
run;
	

