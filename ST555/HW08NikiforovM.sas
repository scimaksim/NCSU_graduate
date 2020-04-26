/*
Author: Maksim V. Nikiforov
Date Created: 2020-04-15
Purpose: Homework 08

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
libname InputDS 'Data'; 
libname Results 'Results';
filename RawData 'Data';

* Establish librefs and filerefs for HW08;
x 'cd C:\Users\mvnikifo\';
libname HW08 'HW08';
filename HW08 'HW08';

* Filter out anomalies from raw data set; 
data HW08.Blood;
  infile RawData("blood.txt") dlm='20'x firstobs=2;
  attrib BloodType length=$2 label="Blood Type"
		 AgeGroup  length=$5 label="Age Group"
		 Subject   length=8
		 WBC       length=8
		 RBC       length=8
		 Chol      length=8  label="Cholesterol" 
		 Review    length=$1 label="Review Code"
  ;
  input Subject BloodType AgeGroup WBC RBC Chol;
  BloodType=upcase(BloodType);
  if WBC ge 4000 and WBC le 11000 and 
     RBC ge 4.0 and RBC le 6.1 and 
     Chol gt 0 and 
     BloodType in ('A','B','AB','O') and 
     AgeGroup in ('Young','Old') then Review = .;
  else if missing(WBC) or missing(RBC) or missing(Chol) or missing(BloodType) or missing(AgeGroup) then Review = 'M';
  else Review = 'Y';
run;

* Produce summary statistics using PROC MEANS. Store summary using ODS OUTPUT;
ods output summary = HW08.BloodSummary;
proc means data = HW08.Blood mean median min max;
  var WBC Chol;
  class BloodType;
run;

* Create the array for report 3;
data HW08.BloodArray;
  set HW08.BloodSummary;
  array TestCodes[2] VName_WBC VName_Chol;
  array Means[*] WBC_Mean Chol_Mean;
  array Medians[*] WBC_Median Chol_Median;
  array Minimums[*] WBC_Min Chol_Min;
  array Maximums[*] WBC_Max Chol_Max;

  do i = 1 to dim(Means);
    TestCode = upcase(TestCodes[i]);
    MeanStats = Means[i];
	MedianStats = Medians[i];
	MinimumStats = Minimums[i];
	MaximumStats = Maximums[i];
	output;
  end;
  keep BloodType TestCode MeanStats MedianStats MinimumStats MaximumStats;
run;

* Produce report 1;
ods noproctitle;
options obs=5;
ods rtf file = "HW08/HW8 Nikiforov Report 1.rtf";
title;
footnote "Header (n=5) of bloodwork data set.";
footnote2 "Only using records in need of a review.";
proc report data = HW08.Blood nowd;
  columns Subject WBC RBC Chol Review;
  define Subject / "Subject Number";
  define WBC / "White Blood Cells" format = comma6.;
  define RBC / "Red Blood Cells";
  define Chol / "Cholesterol Level";
run;
footnote;
ods rtf close;
options obs=max;

* Produce report 2 using summary statistics from ODS OUTPUT;
ods rtf file = "HW08/HW8 Nikiforov Report 2.rtf";
title "WBC and Cholesterol Summarized by Blood Group";
title2 "(Ignoring Rhesus Factor)";
proc report data = HW08.BloodSummary nowd;
  columns BloodType WBC_Mean WBC_Median WBC_Min WBC_Max Chol_Mean Chol_Median Chol_Min Chol_Max;
  define BloodType / "Blood Group (Ignoring Rhesus Factor)" group;
  define WBC_Mean / "Mean White Blood Cell Count" format = 7.2;
  define WBC_Median / "Median White Blood Cell Count" format = 6.1;
  define WBC_Min / "Minimum White Blood Cell Count";
  define WBC_Max / "Maximum White Blood Cell Count";
  define Chol_Mean / "Mean Cholesterol Level" format = 6.2;
  define Chol_Median / "Median Cholesterol Level" format = 5.1;
  define Chol_Min / "Minimum Cholesterol Level";
  define Chol_Max / "Maximum Cholesterol Level";
run;
title;
ods rtf close;

* Produce report 3;
options nodate;
ods rtf file = "HW08/HW8 Nikiforov Report 3.rtf";
title "WBC and Cholesterol Summarized by Blood Group";
footnote "Note: Rhesus factor was not considered";
proc report data = HW08.BloodArray nowd;
  columns BloodType TestCode MeanStats MedianStats MinimumStats MaximumStats;
  define BloodType / "Blood Group (Ignoring Rhesus Factor)" group;
  define TestCode / 'Test Code';
  define MeanStats / "Mean" format = 7.2;
  define MedianStats / "Median" format = 6.1;
  define MinimumStats / "Minimum" format = 6.1;
  define MaximumStats / "Maximum" format = 7.1;
run;
title;
footnote;
ods rtf close;

/* Produce report 4*/
* Start with first report, fit 4 columns per page;
options nodate;
ods pdf file = "HW08/HW8 Nikiforov Report 4.pdf" columns=4;
title "Selected Summaries of WBC and Cholesterol";
proc report data = HW08.Blood nowd;
  columns Subject WBC Chol;
  define Subject / "Subject Number" display;
  define WBC / "White Blood Cells" format = comma6.;
  define Chol / "Cholesterol Level";
  where Review ne '.';
run;

* Return to one column per page;
ods pdf columns=1;

* Add second report;
options pageno=1;
proc report data = HW08.BloodSummary nowd;
  columns BloodType WBC_Mean WBC_Median WBC_Min WBC_Max Chol_Mean Chol_Median Chol_Min Chol_Max;
  define BloodType / "Blood Group (Ignoring Rhesus Factor)" group;
  define WBC_Mean / "Mean White Blood Cell Count" format = 7.2;
  define WBC_Median / "Median White Blood Cell Count" format = 6.1;
  define WBC_Min / "Minimum White Blood Cell Count";
  define WBC_Max / "Maximum White Blood Cell Count";
  define Chol_Mean / "Mean Cholesterol Level" format = 6.2;
  define Chol_Median / "Median Cholesterol Level" format = 5.1;
  define Chol_Min / "Minimum Cholesterol Level";
  define Chol_Max / "Maximum Cholesterol Level";
run;

* Add third and final report;
options pageno=1;
proc report data = HW08.BloodArray nowd;
  columns BloodType TestCode MeanStats MedianStats MinimumStats MaximumStats;
  define BloodType / "Blood Group (Ignoring Rhesus Factor)" order;
  define TestCode / 'Test Code';
  define MeanStats / "Mean" format = 7.2;
  define MedianStats / "Median" format = 6.1;
  define MinimumStats / "Minimum" format = 6.1;
  define MaximumStats / "Maximum" format = 7.1;
run;

ods pdf close;

quit;
