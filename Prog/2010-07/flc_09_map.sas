

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

%DCData_lib( Planning )

data planning.fcl_09;
set planning.DC_nbrhds_2010_7;
keep cluster_tr2000  forecl_1kpcl_sf_condo_2009;
if cluster_tr2000=" " then delete;
run;

 
 
