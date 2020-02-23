/*
Author: Maksim V. Nikiforov
Date Created: 2020-01-30
Purpose: Homework 03

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
filename RawData 'Data\BookData\Data\Clinical Trial Case Study';
libname Results 'Results'; 

* Establish librefs and filerefs for outgoing data;
x 'cd C:\Users\mvnikifo\HW03';
libname HW3 '.';

* Read in raw baseline files for three sites;
data HW3.Site1Baseline;
  infile RawData("Site 1, Baselilne Visit.txt") dlm='09'x dsd;
  attrib Subj        label = 'Subject Number' 
         sfReas      label = 'Screen Failure Reason'              length = $50
		 sfStatus    label = 'Screen Failure Status (0 = Failed)' length = $1
		 BioSex      label = 'Biological Sex'                     length = $1
		 VisitDate   label = 'Visit Date'                         length = $9
		 failDate    label = 'Failure Notification Date'          length = $9
		 sbp         label = 'Systolic Blood Pressure'
		 dbp         label = 'Diastolic Blood Pressure'
		 bpUnits     label = 'Units (BP)'                         length = $5
		 pulse       label = 'Pulse'
		 pulseUnits  label = 'Units (Pulse)'                      length = $9
		 position    label = 'Position'                           length = $9
		 temp        label = 'Temperature'                                     format = 5.1
		 tempUnits   label = 'Units (Temp)'                       length = $1
		 weight      label = 'Weight'
		 weightUnits label = 'Units (Weight)'                     length = $2
		 pain        label = 'Pain Score'
  ;
  input Subj sfReas $ sfStatus $ BioSex $ VisitDate $ failDate $ sbp dbp bpUnits $ pulse pulseUnits $
        position $ temp tempUnits $ weight weightUnits $ pain;
run;

data HW3.Site2Baseline;
  infile RawData("Site 2, Baseline Visit.csv") dlm='2C'x dsd;
  attrib Subj        label = 'Subject Number' 
         sfReas      label = 'Screen Failure Reason'              length = $50
		 sfStatus    label = 'Screen Failure Status (0 = Failed)' length = $1
		 BioSex      label = 'Biological Sex'                     length = $1
		 VisitDate   label = 'Visit Date'                         length = $9
		 failDate    label = 'Failure Notification Date'          length = $9
		 sbp         label = 'Systolic Blood Pressure'
		 dbp         label = 'Diastolic Blood Pressure'
		 bpUnits     label = 'Units (BP)'                         length = $5
		 pulse       label = 'Pulse'
		 pulseUnits  label = 'Units (Pulse)'                      length = $9
		 position    label = 'Position'                           length = $9
		 temp        label = 'Temperature'                                     format = 3.1
		 tempUnits   label = 'Units (Temp)'                       length = $1
		 weight      label = 'Weight'
		 weightUnits label = 'Units (Weight)'                     length = $2
		 pain        label = 'Pain Score'
  ;
  input Subj sfReas $ sfStatus $ BioSex $ VisitDate $ failDate $ sbp dbp bpUnits $ pulse pulseUnits $
        position $ temp tempUnits $ weight weightUnits $ pain;
run;

data HW3.Site3Baseline;
  infile RawData("Site 3, Baseline Visit.dat") dlm='*' dsd;
  attrib Subj        label = 'Subject Number' 
         sfReas      label = 'Screen Failure Reason'              length = $50
		 sfStatus    label = 'Screen Failure Status (0 = Failed)' length = $1
		 BioSex      label = 'Biological Sex'                     length = $1
		 VisitDate   label = 'Visit Date'                         length = $9
		 failDate    label = 'Failure Notification Date'          length = $9
		 sbp         label = 'Systolic Blood Pressure'
		 dbp         label = 'Diastolic Blood Pressure'
		 bpUnits     label = 'Units (BP)'                         length = $5
		 pulse       label = 'Pulse'
		 pulseUnits  label = 'Units (Pulse)'                      length = $9
		 position    label = 'Position'                           length = $9
		 temp        label = 'Temperature'                                     format = 3.1
		 tempUnits   label = 'Units (Temp)'                       length = $1
		 weight      label = 'Weight'
		 weightUnits label = 'Units (Weight)'                     length = $2
		 pain        label = 'Pain Score'
  ;
  input Subj 1-7 sfReas $ 8-58 sfStatus $ 59-61 BioSex $ 62 VisitDate $ 63-72 failDate $ 73-82 sbp 83-85 
        dbp 86-88 bpUnits $ 89-94 pulse 95-97 pulseUnits $ 98-107 position $ 108-120 temp 121-123 
        tempUnits $ 124 weight 125-127 weightUnits $ 128-131 pain 132;
  list;
run;

* Sort all three data sets;
proc sort data=HW3.Site1Baseline
          out=HW3.Site1BaselineSorted;
  by descending sfStatus sfReas descending VisitDate descending failDate Subj;
run;

proc sort data=HW3.Site2Baseline
          out=HW3.Site2BaselineSorted;
  by descending sfStatus sfReas descending VisitDate descending failDate Subj;
run;

proc sort data=HW3.Site3Baseline
          out=HW3.Site3BaselineSorted;
  by descending sfStatus sfReas descending VisitDate descending failDate Subj;
run;

* Compare sorted data sets against master;
proc compare base=Results.hw3dugginssite1 compare=HW3.Site1BaselineSorted
             out=work.diffs1
             outbase outcompare outdiff outnoequal 
			 method=absolute criterion=1E-10;
run;

proc compare base=Results.hw3dugginssite2 compare=HW3.Site2BaselineSorted
             out=work.diffs2
             outbase outcompare outdiff outnoequal 
			 method=absolute criterion=1E-10;
run;

proc compare base=Results.hw3dugginssite3 compare=HW3.Site3BaselineSorted
             out=work.diffs3
             outbase outcompare outdiff outnoequal 
			 method=absolute criterion=1E-10;
run;

* Create custom format for blood pressure variables;
proc format fmtlib library = HW3;
  value sbp(fuzz=0) low-<130 = 'Acceptable'
                    130-high = 'High'
  ;
  value dbp(fuzz=0) low-<80 = 'Acceptable'
                    80-high = 'High'
  ;
run;

* Set options, omit procedure titles, write to PDF/RTF/PowerPoint;
options number pageno=1 nodate fmtsearch=(HW3);
ods noproctitle;
ods listing close;
ods pdf file='HW3 Nikiforov Clinical Report.pdf';
ods rtf file='HW3 Nikiforov Clinical Report.rtf' style=Sapphire;
ods powerpoint file='HW3 Nikiforov Clinical Report.pptx' style=PowerPointDark;

ods powerpoint exclude all;

* Print descriptorsfor all three data sets;
title 'Variable-level Attributes and Sort Information: Site 1';

proc contents data=HW3.Site1BaselineSorted varnum;
  ods select Position Sortedby;
run;

title;

title 'Variable-level Attributes and Sort Information: Site 2';

proc contents data=HW3.Site2BaselineSorted varnum;
  ods select Position Sortedby;
run;

title;

title 'Variable-level Attributes and Sort Information: Site 3';

proc contents data=HW3.Site3BaselineSorted varnum;
  ods select Position Sortedby;
run;

title;

* Begin printing content to PowerPoint file;
ods powerpoint select all;

* Print summary statistics for Site 1;
title 'Selected Summary Statistics on Baseline Measurements';
title2 'for Patients from Site 1';
footnote j=l h=8pt 'Statistic and SAS keyword: Sample size (n), Mean (mean), Standard Deviation (stddev), Median (median), IQR (qrange)';

proc means data=HW3.Site1BaselineSorted nonobs n mean stddev median qrange maxdec=1;
  class pain;
  var weight temp pulse dbp sbp;
run;

title;
footnote;

* Print frequency analysis for site 2;
title 'Frequency Analysis of Baseline Positions and Pain Measurements by Blood Pressure Status';
title2 'for Patients from Site 2';
footnote j=l 'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic reaches 80';

* Place frequency tables into 2 columns on the page;
ods pdf columns=2;

proc freq data=HW3.Site2BaselineSorted;
  tables position / norow nocol; 
  tables pain*dbp*sbp / norow nocol;
  format sbp sbp. dbp dbp.;
run;

title;
footnote;

* Return to single column PDF;
ods pdf columns=1;
ods powerpoint exclude all;

* Print select observations for site 3;
title 'Selected Listing of Patients with a Screen Failure and Hypertension';
title2 'for patients from Site 3';
footnote j=l 'Hypertension (high blood pressure) begins when systolic reaches 130 or diastolic reaches 80';
footnote2 j=l 'Only patients with a screen failure are included.';
 
proc print data=HW3.Site3BaselineSorted noobs label;
  id Subj pain;
  var VisitDate sfStatus sfReas failDate BioSex sbp dbp bpUnits weight weightUnits;
  where (sbp ge 130 or dbp ge 80) and sfStatus eq '0';
run;

title;
footnote;

* Stop writing to PPT, PDF and RTF, resume writing to default output;
ods powerpoint close;
ods pdf close;
ods rtf close;
ods listing;

quit;
