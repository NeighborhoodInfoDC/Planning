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
Notes: Macro doesn't work at all because zipcodes are missing from DOP file.


**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( General );
%DCData_lib( Requests );
%DCData_lib( Planning );


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

            outlib=planning 

            memtype=(data);

            select  HousPipe_2008_geocode;

      run;

  endrsubmit;

 

signoff;



