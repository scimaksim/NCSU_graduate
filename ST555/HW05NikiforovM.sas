/*
Author: Maksim V. Nikiforov
Date Created: 2020-02-27
Purpose: Homework 05

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
libname InputDS 'Data'; 
libname Results 'Results';
filename RawData 'Data';

* Establish librefs and filerefs for HW04 and HW05;
x 'cd C:\Users\mvnikifo\';
libname HW4 'HW04';
libname HW5 'HW05';
filename HW5 'HW05';

/* Search HW4 library for custom formats. 
Omit dates and procedure titles from PDF and RTF */
options fmtsearch=(HW4) nodate;
ods noproctitle;

/* Read in O3Projects file. Create temporary variables to hold 
misformatted data. Subsequently, use SAS functions to correctly 
format observations. */
data HW5.O3projects(drop = _:);
  infile RawData("O3Projects.txt") dsd truncover firstobs=2;
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
		_Equipment   : comma.
		_Personnel   : comma.
  ;
  Region = propcase(scan(_DateRegion,1,,'d'));
  JobID = input(tranwrd((tranwrd(_JobID,'O','0')), 'l', '1'), 8.);
  StName = upcase(_StName);
  JobTotal = _Equipment + _Personnel;
  Date = scan(_DateRegion,1,,'lu');
  Equipment = _Equipment;
  Personnel = _Personnel;
run;

* Read in COProjects file;
data HW5.COprojects(drop = _:);
  infile RawData("COProjects.txt") dsd truncover firstobs=2;
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
		_Equipment   : comma.
		_Personnel   : comma.
  ;
  Region = propcase(scan(_DateRegion,1,,'d'));
  JobID = input(tranwrd((tranwrd(_JobID,'O','0')), 'l', '1'), 8.);
  StName = upcase(_StName);
  JobTotal = _Equipment + _Personnel;
  Date = scan(_DateRegion,1,,'lu');
  Equipment = _Equipment;
  Personnel = _Personnel;
run;

/* Sort LeadProjects dataset by Region, StName, 
and descending JobTotal to match master data set */
proc sort data=HW4.LeadProjects
          out=HW5.SortedLeadProjects;
  by Region StName descending JobTotal;
run;

* Combine all data sets in order of ascending PolCode;
data HW5.NikiforovProjects(drop = _:);
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
  set InputDS.TSPprojects(in=TSP)
      HW5.SortedLeadProjects(in=LEAD)
	  HW5.COprojects(in=CO)
      InputDS.SO2projects(in=SO2)
	  HW5.O3projects(in=O3);
  PolCode = put(strip(1*TSP + 2*LEAD + 3*CO + 4*SO2 + 5*O3), $8.);
  if Equipment = 99999 then Equipment = .;
  if Personnel = 99999 then Personnel = .;
  JobTotal = sum(Equipment, Personnel);
  select(PolCode);
    when('1') PolType = 'TSP';
	when('2') PolType = 'LEAD';
	when('3') PolType = 'CO';
	when('4') PolType = 'SO2';
	when('5') PolType = 'O3';
  end;
  if PolCode='1' or PolCode='4' then do;
  StName = upcase(_st);
  Region = propcase(scan(_DateRegion,1,,'d'));
  Date = scan(_dateregion,1,,'lu');
  JobID = tranwrd((tranwrd(_job,'O','0')), 'l', '1');
  end;
run;

/* The commented sections compare data set contents 
and descriptor against instructor's */

/*
* Compare data set contents against instructor's;
proc compare base=results.hw5dugginsprojects compare=HW5.NikiforovProjects
             outbase outcompare outdif oout=DiffNikiforovProjects
			 method=absolute criterion=1E-15;
run; 
*/

/*
* Funnel descriptor into a data set for comparison against instructor's; 
ods exclude EngineHost SortedBy Attributes;
ods output Position = HW5.NikiforovProjectsDesc(drop=Member);
proc contents data=HW5.NikiforovProjects varnum;
run; 
*/

/*
* Compare descriptor to instructor's;
proc compare base=Results.HW5DugginsProjectsDesc compare=HW5.NikiforovProjectsDesc
             outbase outcompare outdif out=DiffNikiforovProjectsDesc
			 method=absolute
			 criterion=1E-15;
run;
*/

* Sort data set based on PolCode to prepare for graphing;
proc sort data=HW5.NikiforovProjects
          out=NikiforovProjectsSorted;
  by PolCode Region Date;
run;

* Produce 90th percentile summary data set for sorted data set;
ods output summary = HW5.ProjectsPct;
title "90th Percentile of Total Job Cost By Region";
title2 "Including Records where Region was Unknown (Missing)";
proc means data=NikiforovProjectsSorted p90;
  var JobTotal;
  class PolCode Region Date / missing;
  format Date MyQTR.;
run;
title;

* Print contents only to PDF and RTF;
ods listing close;
ods pdf file = "HW05\HW5 Nikiforov Projects Report.pdf";
ods rtf file = "HW05\HW5 Nikiforov Projects Report.rtf";

* Create and save horizontal bar graph PNG using summary statistics data set;
ods listing dpi=300 gpath='HW05';
ods graphics / reset=index imagename="Nikiforov90PctPlot" height=4.5in width=6in;
title "90th Percentile of Total Job Cost by Region";
title2 "Including Records where Region was Unknown (Missing)";
footnote j=l "Bars are labeled with the number of jobs contributing to each bar";
proc sgplot data=HW5.ProjectsPct;
  by PolCode;
  hbar Region / missing group=Date groupdisplay=cluster response=JobTotal_P90
  datalabel=NObs datalabelattrs = (size = 7) datalabelfitpolicy=none;
  keylegend / position=top;
  format JobTotal_P90 dollar9.;
  xaxis display=(nolabel) grid;
  yaxis display=(nolabel);
run;
title;
footnote;
ods listing close;

* Do not print proc freq and proc sort output to PDF and RTF;
ods pdf exclude all;
ods rtf exclude all;

* Produce frequency summaries for sorted data in HW5.LeadProjects;
ods output crosstabfreqs = HW5.ProjectsFreq(where=(_type_='111'));
ods listing;
ods trace on;
proc freq data=NikiforovProjectsSorted;
  tables Region*PolCode*Date / nocol nopercent missing;
  format Date MyQTR.;
run;
ods trace off;

* Sort frequency summaries by PolCode to prepare for plotting;
proc sort data=HW5.ProjectsFreq
          out=NikiforovProjectsFreqSorted;
  by PolCode Region Date;
run;

* Resume printint to PDF and RTF;
ods pdf select all;
ods rtf select all;

* Plot frequency summary statistics and save resulting PNG to HW5 directory;
ods listing dpi=300 gpath='HW05';
ods graphics / reset=index imagename="NikiforovFreqPlot" height=4.5in width=6in;
proc sgplot data=NikiforovProjectsFreqSorted;
  by PolCode;
  styleattrs datacolors = (turquoise gold red green);
  vbar Region / group=Date groupdisplay=cluster response=rowpercent missing;
  keylegend / position=topright location=inside  down=2 opaque;
  xaxis display=(nolabel) labelattrs = (size=16) valueattrs = (size=14);
  yaxis label = "Percentage within Region" 
        labelattrs = (size=16) 
        values=(0 to 60 by 5)
        valueattrs = (size=12)
        grid gridattrs=(color=grayCC thickness=3)
        offsetmax=0.05;
run;
ods listing close;

* Resume writing to default output;
ods pdf close;
ods rtf close;
ods listing;

quit;
