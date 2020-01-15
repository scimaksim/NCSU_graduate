/*
Author: Maksim Nikiforov
Date Created: 2020-01-15
Purpose: Practice PPC2

Modification Date: N/A
Reason for Modification: N/A
*/

* Define library;
libname PPC3 'L:\st555\Data';

* Don't print anything to the listing window;
ods listing close;
* Product PDF using Sapphire style;
ods pdf file='GULFOIL.pdf' style=Sapphire;

* Print first five observations, omit all ODS output except for variables;
proc contents data=ppc3.gulfoil (obs=5);
  ods select variables;
run;

* Create sorted data setin WORK library;
proc sort data=ppc3.gulfoil
          out=sorted_gulfoil;
  by descending regionname descending protractionname date;
run;

* Print sorted data set;
proc print data=sorted_gulfoil label noobs;
  id regionname protractionname;
  by descending regionname descending protractionname; 
  format date date9.;
run;
		
ods pdf close;
ods listing;
