/*
Author: Maksim V. Nikiforov
Date Created: 2020-02-20
Purpose: Homework 04

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
libname InputDS 'Data'; 
libname ResultDS 'Results';
filename RawData 'Data';

* Establish librefs and filerefs for HW04;
x 'cd C:\Users\mvnikifo\HW04';
libname HW4 '.';
filename HW4 '.';

/* Search HW4 library for custom formats. 
Omit dates and procedure titles from PDF */
options fmtsearch=(HW4) nodate;
ods noproctitle;

/* Read in LeadProjects files. Create temporary variables to hold 
misformatted data. Subsequently, use SAS functions to correctly 
format observations. */
data HW4.LeadProjects(drop = _:);
  infile RawData("LeadProjects.txt") dsd truncover firstobs=2;
  attrib StName     length=$2 label="State Name"
         Region     length=$9
         JobID      length= 8
         Date                                        format=date9.
		 PolType    length=$4 label="Pollutant Name"
		 PolCode    length=$8 label="Pollutant Code"
		 Equipment                                   format=dollar11.
		 Personnel                                   format=dollar11.
		 JobTotal                                    format=dollar11.
  ;
  input _StName      : $2.
        _JobID       : $5.
        _DateRegion  : $13.
        _PolCodeType : $5. 
		_Equipment   : comma.
		_Personnel   : comma.
  ;
  Region = propcase(scan(_DateRegion,1,,'d'));
  JobID = input(tranwrd((tranwrd(_JobID,'O','0')), 'l', '1'), 8.);
  StName = upcase(_StName);
  JobTotal = _Equipment + _Personnel;
  Date = scan(_DateRegion,1,,'lu');
  PolCode = scan(_PolCodeType,1,,'lu');
  PolType = scan(_PolCodeType,1,,'d');
  Equipment = _Equipment;
  Personnel = _Personnel;
run;

* Sort new data set by region, state name, and descending job total;
proc sort data=HW4.LeadProjects
          out=HW4.NikiforovLead;
  by Region StName descending JobTotal;
run;

* Compare sorted data set against instructor's master set;
/*proc compare base=ResultDS.HW4DugginsLead compare=HW4.NikiforovLead
             out=LeadComparison
             outbase outcompare outdif 
			 method = absolute
			 criterion = 1E-15;
run;*/

* Create data set based on descriptor; 
/* ods exclude EngineHost SortedBy Attributes;
ods output Position = HW4.NikiforovLeadDesc(drop=Member);
proc contents data=HW4.NikiforovLead varnum;
run; */

* Compare descriptor to instructor's;
proc compare base=ResultDS.HW4DugginsDesc compare=HW4.NikiforovLeadDesc
             outbase outcompare outdif
			 method=absolute
			 criterion=1E-15;
run;

* Create custom format in HW4 library to group dates by quarters;
proc format library=HW4;
  value MyQTR(fuzz=0) '01JAN1998'd - '31MAR1998'd = "Jan/Feb/March"
                         '01APR1998'd - '30JUN1998'd = "Apr/May/Jun"
                         '01JUL1998'd - '30SEP1998'd = "Jul/Aug/Sep"
                         '01OCT1998'd - '31DEC1998'd = "Oct/Nov/Dec"
  ; 
run;

* Print contents to PDF;
ods listing close;
ods pdf file = "HW4 Nikiforov Lead Report.pdf";

* Produce 90th percentile summary data set for sorted data in HW4.LeadProjects;
ods output summary = HW4.LeadPct;
title "90th Percentile of Total Job Cost By Region and Quarter";
title2 "Data for 1998";
proc means data=HW4.NikiforovLead p90;
  var JobTotal;
  class Region Date;
  format Date MyQTR.;
run;
title;
 
* Create and save horizontal bar graph PNG using summary statistics data set;
ods graphics / reset imagename='HW4NikiforovGraph1';
ods listing;
proc sgplot data=HW4.LeadPct;
  hbar Region / group=Date groupdisplay=cluster response=JobTotal_P90 
  datalabel=NObs datalabelattrs = (size = 7);
  keylegend / position=top;
  format JobTotal_P90 dollar9.;
  xaxis label = "90th Percentile of Total Job Cost"
        grid;
run;
ods listing close;

* Produce frequency summaries for sorted data in HW4.LeadProjects;
ods output crosstabfreqs = HW4.LeadFreq(where = (_type_ eq '11') keep = Region Date RowPercent _Type_);
title "Frequency of Cleanup by Region and Date";
title2 "Data for 1998";
proc freq data=HW4.NikiforovLead;
  tables Region*Date / nocol nopercent;
  format Date MyQTR.;
run;
title;

* Compare frequency statistics data set against instructor's master;
ods pdf exclude all;
proc compare base=ResultDS.HW4DugginsGraph2
             compare=HW4.LeadFreq
			 out=LeadFreqCompare
			 outbase outcompare outdif
			 method=absolute criterion=1E-15;
run;
ods pdf exclude none;

* Plot frequency summary statistics and save resulting PNG;
ods graphics / reset imagename='HW4NikiforovGraph2';
ods listing;
proc sgplot data=HW4.LeadFreq;
  styleattrs datacolors = (turquoise gold red green);
  vbar Region / group=Date groupdisplay=cluster response=rowpercent;
  keylegend / position=topright location=inside  across=2 opaque;
  xaxis labelattrs = (size=16) valueattrs = (size=14);
  yaxis label = "Region Percentage within Pollutant" 
        labelattrs = (size=16) 
        values=(0 to 45 by 5)
        valueattrs = (size=12)
        grid gridattrs=(color=grayCC thickness=3)
        offsetmax=0.05;
run;
ods listing close;

ods pdf close;
ods listing;

quit;
