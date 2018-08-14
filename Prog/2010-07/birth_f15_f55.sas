%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

data planning.f1544_tr00;
set planning.agef15_44;
pop_15_44=sum(
P12i30,
P12i31,
P12i32,
P12i33,
P12i34,
P12i35,
P12i36,
P12i37,
P12i38);
keep geo2000 pop_15_44 ;
run;

%Create_all_summary_from_tracts(
lib=planning,
data_pre=f1544,
data_label=%str(Female Population Age 15 through 44, DC),
count_vars= pop_15_44,
register=N)

/*cluster*/
data births_cluster;
set planning.dc_nbrhds_2010_7;
if cluster_tr2000="" then delete;
keep 
cluster_tr2000
births_total_1998
births_total_1999
births_total_2000
births_total_2001
births_total_2002
births_total_2003
births_total_2004
births_total_2005
births_total_2006
births_total_2007;
run;

proc sort data=births_cluster;
by cluster_tr2000;
run;

data planning.birth_rate_cluster;
merge births_cluster planning.f1544_cltr00;
by cluster_tr2000;
birthrate98=(births_total_1998/pop_15_44)*100;
birthrate99=(births_total_1999/pop_15_44)*100;
birthrate00=(births_total_2000/pop_15_44)*100;
birthrate01=(births_total_2001/pop_15_44)*100;
birthrate02=(births_total_2002/pop_15_44)*100;
birthrate03=(births_total_2003/pop_15_44)*100;
birthrate04=(births_total_2004/pop_15_44)*100;
birthrate05=(births_total_2005/pop_15_44)*100;
birthrate06=(births_total_2006/pop_15_44)*100;
birthrate07=(births_total_2007/pop_15_44)*100;
keep
birthrate98
birthrate99
birthrate00
birthrate01
birthrate02
birthrate03
birthrate04
birthrate05
birthrate06
birthrate07
cluster_tr2000;
run;
/*Export to Excel*/
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[birthrate.xls]cluster!R2C1:R41C11" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.birth_rate_cluster;
put cluster_tr2000 '09'x birthrate98 '09'x birthrate99 '09'x birthrate00 '09'x birthrate01 '09'x birthrate02 '09'x
birthrate03'09'x birthrate04 '09'x birthrate05 '09'x birthrate06 '09'x birthrate07 '09'x ;
run;
filename xout clear;

/*ward*/
data births_ward;
set planning.dc_nbrhds_2010_7;
if geo in (1100, 1200, 1300, 1400, 1500, 1600, 1700, 1800);
keep 
ward2002
births_total_1998
births_total_1999
births_total_2000
births_total_2001
births_total_2002
births_total_2003
births_total_2004
births_total_2005
births_total_2006
births_total_2007;
run;

proc sort data=births_ward;
by ward2002;
run;

data planning.birth_rate_ward;
merge births_ward planning.f1544_wd02;
by ward2002;
birthrate98=(births_total_1998/pop_15_44)*100;
birthrate99=(births_total_1999/pop_15_44)*100;
birthrate00=(births_total_2000/pop_15_44)*100;
birthrate01=(births_total_2001/pop_15_44)*100;
birthrate02=(births_total_2002/pop_15_44)*100;
birthrate03=(births_total_2003/pop_15_44)*100;
birthrate04=(births_total_2004/pop_15_44)*100;
birthrate05=(births_total_2005/pop_15_44)*100;
birthrate06=(births_total_2006/pop_15_44)*100;
birthrate07=(births_total_2007/pop_15_44)*100;
keep
birthrate98
birthrate99
birthrate00
birthrate01
birthrate02
birthrate03
birthrate04
birthrate05
birthrate06
birthrate07
ward2002;
run;

/*Export to Excel*/
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[birthrate.xls]ward!R2C1:R9C11" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.birth_rate_ward;
put ward2002 '09'x birthrate98 '09'x birthrate99 '09'x birthrate00 '09'x birthrate01 '09'x birthrate02 '09'x
birthrate03'09'x birthrate04 '09'x birthrate05 '09'x birthrate06 '09'x birthrate07 '09'x;
run;
filename xout clear;
