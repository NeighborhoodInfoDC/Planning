

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

%DCData_lib( Planning )

data planning.sf_price_05_09;
set planning.DC_nbrhds_2010_7;
pct_chg_05_09 = ((r_mprice_sf_2009-r_mprice_sf_2005)/r_mprice_sf_2005)*100;
keep cluster_tr2000 pct_chg_05_09 r_mprice_sf_2009;
if cluster_tr2000=" " then delete;
run;

 
 
