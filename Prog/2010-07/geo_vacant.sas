%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
%DCData_lib( Planning )
%DCData_lib( RealProp )


rsubmit;

** Upload data set to be geocoded (ADDRESSES) to Alpha WORK library **;
  
proc upload status=no
  data=work.vacant_geo 
  out=Work.vacant;

run;

** Geocode data set ADDRESSES and save results to ADDRESSES_GEO **;

%DC_geocode(
  data=Work.vacant ,
  out=Work.vacant_geo,
  staddr=ADDRESS
  )

run;

** Download geocoded data ADDRESSES_GEO to PC WORK library **;

proc download status=no
  data=Work.vacant_geo 
  out=planning.vacant_geo1;

run;

endrsubmit;

signoff;



