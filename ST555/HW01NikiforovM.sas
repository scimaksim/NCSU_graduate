/*
Author: Maksim V. Nikiforov
Date Created: 2020-01-18
Purpose: Homework 01

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\';
libname InputDS 'ST555\Data'; 

* Establish librefs and filerefs for outgoing data;
x 'cd C:\Users\mvnikifo\HW01';
libname HW1 '.';

* Set options, omit procedure titles, write only to PDF;
options number pageno=1 nodate;
ods noproctitle;
ods listing close;
ods pdf file='HW1 Nikiforov Cars Report.pdf' style=Meadow;

* Print descriptor for original data set;
title 'Descriptor Information Before Sorting';

proc contents data=InputDS.Cars varnum;
  ods select attributes position;
run;

title;

* Create sorted data set in WORK library; 
proc sort data=InputDS.Cars
          out=Cars;
  by type descending origin make;
run;

* Print descriptor for sorted data set;
title 'Descriptor Information After Sorting';

proc contents data=Cars varnum;
  ods select attributes position sortedby;
run;

title;

* Print contents of sorted dataset with pagebreaks and labels;
title 'Listing of Prices';
title2 h=8pt 'Including Type and Type by Origin Totals';

proc print data=Cars noobs label;
  by type descending origin make;
  id type origin make;
  var model MSRP invoice drivetrain enginesize cylinders
      horsepower MPG_City MPG_Highway weight wheelbase length;
  sum MSRP invoice;
  sumby type;
  pageby origin;
  attrib type        label = 'Use Classification'
         origin      label = 'Region of Origin'
		 make        label = 'Car Make'
         model       label = 'Car Model' 
		 MSRP        label = 'Manufacturer''s Suggested Retail Price' format = dollar11.
		 invoice     label = 'Invoice Price' format = dollar11.
		 drivetrain  label = 'Drive Train'
		 enginesize  label = 'Engine Size (in)'
		 cylinders   label = '# Of Cylinders'
		 horsepower  label = 'Horsepower (lb-ft)'
		 MPG_city    label = 'City Mileage (mpg)' 
		 MPG_Highway label = 'Highway Mileage (mpg)'
         weight      label = 'Weight (lb)'
		 wheelbase   label = 'Wheelbase (in)';
  label length = 'Length (in)';
run;

title;

* Define tier-based format for mileage values;
proc format;
  value MPG_tier(fuzz=0) low - 15 = "Tier 1"
                         15 <- 20 = "Tier 2"
						 20 <- 30 = "Tier 3"
						 30 <- high = "Tier 4"
  ;
run;   

* Provide various statistical summaries for sorted data set;
title 'Selected Numerical Summaries of Car Prices and Measurements';
title2 h=8pt 'by Type, Origin, and City MPG Classification';
footnote j=l'Excluding Acura and Land Rover';
footnote2 j=l 'Tier 1=Up to 15mpg, Tier 2=Up to 20, Tier 3=Up to 30, Tier 4=Over 30';

proc means data=Cars n min q1 median q3 max nonobs maxdec=1;
  class type origin MPG_city;
  var MSRP invoice enginesize cylinders horsepower weight wheelbase length;
  format MPG_city MPG_tier.;
  where make not in ("Acura" "Land Rover");
  attrib type        label = 'Type'
         origin      label = 'Origin'
		 make        label = 'Car Make'
         model       label = 'Car Model' 
		 MSRP        label = 'Manufacturer''s Suggested Retail Price' format = dollar7.
		 invoice     label = 'Invoice Price' format = dollar7.
		 drivetrain  label = 'Drive Train'
		 enginesize  label = 'Engine Size (in)'
		 cylinders   label = '# Of Cylinders'
		 horsepower  label = 'Horsepower (lb-ft)'
		 MPG_city    label = 'City Mileage (mpg)' 
		 MPG_Highway label = 'Highway Mileage (mpg)'
         weight      label = 'Weight (lb)'
		 wheelbase   label = 'Wheelbase (in)';
  label length = 'Length (in)';
run;

title;
footnote;

* Produce one- and two-way tables. Use nocol to suppress column percentages;
title 'Frequency Breakdown of Types, Types by Origin';
title2 'and Type by City Mileage Classification';
footnote j=l'Excluding Acura and Land Rover';
footnote2 j=l 'Tier 1=Up to 15mpg, Tier 2=Up to 20, Tier 3=Up to 30, Tier 4=Over 30';

proc freq data=Cars;
  tables type type*origin; 
  tables type*MPG_City / nocol;
  where make not in ('Acura' 'Land Rover');
  format MPG_city MPG_tier.;
  attrib type     label = "Use Classification"
         origin   label = "Region of Origin"
		 MPG_City label = "City Mileage (mpg)";
run;

title;
footnote;

* Stop writing to PDF, resume writing to default output;
ods pdf close;
ods listing;

quit;
