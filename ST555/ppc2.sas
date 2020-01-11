/*
Author: Maksim Nikiforov
Date Created: 2020-01-11
Purpose: Practice PPC2

Modification Date: N/A
Reason for Modification: N/A
*/

* Create library reference to requisite dataset;
libname st445 'L:\st445\Data';

* Close default ods output and open PDF and RTF files for writing;
ods listing close;
ods pdf file="C:\Users\mvnikifo\Quakes Data.pdf" style=Journal2;
ods rtf file="C:\Users\mvnikifo\Quakes.rtf";

* Exclude printing of proc contents into rtf file;
ods rtf exclude all;

/*Print and save the variable-level metadata in column-order rather than alphabetical
No other metadata should be printed */
title "Variable-level Metadata";
proc contents data=st445.quakes varnum;
 ods select position;
run;
title;

* Resume printing of content into RTF file;
ods rtf select all;

/* Print the first 20 observations in the data set, but print these variables in order and ignore other variables:
Type, Depth, Magnitude, dNearestStation, and RootMeanSquareTime */
proc print data=st445.quakes(obs=20);
  var Type Depth Magnitude dNearestStation RootMeanSquareTime;
run;

* Close PDF and RTF files for writing, resume printing into default ODS;
ods pdf close;
ods rtf close;
ods listing;
