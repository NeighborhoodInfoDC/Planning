/**************************************************************************
 Program:  Pop_forecast_r9_dc_all.sas
 Library:  Planning
 Project:  Urban-Greater DC
 Author:   P. Tatian
 Created:  08/15/18
 Version:  SAS 9.4
 Environment:  Local Windows session (desktop)
 
 Description:  Create standard DC geo summary files for OP
population, household, and jobs forecasts from TAZ data.

 Modifications:
**************************************************************************/

%include "L:\SAS\Inc\StdLocal.sas";

** Define libraries **;
%DCData_lib( Planning )


/** Macro Summarize - Start Definition **/

%macro Summarize( geo );

  %local geosuf geodlbl;
  
  %if %sysfunc( putc( %upcase(&geo), $geoval. ) ) ~= %then %do;
    %let geosuf = %sysfunc( putc( %upcase(&geo), $geosuf. ) );
    %let geodlbl = %sysfunc( putc( %upcase(&geo), $geodlbl. ) );
  %end;
  %else %do;
    %err_mput( macro=GeoWt, msg=Invalid or missing value of geography (GEO=&geo). )
    %goto exit_macro;
  %end;

  %Transform_geo_data(
      dat_ds_name=Planning.Pop_forecast_r9_dc_taz10,
      dat_org_geo=Taz2010,
      dat_count_vars=emp: gq: hh: tpop:,
      dat_prop_vars=,
      wgt_ds_name=General.Wt_taz10&geosuf,
      wgt_org_geo=Taz2010,
      wgt_new_geo=&geo,
      wgt_id_vars=,
      wgt_wgt_var=Popwt,
      out_ds_name=Pop_forecast_r9_dc&geosuf,
      out_ds_label=,
      calc_vars=,
      calc_vars_labels=,
      keep_nonmatch=N,
      show_warnings=10,
      print_diag=Y,
      full_diag=N
    )

  %Finalize_data_set( 
    data=Pop_forecast_r9_dc&geosuf,
    out=Pop_forecast_r9_dc&geosuf,
    outlib=Planning,
    label="Population, household, and job forecasts, 2010-2045, DC, &geodlbl",
    sortby=&geo,
    revisions=%str(New file.),
    printobs=0
  )

  run;

  %exit_macro:

%mend Summarize;

/** End Macro Definition **/


%Summarize( anc2002 )
%Summarize( anc2012 )
%Summarize( bridgepk )
%Summarize( city )
%Summarize( cluster_tr2000 )
%Summarize( cluster2000 )
%Summarize( cluster2017 )
%Summarize( eor )
%Summarize( psa2004 )
%Summarize( psa2012 )
%Summarize( stantoncommons )
%Summarize( Geo2000 )
%Summarize( Geo2010 )
%Summarize( voterpre2012 )
%Summarize( ward2002 )
%Summarize( ward2012 )
%Summarize( zip )
