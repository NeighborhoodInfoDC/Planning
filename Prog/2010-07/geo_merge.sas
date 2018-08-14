%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";

libname inlib "D:\DCData\Libraries\Planning\Data";

%let keep = cluster2000 zip psa2004 anc2002 cjrTractBl ward2002 x_coord y_coord affunits units ;
%let map_prefix = Parcel_join_;
%let xfer_files = ;
%let unq_id = fid_1; 

/** Macro Xfer - Start Definition **/

%macro Xfer ( inds=, var=, keep= );

  %let xfer_files = &xfer_files &inds;

  data &inds;

    set inlib.&map_prefix.&inds;

    %Octo_&var( )

    format _all_;
    informat _all_;

    keep &unq_id. &var &keep ;

  run;

  proc sort data=&inds;
  by &unq_id.;
  run;

%mend Xfer;

/** End Macro Definition **/


** Creating standard variables for **;

%Xfer( inds=block, var=GeoBlk2000, keep=CJRTRACTBL x_coord y_coord )

%Xfer( inds=ward02, var=ward2002 )

%Xfer( inds=polsa, var=psa2004 )

%Xfer( inds=anc02, var=anc2002 )

%Xfer( inds=zip, var=zip  )

%Xfer( inds=nbhclus, var=cluster2000 )


** Merge files together, create remaining geographic IDs **;

data inlib.green;

  length CJRTRACTBL $ 12;

  merge &xfer_files;
  by &unq_id.;

  ** Census tract **;

  length Geo2000 $ 11;

  Geo2000 = GeoBlk2000;

  label
  Geo2000 = "Full census tract ID (2000): ssccctttttt";

  ** Tract-based neighborhood clusters **;

  %Block00_to_cluster_tr00()

  ** Casey target area neighborhoods **;

  %Tr00_to_cta03()
  %Tr00_to_cnb03()

  ** East of the river **;

  %Tr00_to_eor()

  ** City **;

  length City $ 1;

  city = "1";

  label city = "Washington, D.C.";

  format geo2000 $geo00a. anc2002 $anc02a. psa2004 $psa04a. 
         ward2002 $ward02a. zip $zipa. cluster2000 $clus00a. 
         city $city.;

  label
    CJRTRACTBL = "OCTO tract/block ID"
    Ssl = "Property Identification Number (Square/Suffix/Lot)"
  ;

run;



