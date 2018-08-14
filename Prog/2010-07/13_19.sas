%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%DCData_lib( Planning )

data planning.age_1319_tr00;
set planning.age13_19;
pop_13_19=sum(p14i16,
p14i17,
p14i18,
p14i19,
p14i20,
p14i21,
p14i22,
p14i37,
p14i38,
p14i39,
p14i40,
p14i41,
p14i42,
p14i43);
keep geo2000 pop_13_19 pop100;
run;

%Create_all_summary_from_tracts(
lib=planning,
data_pre=age_1319,
data_label=%str(Population Age 13 through 19, DC),
count_vars= pop_13_19 pop100,
calc_vars=
pct_1319=100*(pop_13_19/pop100),
register=N)

/*Export to Excel*/
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[pop_1319.xls]city!R2C1:R2C4" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.age_1319_city;
put city '09'x pct_1319 '09'x pop_13_19 '09'x pop100'09'x;
run;
filename xout clear;
/*Export to Excel*/
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[pop_1319.xls]ward!R2C1:R9C4" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.age_1319_wd02;
put ward2002 '09'x pct_1319 '09'x pop_13_19 '09'x pop100'09'x;
run;
filename xout clear;
/*Export to Excel*/
filename xout dde  "Excel|D:\DCData\Libraries\Planning\Data\[pop_1319.xls]cluster!R2C1:R41C4" 
lrecl=1000 notab;

data _null_;
file xout;
set planning.age_1319_cltr00;
put cluster_tr2000 '09'x pct_1319 '09'x pop_13_19 '09'x pop100'09'x;
run;
filename xout clear;
