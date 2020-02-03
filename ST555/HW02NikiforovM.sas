/*
Author: Maksim V. Nikiforov
Date Created: 2020-01-23
Purpose: Homework 01

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\';
libname InputDS 'ST555\Data'; 
filename RawData 'ST555\Data';

* Establish librefs and filerefs for outgoing data;
x 'cd C:\Users\mvnikifo\HW02';
libname HW2 '.';
filename Results '.';

* Gain access to formats in the InputDS library;
options fmtsearch=(InputDS) nodate;

* Remove titles of procedures from documents;
ods noproctitle;

* Close dafult outut destination and open RTF, PDF files for writing;
ods listing close;
ods rtf file="HW2 Nikiforov Baseball Report.rtf" style=Sapphire;
ods pdf file="HW2 Nikiforov Baseball Report.pdf" style=Journal;

* Create data set from raw file, start at line 13 to omit notes;
data HW2.Baseball;
  infile RawData("Baseball.dat") dlm='092C'x firstobs=13;
  attrib FName    label='First Name'                    length=$9
         LName    label='Last Name'                     length=$11   
		 Team     label='Team at the end of 1986'       length=$13
		 nAtBat   label='# of At Bats in 1986'  
		 nHits    label='# of Hits in 1986'      
		 nHome    label='# of Home Runs in 1986'
		 nRuns    label='# of Runs in 1986'
		 nRBI     label='# of RBIs in 1986'
		 nBB      label='# of Walks in 1986'
		 YrMajor  label='# of Years in the Major Leagues'
		 CrAtBat  label='# of At Bats in Career'
		 CrHits   label='# of Hits in Career'
		 CrHome   label='# of Home Runs in Career'
         CrRuns   label='# of Runs in Career'
         CrRbi    label='# of RBIs in Career'
         CrBB     label='# of Walks in Career'
         League   label='League at the end of 1986'     length=$8
		 Division label='Division at the end of 1986'   length=$4
		 Position label='Position(s) Played'            length=$2
		 nOuts    label='# of Put Outs in 1986'
		 nAssts   label='# of Assists in 1986'
		 nError   label='# of Errors in 1986'
		 Salary   label='Salary (Thousands of Dollars)' format=DOLLAR10.3
  ; 
  input LName $ FName $ Team $ nAtBat 50-53 nHits 54-57 nHome 58-61 nRuns 62-65 
        nRBI 66-69 nBB 70-73 YrMajor 74-77 CrAtBat 78-82 CrHits 83-86 CrHome 87-90 CrRuns 91-94
		CrRbi 95-98 CrBB 99-102 League $ Division $ Position $ nOuts 133-136 nAssts 137-140 nError 141-144 Salary 145-152;
run;

* Do not print contents to PDF;
ods pdf exclude all;

* Print descriptor for variables in creation order to RTF;
title 'Variable-Level Metadata (Descriptor) Information';
proc contents data=HW2.Baseball varnum;
  ods select position;
run;
title;

* Print details of salary format to RTF;
title 'Salary Format Details';
proc format library=InputDS fmtlib;
  select Salary;
run;
title;

* Resume printing contents to PDF;
ods pdf exclude none;

* Print five-number summaries for batting statistics to RTF and PDF, do not omit missing values;
title 'Five Number Summaries of Selected Batting Statistics';
title2 h=10pt 'Grouped by League (1986), Division (1986), and Salary Category (1987)';
proc means data=HW2.Baseball min p25 p50 p75 max nolabels missing maxdec=2;
  class League Division Salary;
  format Salary Salary.;
  vars nHits nHome nRuns nRBI nBB;
run;
title;

* Print frequency statistics to RTF and PDF, do not omit missing values; 
title 'Breakdown of Players by Position and Position by Salary';
proc freq data=HW2.Baseball;
  table Position Position*Salary / missing;
  format Salary Salary.;
run;
title;

* Sort player information;
proc sort data=HW2.Baseball
          out=Baseball;
  by League Division Team descending Salary;
run;

* Print sorted player information to RTF and PDF; 
title 'Listing of Selected 1986 Players';
footnote j=l h=8pt 'Included: Players with Salaries of at least $1,000,000 or who played for the Chicago Cubs';
proc print data=Baseball label;
  id LName FName Position;
  var League Division Team Salary nHits nHome nRuns nRBI nBB;
  where (Salary>=1000) | (Team='Chicago' & Division='East'); 
  sum Salary nHits nHome nRuns nRBI nBB;
  format Salary dollar12.3 nHits nHome nRuns nRBI nBB comma5.;
run;
title;
footnote;

* Close documents for writing, resume sending ouput to default destination;
ods pdf close;
ods rtf close;
ods listing;

quit;
