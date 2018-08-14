
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

data planning.totalpop08;
set planning.pop08 (rename=(y08pop=pop));
format tract $geo00a.;
keep tract pop;
run;


 %Transform_geo_data(
    dat_ds_name=planning.totalpop08,
    dat_org_geo=tract,
    dat_count_vars=pop,
    wgt_ds_name=General.Wt_tr00_cltr00,
    wgt_org_geo=Geo2000,
    wgt_new_geo=cluster_tr2000,
    wgt_wgt_var=PopWt,
    out_ds_name=planning.Pop_08)

	data planning.pop_00_05;
	set planning.popest_2005_cltr00;
	format cluster_tr2000 $clus00a.;
	run;

	data planning.pop00_05_08;
	merge planning.pop_00_05 planning.Pop_08;
	by Cluster_tr2000;
pctchg00_05=((popest_2005-popest_2000)/popest_2000)*100;
pctchg05_08=((pop-popest_2005)/popest_2005)*100;
run;
