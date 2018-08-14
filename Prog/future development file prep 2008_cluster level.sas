*************************************************************************
** program name: future development file prep_cluster level.sas 
** following program name:
** project name: SEO
** Description: This program cleans a DC Office of Planning file on future
	development in DC to be used with student data and create projections of
	future student populations at the neighborhood cluster level
** Date Created: 4/18/2006  M. Woolley
** Date updated: 9/14/2007  for SEO project
** Date updated: 9/18/09 for School Assignment Policy work, JC. NOTE: Merged on cluster_tr00 in ArcMap from Art Rogers
shape files.
*************************************************************************;

%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
*%include "K:\Metro\PTatian\DCData\SAS\Inc\AlphaSignon.sas" /nosource2;

** Define libraries **;
%DCData_lib( RealProp );
%DCData_lib( General );
%DCData_lib( Planning );


*load file with unique id macro (%testdup (filename, id);
*%include "D:\crosswalk\testdup.sas";
** load formats;
*%include "K:\metro\maturner\hnc2007\programs\programs2006\programs\hncformats06.sas";

*options mprint nocenter;

proc contents data=planning.Houspipe2008q2_clust_spatjoin;
title "Full Housing Pipeline Data";
run;

*Definitions
*Lable UNITS=Number of residential units included in project;

* formats for DCOP file (STATUSID);
proc format ;
value status 
1	='Completed'
2	='Under Construction'
3	='Planned'
4	='Conceptual '
9	='New Neighborhood';
run;


proc freq data=planning.Houspipe2008q2_clust_spatjoin;
table landuse;
title "Type of projects";
run;
*Total of 561 developments falling in below categories;
proc freq data=planning.Houspipe2008q2_clust_spatjoin ;
	table landuse;
	title "Landuse for full file";
run;

proc freq data=planning.Houspipe2008q2_clust_spatjoin ;
	table tenure;
	title "Tenure for full file";
run;

proc freq data=planning.Houspipe2008q2_clust_spatjoin (where=(landuse in ('Mixed Use' 'Residential' 'Single Family Resident' 'Multi-Family Residenti')));
table landuse;
	title "Landuse for just residential observations";
run;
*Net new units seems like trash to me;
data test (keep= yearcomp objectid address demores landuse name parcelid statusid tenure timing
		type units net_units ward x_coord y_coord comments cluster00 rename=(parcelid=ssl objectid=dcopid));
	set planning.Houspipe2008q2_clust_spatjoin;
	where landuse in ('Mixed Use' 'Residential' 'Single Family Resident' 'Multi-Family Residenti');
*create net residential units variable;
	net_units = units - demores;
*flag completed projects before 2003;
	YearComp = year(timing);
	if YearComp < 2003 then statusid=0;
	run;
proc contents data=test;
run;
** double check that DCOPid (was objectid) is a unique id number;

%testdup (test, DCOPid);
proc sort data=test nodupkey;
	by DCOPid;
	run;

proc freq data=test;
table tenure;
title "Frequency of tenure for residential properties";
run;

** checking data;
proc freq data=test;
*	where statusid=1;
	table landuse*tenure;
	format statusid status.;
	title "Landuse and tenure for all residential properties";
	run;

proc freq data=test;
	table landuse tenure landuse*tenure statusid type;
	format statusid status.;
	Title "Unclear run by residential properties";
	run;

*proc tabulate data=test;
*	var net_units;
*	class landuse statusid;
*	table landuse (sum=' ' all='total'), net_units*statusid;
*	format statusid status.;
*	run;

proc sort data=test;
	by landuse;
run;

proc summary data=test;
	var units;
	by landuse;
	class tenure;
	output out=check sum=;
	run;

proc transpose data=check out=checktran;
	var units;
	by landuse;
	id tenure;
	run;
proc freq data=planning.future_dev_2008;
table landuse*tenure;
run;
**Mark's original doesn't make any sense to me;
data planning.future_dev_2008;
	set test ;
	
** code for property type;
	if landuse = 'Single Family Resident' then proptype='10';

	if landuse = 'Multi-Family Residenti' and tenure='Ownership' then proptype='11';
		else if landuse = 'Multi-Family Residenti' and tenure='Rental' then proptype='13';
		else if landuse = 'Multi-Family Residenti' then proptype='MF';

	if landuse = 'Mixed Use' and tenure = 'Ownership' then proptype = '11';
		else if landuse = 'Mixed Use' and tenure= 'Rental' then proptype = '13';
		else if landuse = 'Mixed Use' then proptype = 'MU';

	if landuse = 'Residential' and tenure = 'Rental' then proptype='14'; /* changed this line to make all residential/rental = Multifamily rental (none=SF)*/
		else if landuse = 'Residential' and tenure = 'Ownership' then proptype = '15';
		else if landuse = 'Residential' then proptype = 'R';
*	if dcopid = '1015' then proptype = '10';** adding SF property type to one mixed use project;


	run;
proc format ;
value $proptyp
"10"	= 'Single family Owned'

'11'	='Multi family/Mixed Owned'
'13'	='Multi family/Mixed rental'

'14' = 'Residential/rental'
'15' = 'Resdiential/owned'

'MF' = "Multi familiy, no tenure type"
'MU' = "Mixed use, no tenure type"
'R' = "Residential, no tenure type"

run;

proc freq data=planning.future_dev_2008;
	table proptype;
	format proptype $proptyp. ; run;
*All have a cluster assigned;
proc print data=planning.future_dev_2008;
	var landuse tenure proptype   ;
	run;

** summarize by property type and cluster;
proc sort data=planning.future_dev_2008;
	by cluster00 proptype;
	
	run;
proc Freq data=planning.future_dev_2008;
table statusid;
format statusid status.;
run;
*302 observations where completed by 2002;
proc freq data=planning.future_dev_2008 (where = (statusid in (0)));
table timing;
run;
** already completed projects 1998-2002;
proc summary data=planning.future_dev_2008 (where=(statusid in (0)));
	by cluster00 proptype;
	var units;
	output out=prop_9802 sum=;
	run;

proc transpose data=prop_9802 out=units_9802 (drop=_name_)prefix=Prop9802_;
	var units;
	id proptype;
	by cluster00;
	run;

** already completed projects 2003-2006;
proc summary data=planning.future_dev_2008  (where=(statusid in (1)));
	by cluster00 proptype;
	var units;
	output out=prop_0306 sum=;
	run;

proc transpose data=prop_0306 out=units_0306 (drop=_name_)prefix=Prop0306_;
	var units;
	id proptype;
	by cluster00;
	run;

** near-term property;
proc summary data=planning.future_dev_2008  (where=(statusid in (2 3 4)));
	by cluster00 proptype;
	var units;
	output out=newprop2010 sum=;
	run;

proc transpose data=newprop2010 out=units2010 (drop=_name_)prefix=prop2010_;
	var units;
	id proptype;
	by cluster00;
	run;

** long-term projects;
proc summary data=planning.future_dev_2008 (where=(statusid = 9));
	by cluster00 proptype;
	var units;
	output out=newprop2017 sum=;
	run;
	
proc transpose data=newprop2017 out=units2017 (drop=_name_) prefix=prop2017_;
	var units;
	id proptype;
	by cluster00;
	run;

**Merge altogether into one dataset;


data planning.future_units08 ;
	merge units_9802 units_0306 units2010 units2017 ;
	by cluster00;

	label 
		Prop9802_10	= "Single family Owned_Completed 9802"

		Prop9802_11	="Multi family/Mixed Owned_Completed 9802"
		Prop9802_13	="Multi family/Mixed rental_Completed 9802"

		Prop9802_14 = "Residential/rental_Completed 9802"
		Prop9802_15 = "Resdiential/owned_Completed 9802"

		Prop9802_MF = "Multi familiy, no tenure type_Completed 9802"
		Prop9802_MU = "Mixed use, no tenure type_Completed 9802"
		Prop9802_R = "Residential, no tenure type_Completed 9802"

		Prop0306_10	= "Single family Owned_Completed 0306"

		Prop0306_11	="Multi family/Mixed Owned_Completed 0306"
		Prop0306_13	="Multi family/Mixed rental_Completed 0306"

		Prop0306_14 = "Residential/rental_Completed 0306"
		Prop0306_15 = "Resdiential/owned_Completed 0306"

		Prop0306_MF = "Multi familiy, no tenure type_Completed 0306"
		Prop0306_MU = "Mixed use, no tenure type_Completed 0306"
		Prop0306_R = "Residential, no tenure type_Completed 0306"

		Prop2010_10	= "Single family Owned_Proposed 2010"

		Prop2010_11	="Multi family/Mixed Owned_Proposed 2010"
		Prop2010_13	="Multi family/Mixed rental_Proposed 2010"

		Prop2010_14 = "Residential/rental_Proposed 2010"
		Prop2010_15 = "Resdiential/owned_Proposed 2010"

		Prop2010_MF = "Multi familiy, no tenure type_Proposed 2010"
		Prop2010_MU = "Mixed use, no tenure type_Proposed 2010"
		Prop2010_R = "Residential, no tenure type_Proposed 2010"

			Prop2017_10	= "Single family Owned_Proposed 2017"

		Prop2017_11	="Multi family/Mixed Owned_Proposed 2017"
		Prop2017_13	="Multi family/Mixed rental_Proposed 2017"

		Prop2017_14 = "Residential/rental_Proposed 2017"
		Prop2017_15 = "Resdiential/owned_Proposed 2017"

		Prop2017_MF = "Multi familiy, no tenure type_Proposed 2017"
		Prop2017_MU = "Mixed use, no tenure type_Proposed 2017"
		Prop2017_R = "Residential, no tenure type_Proposed 2017";

	run;
proc print data=planning.future_units08 ;run;

**********Export final data set  to excel  table*******************;
filename fexport "K:\Metro\PTatian\DCData\Libraries\Planning\Raw\HousingPipeline2008.csv" lrecl=2000;

proc export data=planning.future_units08 
   outfile=fexport
    dbms=csv replace;

run;

filename fexport clear;
run;
	
_______________________________________________
proc sort data=planning.future_dev_2008;
	by proptype;
	run;


** create ratios of MF owner-renter, and SF-MF to estimate unit types in unspecified properties;
proc summary data=planning.future_dev_2008 (where=(statusid in (0 1 2 3 4)));
	by proptype;
	var units;
	output out=est_prop sum=;
	run;

proc transpose data=est_prop out=est_prop2 (drop=_name_) prefix=City_;
	var units;
	id proptype;
	run;

** create cluster file to merge on city-wide rates;
data cluster;	
	set seo.typology06 (keep=cluster_tr2000);
	
	mvar=1;
run;

data est_prop3;
	set est_prop2;

	mvar=1;

	Total = sum (of city_10 city_11 city_13);
	TotalMF = sum (of city_11 city_13);

	RateSFtot = City_10 / total;
	RateMFtot = totalMF / total;
	RateCNtot = city_11 / total;
	RateRnttot = city_13 / total;
	RateCNMF = city_11 / totalMF;
	RateRntMF = city_13 / totalMF;

run;

proc print data=est_prop3;
run;

data est_prop4 (drop=mvar);
	merge est_prop3 cluster;
	by mvar;
run;

data seo.future_units06 (keep=clusname cluster_tr2000 prop9802_sf prop9802_cn prop9802_rnt 
				prop0306_sf prop0306_cn prop0306_rnt
				prop2010_sf prop2010_cn prop2010_rnt prop2017_sf prop2017_cn prop2017_rnt
				total9802 total0306 total2010 total2017 totalexp
				stu2010_sf stu2010_cn stu2010_rnt stu2017_sf stu2017_cn stu2017_rnt 
				stutot2017_sf stutot2017_cn stutot2017_rnt stu2010_tot stu2017_tot stutot2017_tot);
	merge units_9802 units_0306 units2010 units2017 est_prop4;
	by cluster_tr2000;

** add into SF homes the fraction of unspecified residential projects assumed to be SF (6.6%);
	addres2010 = sum(of prop2010_AO prop2010_AR prop2010_AU);
	addSF2010 = RateSFtot * addres2010;
	prop2010_SF = sum(of prop2010_10 addSF2010);

	addres9802 = sum(of prop9802_AO prop9802_AR prop9802_AU);
	addSF9802 = RateSFtot * addres9802;
	prop9802_SF = sum(of prop9802_10 addSF9802);

	addres0306 = sum(of prop0306_AO prop0306_AR prop0306_AU);
	addSF0306 = RateSFtot * addres0306;
	prop0306_SF = sum(of prop0306_10 addSF0306);

** add into MF unspecified units the fraction of unspecified residential projects assumed to be MF (93.4%);
	addMF2010 = RateMFtot*(prop2010_AU);
	prop2010_MF = sum(of prop2010_MF addMF2010);

	addMF9802 = RateMFtot*(prop9802_AU);
	prop9802_MF = sum(of prop9802_MF addMF9802);

	addMF0306 = RateMFtot*(prop0306_AU);
	prop0306_MF = sum(of prop0306_MF addMF0306);

** add into MF owner units the fraction of unspecified residential owner projects assumed to be MF (93.3%)
** also decompose unknown MF units into rental/condo based on proportion of known units with file (condo=65.4% rental=34.6%);
	addCNres2010 = RateMFtot*(prop2010_AO);
	addCNMF2010 = RateCNMF*(prop2010_MF);
	prop2010_CN = sum(of prop2010_11 addCNres2010 addCNMF2010);

	addCNres9802 = RateMFtot*(prop9802_AO);
	addCNMF9802 = RateCNMF*(prop9802_MF);
	prop9802_CN = sum(of prop9802_11 addCNres9802 addCNMF9802);

	addCNres0306 = RateMFtot*(prop0306_AO);
	addCNMF0306 = RateCNMF*(prop0306_MF);
	prop0306_CN = sum(of prop0306_11 addCNres0306 addCNMF0306);
	
** add into MF rental units the fraction of unspecified residential rental projects assumed to be MF (93.3%);
	addRntres2010 = RateMFtot*(prop2010_AR);
	addRntMF2010 = RateRntMF*(prop2010_MF);
	prop2010_Rnt = sum(of prop2010_13 addRntres2010 addRntMF2010);

	addRntres9802 = RateMFtot*(prop9802_AR);
	addRntMF9802 = RateRntMF*(prop9802_MF);
	prop9802_Rnt = sum(of prop9802_13 addRntres9802 addRntMF9802);

	addRntres0306 = RateMFtot*(prop0306_AR);
	addRntMF0306 = RateRntMF*(prop0306_MF);
	prop0306_Rnt = sum(of prop0306_13 addRntres0306 addRntMF0306);
	
** decompose new neighborhoods into 10% SF and 90% MF (currently all MF);
	addnewnSF = .1 * (prop2017_MF);
	prop2017_SF = sum(of addnewnSF prop2017_SF);
	prop2017_MF = .9 * (prop2017_MF);

** decompose new neighborhood MF into 40% rental and 60% condo;	
	prop2017_CN = RateCNMF * prop2017_MF;
	prop2017_Rnt = RateRntMF * prop2017_MF;
		
** calculated total new units;
	total9802 = sum(of prop9802_SF prop9802_CN prop9802_Rnt);
	total0306 = sum(of prop0306_SF prop0306_CN prop0306_Rnt);
	total2010 = sum(of prop2010_SF prop2010_CN prop2010_Rnt);
	total2017 = sum(of prop2017_SF prop2017_CN prop2017_Rnt);
	totalexp = sum(of total2010 total2017);

** project additional students from net new housing
	use multipliers from 2006 HNC:
		SF - 0.40098
		Condo - 0.07149
		MF rental - 0.24177;

	stu2010_SF = prop2010_sf * 0.40098;
	stu2010_CN = prop2010_CN * 0.07149;
	stu2010_rnt = prop2010_rnt * 0.24177;

	stu2017_SF = prop2017_sf * 0.40098;
	stu2017_CN = prop2017_CN * 0.07149;
	stu2017_rnt = prop2017_rnt * 0.24177;

	StuTot2017_SF = sum(of stu2010_sf stu2017_sf);
	StuTot2017_CN = sum(of stu2010_cn stu2017_cn);
	StuTot2017_rnt = sum(of stu2010_rnt stu2017_rnt);

	Stu2010_TOT = sum(of stu2010_sf stu2010_cn stu2010_rnt);
	Stu2017_TOT = sum(of stu2017_sf stu2017_cn stu2017_rnt);
	StuTot2017_TOT = sum(of StuTot2017_sf StuTot2017_cn StuTot2017_rnt);

	clusname = put(cluster_tr2000, $clusnm.);
		
label 
prop9802_sf = "Number of single family homes completed between 1998 and 2002"
prop9802_cn = "Number of condo units completed between 1998 and 2002"
prop9802_rnt = "Number of multifamily rental units completed between 1998 and 2002"
prop0306_sf = "Number of single family homes completed between 2003 and 2006"
prop0306_cn = "Number of condo units completed between 2003 and 2006"
prop0306_rnt = "Number of multifamily rental units completed between 2003 and 2006"
prop2010_sf = "Number of single family homes expected by 2010"
prop2010_cn = "Number of condo units expected by 2010"
prop2010_rnt = "Number of multifamily rental units expected by 2010" 
prop2017_sf = "Number of single family homes expected between 2010 and 2017"
prop2017_cn = "Number of condo units expected between 2010 and 2017"
prop2017_rnt = "Number of multifamily rental units expected between 2010 and 2017"
total9802   = "Total number of housing units completed between 1998 and 2002"
total0306   = "Total number of housing units completed between 2003 and 2006"
total2010   = "Total number of housing units expected by 2010"
total2017   = "Total number of housing units expected between 2010 and 2017"
totalexp    = "Total number of housing units expected by 2017"
stu2010_sf  = "Projected number of public school students from new single family housing expected by 2010"
stu2010_cn  = "Projected number of public school students from new condominiums/coops expected by 2010"
stu2010_rnt  = "Projected number of public school students from new multifamily rental housing expected by 2010"
stu2017_sf  = "Projected number of public school students from new single family housing expected between 2010 and 2017"
stu2017_cn  = "Projected number of public school students from new condominiums/coops expected between 2010 and 2017"
stu2017_rnt  = "Projected number of public school students from new multifamily rental housing expected between 2010 and 2017"
stutot2017_sf  = "Projected number of public school students from new single family housing expected by 2017"
stutot2017_cn  = "Projected number of public school students from new condominiums/coops expected by 2017"
stutot2017_rnt  = "Projected number of public school students from new multifamily rental housing expected by 2017"
stu2010_tot  = "Projected number of public school students from all types of new housing expected by 2010"
stu2017_tot  = "Projected number of public school students from all types of new housing expected between 2010 and 2017"
stutot2017_tot  = "Projected number of public school students from all types of new housing expected by 2017";

run;

proc contents data=seo.future_units06;
	run;

proc summary data=seo.future_units06;
	class cluster_tr2000;
	var _numeric_;
	id clusname;
	output out=check sum=;
	run;

data output;
	set check;

	if cluster_tr2000 = " " then clusname = "Washington D.C.";

run;

** output data - housing units;

filename out dde "Excel|K:\Metro\MAturner\SEO Project\Tables\Housing_units\[New and recently completed housing units.xls]units!R8C1:R49C17" notab;

data _null_;
	set output ;
	file out lrecl=65000;
	put	cluster_tr2000 '09'x clusname '09'x total9802 '09'x total0306 '09'x total2010 '09'x totalexp '09'x
		prop2010_sf	'09'x prop2010_cn '09'x prop2010_rnt '09'x prop2017_sf '09'x prop2017_cn '09'x prop2017_rnt '09'x 
		prop9802_sf '09'x prop9802_cn '09'x prop9802_rnt '09'x prop0306_sf '09'x prop0306_cn '09'x prop0306_rnt; 
run;


** output data - projected students;

filename out dde "Excel|K:\Metro\MAturner\SEO Project\Tables\Housing_units\[New and recently completed housing units.xls]students!R8C1:R49C17" notab;

data _null_;
	set output ;
	file out lrecl=65000;
	put	cluster_tr2000 '09'x clusname '09'x stu2010_tot '09'x stu2017_tot '09'x stutot2017_tot '09'x 
		stu2010_sf	'09'x stu2010_cn '09'x stu2010_rnt '09'x stu2017_sf '09'x stu2017_cn '09'x stu2017_rnt '09'x 
		stutot2017_sf '09'x stutot2017_cn '09'x stutot2017_rnt; 
run;
	

** output specific projects in near southeast;

proc print data=seo.future_dev;
	where cluster_tr2000='27';
	var cluster_tr2000 name net_units statusid timing;
	format  statusid status. cluster_tr2000;
	run;
