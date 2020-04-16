/*
Author: Maksim V. Nikiforov
Date Created: 2020-03-13
Purpose: Homework 06

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
libname InputDS 'Data'; 
libname Results 'Results';
filename RawData 'Data';

* Establish librefs and filerefs for HW06;
x 'cd C:\Users\mvnikifo\';
libname HW6 'HW06';
filename HW6 'HW06';

* Search for formats within the HW6 library;
options fmtsearch=(HW6);

* Associate Metro index values with MetroDesc descriptions;
proc format library=HW6;
  value MetroDesc
    0 = "Indeterminable"
	1 = "Not in a Metro Area"
	2 = "In Central/Principal City"
	3 = "Not in Central/Principal City"
	4 = "Central/Principal Indeterminable"
  ;
run;

* Read in raw Cities.txt file. Strip away commas in city population numbers;
data HW6.CityPop;
  infile RawData("Cities.txt") dsd dlm='09'x firstobs=2;
  attrib City       label="City Name"                    length=$40
         CityPop    label="City Population (in 100s)"               informat=COMMA6. format=COMMA6.
		 Ownership  label="Ownership Status"             length=$6 
  ;
  input City CityPop;
  Ownership="Owned";
  City=tranwrd(City,'/','-');
run;

* Read in raw States.txt file. Tabs delimit Serial and State, spaces delimit State and City;
data HW6.States;
  infile RawData("States.txt") dsd dlm='09'x firstobs=2 truncover;
  attrib Serial     label="Household Serial Number"       length=8
         State      label="State, District, or Territory" length=$20
		 City       label="City Name"                     length=$40
		 Ownership  label="Ownership Status"              length=$6
  ;
  input Serial State City $ 28-73;
  Ownership="Owned";
run;

* Read in raw Contract.txt file;
data HW6.Contract;
  infile RawData("Contract.txt") dsd dlm='09'x firstobs=2;
  attrib Serial     label="Household Serial Number"  length=8
         Metro      label="Metro Status Code"        length=8
		 CountyFIPS label="County FIPS Code"         length=$3
         MortPay    label="Monthly Mortgage Payment" length=8  informat=DOLLAR6.  format=DOLLAR6.
         HHI        label="Household Income"         length=8  informat=DOLLAR10. format=DOLLAR10.
		 HomeVal    label="Home Value"               length=8  informat=DOLLAR10. format=DOLLAR10.
		 MortStat   label="Mortgage Status"          length=$45
		 Ownership  label="Ownership Status"         length=$6
		 MetroDesc  label="Metro Status Description" length=$32
  ;
  input Serial Metro CountyFIPS MortPay HHI HomeVal;
  MortStat="Yes, contract to purchase";
  Ownership="Owned";
  MetroDesc = put(Metro,MetroDesc.);
run;

* Read in raw Mortgaged.txt file;
data HW6.Mortgaged;
  infile RawData("Mortgaged.txt") dsd dlm='09'x firstobs=2 truncover;
  attrib Serial     label="Household Serial Number"  length=8
         Metro      label="Metro Status Code"        length=8
         CountyFIPS label="County FIPS Code"         length=$3
		 MortPay    label="Monthly Mortgage Payment" length=8   informat=DOLLAR6.  format=DOLLAR6.
         HHI        label="Household Income"         length=8   informat=DOLLAR10. format=DOLLAR10.
		 HomeVal    label="Home Value"               length=8   informat=DOLLAR10. format=DOLLAR10.
		 MortStat   label="Mortgage Status"          length=$45
		 Ownership  label="Ownership Status"         length=$6
		 MetroDesc  label="Metro Status Description" length=$32 
  ;
  input Serial Metro CountyFIPS MortPay HHI HomeVal;
  MortStat="Yes, mortgaged/ deed of trust or similar debt";
  Ownership="Owned";
  MetroDesc = put(Metro,MetroDesc.);
run;

/* Combine four data sets with unique household serial numbers. Two data sets (FreeClear and Renters) have been
provided by the instructor, and the remaining two data sets were created in the previous two steps */
data HW6.FreeClearRenters;
  set InputDS.FreeClear(in=FreeClear) InputDS.Renters(in=Renters rename=(FIPS=CountyFips)) HW6.Contract HW6.Mortgaged;
  MetroDesc = put(Metro,MetroDesc.);
  if FreeClear then 
    do;
      MortStat="No, owned free and clear";
	  Ownership="Owned";
	end;
  else if Renters then 
    do;
      MortStat="N/A";
      Ownership="Rented";
	end;
run;

* Sort CityPop and States data sets by common variable, City, to prepare for merging;
proc sort data=HW6.CityPop
          out=HW6.SortedCityPop;
  by City;
run;

proc sort data=HW6.States
          out=HW6.SortedStates;
  by City;
run;

* Merge CityPop and State data sets using the key variable "City";
data HW6.CityPopState;
  merge HW6.SortedCityPop HW6.SortedStates;
  by City;
run;

* Sort the merged CityPopState data set by Serial keyword to prepare for merging in a subsequent step;
proc sort data=HW6.CityPopState
          out=HW6.SortedCityPopState;
  by Serial;
run;

* Sort the FreeClearRenters data set by Serial keyword to prepare for merging in a subsequent step;
proc sort data=HW6.FreeClearRenters
          out=HW6.SortedFreeClearRenters;
  by Serial;
run;

* Create a combined data set using the "merge" procedure on the key variable "Serial";
data HW6.NikiforovIpums2005;
  attrib Serial     label="Household Serial Number"       length=8
         CountyFIPS label="County FIPS Code"              length=$3
         Metro      label="Metro Status Code"             length=8
         MetroDesc  label="Metro Status Description"      length=$32
		 CityPop    label="City Population (in 100s)"                 format=COMMA6.
		 MortPay    label="Monthly Mortgage Payment"      length=8    format=DOLLAR6.
         HHI        label="Household Income"              length=8    format=DOLLAR10.
		 HomeVal    label="Home Value"                    length=8    format=DOLLAR10.
		 State      label="State, District, or Territory" length=$20
		 City       label="City Name"                     length=$40
		 MortStat   label="Mortgage Status"               length=$45
		 Ownership  label="Ownership Status"              length=$6	 
  ;
  merge HW6.SortedCityPopState HW6.SortedFreeClearRenters;
  by Serial;
  
  if Ownership="Owned" then 
    do;
      if HomeVal=. then HomeVal=.M;
	end;
  else if Ownership="Rented" then 
    do;
	  if HomeVal="9999999" then HomeVal=.R;
	end;
run;

* Compare contents of the merged data set against instructor's;
proc compare base=Results.hw6dugginsipums2005 compare=HW6.NikiforovIpums2005
             out=HW6.CompareIpums2005 outbase outcompare outdif
			 method=absolute criterion=1E-15;
run;

* Isolate descriptor in its own data set;
ods exclude EngineHost SortedBy Attributes;
ods output Position = HW6.ContentsNikiforovIpums2005(drop=Member Informat);
proc contents data=HW6.NikiforovIpums2005 varnum;
run;

* Compare descriptor against insturctor's;
proc compare base=Results.hw6dugginsdesc compare=HW6.ContentsNikiforovIpums2005
             out=HW6.CompareIpums2005 outbase outcompare outdif
			 method=absolute criterion=1E-15;
run;

* Create PDF file. Omit dates and proc titles and explicitly control page breaks;
options nodate;
ods noproctitle;
ods listing close;
ods graphics on / width=5.5in;
ods pdf file = "HW06\HW6 Nikiforov IPUMS Report.pdf" startpage = never;
title "Listing of Households in NC with Incomes Over $500,000";

* Print all households in NorthCarolina with incomes over $500,000;
proc report data=HW6.NikiforovIpums2005;
  where HHI gt 500000 and State="North Carolina";
  columns City Metro MortStat HHI HomeVal;
run;
title;

* Print select "proc univariate" tables in PDF;
ods proctitle;
ods trace on;
ods select Univariate.CityPop.BasicMeasures  Univariate.CityPop.Quantiles Univariate.CityPop.Histogram.Histogram
           Univariate.MortPay.Quantiles Univariate.HHI.BasicMeasures Univariate.HHI.ExtremeObs 
           Univariate.HomeVal.BasicMeasures Univariate.HomeVal.ExtremeObs Univariate.HomeVal.MissingValues;

proc univariate data=HW6.NikiforovIpums2005;
  var CityPop MortPay HHI HomeVal;
  histogram CityPop / kernel;
run;
ods trace off;

* Page break for graphics;
ods pdf startpage = now;

* Print histogram with city populations;
title "Distribution of City Population";
title2 "(For Households in a Recognized City)";
footnote j=l "Recognized cities have a non-zero value for City Population.";
proc sgplot data=HW6.NikiforovIpums2005;
  histogram CityPop / scale = proportion;
  density CityPop / type=kernel lineattrs=(color=cxCC0000 thickness=3);
  where CityPop ne 0;
  keylegend / location = inside position = ne;
  yaxis display = (nolabel) valuesformat = percent7.;
run;
title;
footnote;

* Print four panels of historgrams based on mortgage status and household incomes;
title "Distribution of Household Income Stratified by Mortgage Status";
footnote "Kernel estimate parameters were determined automatically.";
proc sgpanel data=HW6.NikiforovIpums2005 noautolegend;
  panelby MortStat / novarname;
  histogram HHI / scale = proportion;
  density HHI / type=kernel lineattrs=(color=cxCC0000);
  rowaxis display = (nolabel) valuesformat = percent7.;
run;
title;
footnote;

* Close PDF for writing, resume printing to default destination;
ods pdf close;
ods listing;

quit;
