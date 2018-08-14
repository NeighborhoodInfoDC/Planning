%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;

%DCData_lib( RealProp )

data ownership;
set Realprop.Sales_res_clean;
saleyear = YEAR(saledate) ;
saleyear_prev = year(saledate_prev);
if (owner_occ_sale_prev =1) ;
if saleyear_prev="." then delete;
if saleyear_prev lt 1995 then delete;
length_own=saleyear-saleyear_prev;
keep cluster_tr2000 ui_proptype  saleyear saleyear_prev length_own;
run;

/*average length sf*/
data ownership_sf;
set ownership;
if ui_proptype=10;
run;

proc means data=ownership_sf noprint;
class Cluster_tr2000;
var length_own; 
     output out=ownership_sf mean=;
run;

data realprop.ownership_sf;
set ownership_sf;
if Cluster_tr2000 = " " then delete;
keep cluster_tr2000 length_own;
run;

/*average length condo*/
data ownership_condo;
set ownership;
if ui_proptype=11;
run;

proc sort data=ownership_condo;
by Cluster_tr2000;
run;
 
proc means data=ownership_condo noprint;
class Cluster_tr2000;
var length_own; 
     output out=ownership_condo mean=;
run;

data realprop.ownership_condo;
set ownership_condo;
if Cluster_tr2000 = " " then delete;
keep cluster_tr2000 length_own;
run;


