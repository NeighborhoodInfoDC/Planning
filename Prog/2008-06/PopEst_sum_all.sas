/**************************************************************************
 Program:  PopEst_sum_all.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/29/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Create summary files for TAZ-based population
 estimates from OP/State Data Center.

 Ward & cluster summary levels only.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )


** City **;

data PopEst_2005_Taz00 (compress=no);

  length city $ 1;

  retain city '1';

  set Planning.PopEst_2005_Taz00;
  
  label city = "Washington, D.C.";
  
run;

proc summary data=PopEst_2005_Taz00;
  by city;
  var PopEst_: ;
  output 
    out=Planning.PopEst_2005_city 
      (label="Population estimates from OP/State Data Center, 2005, DC, City total"
       sortedby=city
       drop=_type_ _freq_)
    sum= ;
run;

%File_info( data=Planning.PopEst_2005_city )



** Wards **;

%Transform_geo_data(
    dat_ds_name=Planning.PopEst_2005_Taz00,
    dat_org_geo=taz2000,
    dat_count_vars=PopEst_:,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_taz00_ward02,
    wgt_org_geo=taz2000,
    wgt_new_geo=ward2002,
    wgt_id_vars=,
    wgt_wgt_var=popwt,
    out_ds_name=Planning.PopEst_2005_wd02,
    out_ds_label=%str(Population estimates from OP/State Data Center, 2005, DC, Ward (2002)),
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=N,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )


run;

%File_info( data=Planning.PopEst_2005_wd02 )


** Clusters **;

%Transform_geo_data(
    dat_ds_name=Planning.PopEst_2005_Taz00,
    dat_org_geo=taz2000,
    dat_count_vars=PopEst_:,
    dat_prop_vars=,
    wgt_ds_name=General.Wt_taz00_cltr00,
    wgt_org_geo=taz2000,
    wgt_new_geo=cluster_tr2000,
    wgt_id_vars=,
    wgt_wgt_var=popwt,
    out_ds_name=Planning.PopEst_2005_cltr00,
    out_ds_label=%str(Population estimates from OP/State Data Center, 2005, DC, Neighborhood cluster (tract-based, 2000)),
    calc_vars=,
    calc_vars_labels=,
    keep_nonmatch=N,
    show_warnings=10,
    print_diag=Y,
    full_diag=N
  )


run;

%File_info( data=Planning.PopEst_2005_cltr00 )

