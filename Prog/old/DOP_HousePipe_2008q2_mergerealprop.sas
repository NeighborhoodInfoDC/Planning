/**************************************************************************
 Program:  DOP_HousePipe_2008q2.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC/School Assignment Policies
 Author:   Jcomey
 Created:  9/18/2008
 Updated:  
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description: Assigning neighborhood clusters to Department of Planning's geocoded Housing Pipeline file. 

 Modifications:
Notes: 


**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( General );
%DCData_lib( Planning );


rsubmit;

data ACS_2006_fam ;/* creates a file on the alpha - temp */
set Ipums.Acs_2006_fam_pmsa99 (keep= serial persons_hh related_pers	unrelated_pers statefip	hhwt) 
	 ;
proc download inlib=work outlib=Ipums; /* download to PC */
select ACS_2006_fam ;  

run;

endrsubmit; 

*Pull down parcel level file with geographies*/;
rsubmit;


data parcel_geo ;/* creates a file on the alpha - temp */
set Realprop.Parcel_geo
	;
proc download inlib=work outlib=realprop; /* download to PC */
select parcel_geo ; 

run;

endrsubmit; 

proc sort data=realprop.Parcel_geo ;
by ssl  ;run;


proc sort data=planning.daexpply2008q2_HousPipe;
by cluster_tr2000 ;run;

data HousPipe_2008;
	set planning.daexpply2008q2_HousPipe;

run;

rsubmit;

        proc upload     status = no  

            inlib = Work 

            outlib = Work

            memtype = (data);

			***Insert file name;
            select HousPipe_2008;

        run; 
**Commented out because doesn't work -- Dave D working on;
      *%corrections (

            infile = Students, 

            correctfile = [dcdata2.realprop.prog]dc_schools_recode.txt, 

            outfile = students_clean, 

            repl_var = stu_street);

 
*Data statement is the file I'm uploading to the Alpha, and out statement is the final geocoded version
	Plus, you need to fill in the accurate field names for street, zip;

      %DC_geocode(

            data=Work.HousPipe_2008, 

            out=Work.HousPipe_2008_geocode, 

            staddr=street_address, 

            zip = zip, 

            id = id,

 
/*keep parcel file all the same -- geocoding itself*/
/*           parcelfile = realprop.parcel_geocode_base_new, [We used to include this code, no longer]*/

            unit_match=Y,

            geo_match=Y,

            block_match=Y,

            listunmatched=Y,

            debug=N);

      run;

*select the final geocoded file down from the Alpha;
      proc download status = no  

            inlib=work 

            outlib=Requests 

            memtype=(data);

            select  HousPipe_2008_geocode;

      run;

  endrsubmit;

 
**********Export geocoded file*******************;

filename fexport "K:\Metro\PTatian\DCData\Libraries\Planning\Raw\HousPipe_2008_geocode.csv" lrecl=2000;

proc export data=planning.HousPipe_2008_geocode
    outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;

signoff;



