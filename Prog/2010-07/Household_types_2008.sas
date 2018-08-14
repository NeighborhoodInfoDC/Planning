/**************************************************************************
 Program:  Household_types_2006.sas
 Library:  Planning
 Project:  NeighborhoodInfo DC
 Author:   P. Tatian
 Created:  08/03/08
 Version:  SAS 9.1
 Environment:  Windows
 
 Description:  Use ACS 2006 IPUMS data to determine household types.

 Modifications:
**************************************************************************/

***%include "K:\Metro\PTatian\DCData\SAS\Inc\Stdhead.sas";
%include "C:\DCData\SAS\Inc\Stdhead.sas";

** Define libraries **;
%DCData_lib( Planning )
%DCData_lib( Ipums )

*options obs=100;

data Household_types (compress=no);

  set 
    Ipums.Ipums_2000_fam_pmsa99 (in=in2000)

	
    Ipums.Acs_2008_fam_pmsa99;

  where statefip = 11 and gq not in ( 3, 4 );

  retain total 1;

  if in2000 then year = 2000;
  else year = 2008;

  if not is_family then do;

    /** Non-family HHs **/
    
    if not is_elderly then do;
  
      if persons_hh = 1 then hhtype = 1;  /** Single person HHs **/
      else hhtype = 2;  /** Other nonfamily (nonelderly) **/

    end;
    else do;
    
      if not has_spouse then hhtype = 8;
      
    end;
    
  end;
  else do;
  
    /** Family HHs **/
    
    if has_spouse then do;

      if own_children_18 = 0 then do;
        /** Married couples w/o children **/
        if not is_elderly then hhtype = 3;  
        else hhtype = 9;
      end;
      else do;
        hhtype = 4;
      end;
      
    end;
    else do;
    
      if own_children_18 > 0 then do;
        if hhh_sex = 2 then hhtype = 5;  /** Single female **/
        else hhtype = 6;  /** Single male **/
      end;
      else do;
        if not is_elderly then do;
          if related_children_18 > 0 then hhtype = 7.1;  /** Other family (nonelderly) w/children **/
          else hhtype = 7.2; /** Other family, w/o children **/
        end;
        else hhtype = 8;
      end;
      
    end;
    
  end;    

run;

proc format;
  value oneplus
    0 = '0'
    1-high = '1+';
  value twoplus
    0 = '0'
    1 = '1'
    2-high = '2+';
  value hhtype
    1 = 'Singles (noneld.)'
    2 = 'Other nonfamily (noneld.)'
    3 = 'Childless married (noneld.)'
    4 = 'Married w/children'
    5 = 'Single mom'
    6 = 'Single dad'
    7.1,7.2 = 'Other family (noneld.)'
    /*
    7.1 = 'Other family (noneld.) w/child'
    7.2 = 'Other family (noneld.) w/o child'
    */
    8 = 'Empty nester, no spouse'
    9 = 'Empty nester, w/spouse';
  
proc freq data=Household_types;
  by year;
  tables hhtype * is_family * is_elderly * persons_hh * has_spouse * own_children_18 / list missing nocum nopercent;
  format hhtype hhtype. persons_hh twoplus. own_children_18 oneplus.;
run;

ods rtf file="&_dcdata_path\Planning\Prog\2010-07\Household_types.rtf" style=Styles.Rtf_arial_9pt;

proc tabulate data=Household_types format=comma10.0 noseps missing;
  class year hhtype;
  var total;
  weight hhwt;
  table 
    /** Rows **/
    sum * f=comma10. ( all hhtype ) * colpctsum=' ',
    /** Columns **/
    total * year
  / rts=50;
  format hhtype hhtype.;
run;

ods rtf close;

