/**************************************************************************
 Program:  Green_roofs.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  07/30/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Geocode file containing locations of green roofs.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( OCTO )
%DCData_lib( RealProp )

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  data=Octo.greenroofpt 
  out=greenroofpt;
run;

%DC_geocode(
  geo_match=Y,
  data=greenroofpt,
  out=greenroofpt_geo,
  staddr=address,
  zip=,
  id=,
  ds_label=,
  listunmatched=Y
)

** Add city code, replace ward2002 with cluster-based version **;

proc sort data=greenroofpt_geo;
  by cluster_tr2000;

data greenroofpt_geo;

  length city $ 1;
  retain city '1';
  
  merge 
    greenroofpt_geo 
      (drop=comment
       rename=(ward2002=x_ward2002)
       in=in1)
    General.Cluster2000 
      (keep=cluster2000 ward2002
       rename=(cluster2000=cluster_tr2000));
  by cluster_tr2000;
  
  if in1;
  
  if missing( ward2002 ) then ward2002 = x_ward2002;
  
  drop x_ward2002;
    
run;

proc sort data=greenroofpt_geo;
  by ui_proptype;

proc print data=greenroofpt_geo n='N=';
  by ui_proptype;
  id address_std;
  var ward2002 cluster_tr2000;
run;

proc freq data=greenroofpt_geo;
  tables ui_proptype;
run;

** Summarize counts for wards, cluster, city **;

proc summary data=greenroofpt_geo nway;
  class ward2002;
  output out=Planning.Green_roofs_wd02 (rename=(_freq_=Green_roofs_2007) drop=_type_);
run;

proc print;
run;

proc summary data=greenroofpt_geo nway;
  class cluster_tr2000;
  output out=Planning.Green_roofs_cltr00 (rename=(_freq_=Green_roofs_2007) drop=_type_);
run;

proc print;
run;

proc summary data=greenroofpt_geo nway;
  class city;
  output out=Planning.Green_roofs_city (rename=(_freq_=Green_roofs_2007) drop=_type_);
run;

proc print;
run;

endrsubmit;

** End submitting commands to remote server **;

run;

signoff;
