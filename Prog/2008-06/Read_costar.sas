/**************************************************************************
 Program:  Read_costar.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/01/08
 Version:  SAS 9.1
 Environment:  Windows with SAS/Connect
 
 Description:  Read CoStar data from WDCEP.

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;
***%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( RealProp )

%global MAXROWS file_list;

%let MAXROWS = 5000;
%let file_list = ;

*options obs=10;

/** Macro Read_sheet - Start Definition **/

%macro Read_sheet( sheet );

  %let file_list = &file_list &sheet;

  filename xlsFile dde "excel|&_dcdata_path\Planning\Raw\DCEP\[CoStar.xls]&sheet.!r2c1:R&MAXROWS.C45" lrecl=1000 notab;
  *filename csvFile  "&_dcdata_path\Planning\Raw\DCEP\CapitolHill_Office.csv" lrecl=1000;

  data &sheet (compress=no);

    ***infile csvFile dsd stopover firstobs=2;
    infile xlsFile missover dsd dlm='09'x;

    input
      BuildingAddress : $40.
      BuildingName : $80.
      BuildingPark : $80.
      PropertyType : $30.
      BuildingStatus : $16.
      BuildingClass : $1.
      SubmarketCluster : $40.
      SubmarketName : $40.
      CityName : $20.
      State : $2.
      Zip : $5.
      CountyName : $40.
      YearBuilt 
      NumberOfStories
      YearRenovated
      NumberOfParkingSpaces
      ParkingRatio
      LandAreaAC
      RentableBuildingArea
      TypicalFloorSize
      MaxBuildingContiguousSpace
      MaxFloorContiguousSpace
      TotalAvailableSpaceSF
      DirectAvailableSpace
      DirectVacantSpace
      SubletAvailableSpace
      SubletVacantSpace
      PercentLeased
      xAverageWeightedRent : $20.
      BuildingTaxExpenses : $40.
      BuildingOperatingExpenses : $40.
      SubletServices : $20.
      DirectServices : $20.
      PropertyManagerName : $80.
      DeveloperName : $80.
      LeasingCompanyName : $80.
      LeasingCompanyAddress : $80.
      LeasingCompanyCityStateZip : $80.
      LeasingCompanyPhone : $10.
      LeasingCompanyFax : $10.
      LeasingCompanyContact : $40.
      OwnerName : $80.
      ArchitectName : $80.
      Amenities : $200.
      Serial : $6.
    ;
    
    if BuildingAddress = '' then delete;
    
    if xAverageWeightedRent = '-' then AverageWeightedRent = .u;
    else if upcase( xAverageWeightedRent ) = 'NEGOTIABLE' then AverageWeightedRent = .n;
    else AverageWeightedRent = input( xAverageWeightedRent, 20.2 );
    
    drop xAverageWeightedRent;

  run;

  filename xlsFile clear;

  /*
  %File_info( 
    data=&sheet, 
    printobs=5,
    freqvars= 
      BuildingClass BuildingPark BuildingStatus CityName CountyName
      DirectServices NumberOfParkingSpaces NumberOfStories
      PropertyType State SubmarketCluster SubmarketName YearBuilt
      YearRenovated Zip
  )
  */

%mend Read_sheet;

/** End Macro Definition **/


** Read individual worksheets **;

%Read_sheet( CapitolHill_Office )
%Read_sheet( CBD_Office )
%Read_sheet( EastEnd_Office )
%Read_sheet( Gtown_Office )
%Read_sheet( NE_Office )
%Read_sheet( NoMa_Office )
%Read_sheet( SE_Office )
%Read_sheet( SW_Office )
%Read_sheet( Uptown_Office )
%Read_sheet( WestEnd_Office )


** Combine data together **;

data CoStar_nogeo;

  set &file_list;
  
  length city $ 1;
  
  retain city '1';
  
  ** Correct addresses **;
  
  select ( BuildingAddress );
    when ( '1601 NW Massachusetts Ave' ) BuildingAddress = '1601 Massachusetts Ave NW';
    when ( '1749-1751 St. Matthew''s Ct NW' ) BuildingAddress = '1749 St. Matthews Ct NW';
    when ( '1063 NW Thomas Jefferson St' ) BuildingAddress = '1063 Thomas Jefferson St NW';
    when ( '2804-2806 Douglas St N' ) BuildingAddress = '2804 DOUGLAS STREET NE';
    when ( '501 NE Capitol Ct' ) BuildingAddress = '501 Capitol Ct NE';
    when ( '1533 Pennsylvania Ave S' ) BuildingAddress = '1533 PENNSYLVANIA AVENUE SE';
    when ( '2404 NW Wisconsin Ave' ) BuildingAddress = '2404 Wisconsin Ave NW';
    when ( '105 1/2 2nd St' ) BuildingAddress = '105 2nd St NE';
    when ( '413 East Capitol St' ) BuildingAddress = '413 EAST CAPITOL STREET SE';
    when ( '1900 E St' ) BuildingAddress = '1900 E St NW';
   otherwise /** DO NOTHING **/;
  end;
  
run;

** Start submitting commands to remote server **;

rsubmit;

proc upload status=no
  inlib=work 
  outlib=work memtype=(data);
  select Costar_nogeo;
run;

%DC_geocode(
  geo_match=Y,
  data=CoStar_nogeo,
  out=CoStar_2008,
  staddr=BuildingAddress,
  zip=Zip,
  id=Serial,
  ds_label="WDCEP CoStar database, DC, 2008",
  listunmatched=Y
)

data CoStar_2008;

  set CoStar_2008;
  
  select ( BuildingAddress );
    when ( '470-490 L''Enfant Plz SW' ) do;
      ward2002 = '2';
      cluster_tr2000 = '09';
    end;
    when ( '950 L''Enfant Plz SW' ) do;
      ward2002 = '2';
      cluster_tr2000 = '09';
    end;
    when ( '955 L''Enfant Plz SW' ) do;
      ward2002 = '2';
      cluster_tr2000 = '09';
    end;
    when ( '3288 Rear St NW' ) do;
      ward2002 = '2';
      cluster_tr2000 = '04';
    end;    
    otherwise /** DO NOTHING **/;
  end;

run;

proc download status=no
  inlib=work 
  outlib=Planning memtype=(data);
  select CoStar_2008;
run;

endrsubmit;

** End submitting commands to remote server **;

%File_info( 
  data=Planning.CoStar_2008,
  printobs=0,
  freqvars= 
    city ward2002 cluster_tr2000
    BuildingClass BuildingPark BuildingStatus City CountyName
    DirectServices NumberOfStories
    PropertyType State SubmarketCluster SubmarketName YearBuilt
    YearRenovated Zip
)

signoff;

