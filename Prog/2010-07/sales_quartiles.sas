%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;

%DCData_lib( RealProp )

data sales;
set Realprop.Sales_res_clean;
saleyear = YEAR(saledate) ;
if saleyear=2009;
keep cluster_tr2000 ui_proptype saleprice saleyear;
run;

/*percentile price sf*/
data sales_sf;
set sales;
if ui_proptype=10;
run;

proc means data=sales_sf noprint;
class Cluster_tr2000;
var saleprice; 
     output out=sales_sf_med median=;
run;

data sales_sf_med;
set sales_sf_med;
if Cluster_tr2000 = " " then delete;
saleprice_med=saleprice;
keep cluster_tr2000 saleprice_med;
run;

proc means data=sales_sf noprint;
class Cluster_tr2000;
var saleprice; 
     output out=sales_sf_q1 q1=;
run;

data sales_sf_q1;
set sales_sf_q1;
if Cluster_tr2000 = " " then delete;
saleprice_q1=saleprice;
keep cluster_tr2000 saleprice_q1;
run;

proc means data=sales_sf noprint;
class Cluster_tr2000;
var saleprice; 
     output out=sales_sf_q3 q3=;
run;

data sales_sf_q3;
set sales_sf_q3;
if Cluster_tr2000 = " " then delete;
saleprice_q3=saleprice;
keep cluster_tr2000 saleprice_q3;
run;

data realprop.sales_sf_quartiles;
merge sales_sf_med sales_sf_q1 sales_sf_q3;
by cluster_tr2000;
run;

/*percentile condo*/
data sales_condo;
set sales;
if ui_proptype=11;
run;
proc means data=sales_condo noprint;
class Cluster_tr2000;
var saleprice; 
     output out=sales_condo_med median=;
run;

data sales_condo_med;
set sales_condo_med;
if Cluster_tr2000 = " " then delete;
saleprice_med=saleprice;
keep cluster_tr2000 saleprice_med;
run;

proc means data=sales_condo noprint;
class Cluster_tr2000;
var saleprice; 
     output out=sales_condo_q1 q1=;
run;

data sales_condo_q1;
set sales_condo_q1;
if Cluster_tr2000 = " " then delete;
saleprice_q1=saleprice;
keep cluster_tr2000 saleprice_q1;
run;

proc means data=sales_condo noprint;
class Cluster_tr2000;
var saleprice; 
     output out=sales_condo_q3 q3=;
run;

data sales_condo_q3;
set sales_condo_q3;
if Cluster_tr2000 = " " then delete;
saleprice_q3=saleprice;
keep cluster_tr2000 saleprice_q3;
run;

data realprop.sales_condo_quartiles;
merge sales_condo_med sales_condo_q1 sales_condo_q3;
by cluster_tr2000;
run;
