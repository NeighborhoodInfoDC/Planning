
%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

data Planning.PopEst_2008_Tr00 (label="Population estimates from OP/Caliper, 2008, DC, Tract (2000)");
length tract $11;
set planning.pop08 (rename=(y08pop=PopEst_2008));
format tract $geo00a.;
keep tract PopEst_2008;
label 
    PopEst_2008 = "Population estimate, 2008"
    tract = "Census Tract 2000";
run;

proc sort data=Planning.PopEst_2008_Tr00;
by tract;
run;

proc summary data=Planning.PopEst_2008_Tr00;
by tract;
var PopEst_2008;
output out=Planning.PopEst_2008_Tr00 sum=;
run;


/*Aggregate at Cluster level*/

%Transform_geo_data(
    dat_ds_name=Planning.PopEst_2008_Tr00,
    dat_org_geo=tract,
    dat_count_vars=popest_2008,
    wgt_ds_name=General.Wt_tr00_cltr00,
    wgt_org_geo=Geo2000,
    wgt_new_geo=cluster_tr2000,
    wgt_wgt_var=PopWt,
    out_ds_name=Planning.PopEst_08_cltr00);

/*Aggregate at Ward level*/

%Transform_geo_data(
    dat_ds_name=Planning.PopEst_2008_Tr00,
    dat_org_geo=tract,
    dat_count_vars=popest_2008,
    wgt_ds_name=General.wt_tr00_ward02,
    wgt_org_geo=Geo2000,
    wgt_new_geo=ward2002,
    wgt_wgt_var=PopWt,
    out_ds_name=Planning.PopEst_08_wd02);

/*Aggregate at City Level*/

data PopEst_2008_Tr00 (compress=no);

  length city $ 1;

  retain city '1';

  set Planning.PopEst_2008_Tr00;
  
  label city = "Washington, D.C.";
  
run;

proc summary data=PopEst_2008_Tr00;
  by city;
  var popest_2008 ;
  output 
    out=Planning.PopEst_08_city 
      (label="Population estimates from OP/State Data Center, 2008, DC, City total"
       sortedby=city
       drop=_type_ _freq_)
    sum= ;
run;





	

	
