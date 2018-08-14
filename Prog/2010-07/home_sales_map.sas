

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

%DCData_lib( Planning )

data planning.hinc_mrtg_05_08;
set planning.DC_nbrhds_2010_7;
%Pct_calc( var=PctMrtgOrig_hinc, num=NumMrtgOrig_hinc, den=NumMrtgOrig_inc, from=1997, to=2008, year_only_lbl=Y );
pct_chg_05_08 = PctMrtgOrig_hinc_2008-PctMrtgOrig_hinc_2005;
keep cluster_tr2000 pct_chg_05_08;
if cluster_tr2000=" " then delete;
run;

 
 
