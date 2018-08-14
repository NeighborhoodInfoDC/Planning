/**************************************************************************
 Program:  DCData\Requests\Prog\2010\0-5yearolds.sas
 Library:  DCData\Libraries\Requests
 Project:  NeighborhoodInfo DC
 Author:   Comey	
 Created:  08/31/10
 Version:  SAS 8.2
 Environment:  Windows with SAS/Connect
 
 Description:  Program to calculate number of 13-19 year olds by census tracts
 Documentation provided here: K:\Metro\PTatian\DCData\Libraries\Census\Doc\0Technical_Documentation.pdf in 
summary table section -- details pasted below

SEX BY AGE FOR THE POPULATION UNDER 20
YEARS [43]
Universe: Population under 20 years
Total: P014001 02 9
Male: P014002 02 9
Under 1 year P014003 02 9
1 year P014004 02 9
2 years P014005 02 9
3 years P014006 02 9
4 years P014007 02 9
5 years P014008 02 9
6 years P014009 02 9
7 years P014010 02 9
8 years P014011 02 9
9 years P014012 02 9
10 years P014013 02 9
11 years P014014 02 9
12 years P014015 02 9
13 years P014016 02 9
14 years P014017 02 9
15 years P014018 02 9
16 years P014019 02 9
17 years P014020 02 9
18 years P014021 02 9
19 years P014022 02 9
Female: P014023 02 9
Under 1 year P014024 02 9
1 year P014025 02 9
2 years P014026 02 9
3 years P014027 02 9
4 years P014028 02 9
5 years P014029 02 9
6 years P014030 02 9
7 years P014031 02 9
8 years P014032 02 9
9 years P014033 02 9
10 years P014034 02 9
11 years P014035 02 9
12 years P014036 02 9
13 years P014037 02 9
14 years P014038 02 9
15 years P014039 02 9
16 years P014040 02 9
17 years P014041 02 9
18 years P014042 02 9
19 years P014043 02 9

 Modifications:
**************************************************************************/

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( census )
rsubmit;

data age13_19 ;/* creates a file on the alpha - temp */
set census.Cen2000_sf1_dc_ph   (keep= geo2000 sumlev block p14i37 p14i38 p14i39 p14i40 p14i41 p14i42 p14i43
p14i16 p14i17 p14i18 p14i19 p14i20 p14i21 p14i22 pop100);
where sumlev="080"; /*census track only, not block*/

proc download inlib=work outlib=census; /* download to PC */
select age13_19 ; 

run;

endrsubmit; 

proc contents data=census.age13_19;
run;



**********Export table of total number of 0-5 year olds by census tract*******************;

*filename fexport "K:\Metro\SPopkin\Promise & Choice Neighborhoods\DCPN\Evaluation\RDWG\age0_5.csv" lrecl=2000;

*proc export data=census.age0_5
    outfile=fexport
    dbms=csv replace;

*run;

*filename fexport clear;
*run;

signoff;
