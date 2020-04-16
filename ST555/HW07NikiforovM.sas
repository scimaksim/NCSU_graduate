/*
Author: Maksim V. Nikiforov
Date Created: 2020-04-02
Purpose: Homework 07

Modification Date: N/A
Reason for Modification: N/A
*/

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
libname InputDS 'Data'; 
libname Results 'Results';
filename RawData 'Data';

* Establish librefs and filerefs for HW07;
x 'cd C:\Users\mvnikifo\';
libname HW07 'HW07';
filename HW07 'HW07';

* Search for formats within the InputDS library;
options fmtsearch=(InputDS);

/* Create SO2 data set from raw CSV file. Extract day of observation using the "scan" method and 
increment date using the "intnx" method described in chapter 4 of the textbook */
data HW07.SO2;
  infile RawData("EPA Data.csv") dsd firstobs=7 truncover;
  attrib date         format=YYMMDD10. label="Observation Date"
         siteid                        label="Site ID"
		 poc                           label="Parameter Occurance Code (Instrument Number within Site and Parameter)"
		 aqscode                       label="AQS Parameter Code"
		 aqsabb       length=$4        label="AQS Parameter Abbreviation"
		 aqsdesc      length=$40       label="AQS Measurement Description"
		 aqs                           label="AQS Observed Value"
		 aqi                           label="Daily Air Quality Index Value"
		 count                         label="Daily AQS Observations"
  ;
  input siteid aqscode poc 
        / day $
        / aqs 4-7
        / aqi 4
        / count 6-7;
  day=input(scan(day,1,,'lu'),8.);
  date=intnx('day', '31DEC2018'd, day, 'beginning');
  drop day;
  aqsabb='SO2';
  aqsdesc='Daily Max 1-hour SO2 Concentration';
  stcode=input(substr(put(siteid,9.),1,2),8.);
  countycode=input(substr(put(siteid,9.),3,3),8.);
  sitenum=input(substr(put(siteid,9.),6),8.);
run;

* Create O3 data set;
data HW07.O3;
  infile RawData("EPA Data (1).csv") dsd firstobs=2;
  attrib date         format=YYMMDD10. informat=mmddyy8. label="Observation Date"
         siteid                                          label="Site ID"
		 poc                                             label="Parameter Occurance Code (Instrument Number within Site and Parameter)"
		 aqscode                                         label="AQS Parameter Code"
		 aqsabb       length=$4                          label="AQS Parameter Abbreviation"
		 aqsdesc      length=$40                         label="AQS Measurement Description"
		 aqs                                             label="AQS Observed Value"
		 aqi                                             label="Daily Air Quality Index Value"
		 count                                           label="Daily AQS Observations"
  ;
  input date siteid poc aqs aqi count aqscode;
  aqsabb='O3';
  aqsdesc="Daily Max 8-hour Ozone Concentration";
  stcode=input(substr(put(siteid,9.),1,2),8.);
  countycode=input(substr(put(siteid,9.),3,3),8.);
  sitenum=input(substr(put(siteid,9.),6),8.);
run;

/* Create CO data set. Increment dates by 1 using intx function from textbook's section 4.6. 
Omit observations with missing AQS/AQI/count values */
data HW07.CO;
  infile RawData("EPA Data (2).csv") dsd firstobs=6 truncover;
  attrib date         format=YYMMDD10. label="Observation Date"
         siteid                        label="Site ID"
		 poc                           label="Parameter Occurance Code (Instrument Number within Site and Parameter)"
		 aqscode                       label="AQS Parameter Code"
		 aqsabb       length=$4        label="AQS Parameter Abbreviation"
		 aqsdesc      length=$40       label="AQS Measurement Description"
		 aqs                           label="AQS Observed Value"
		 aqi                           label="Daily Air Quality Index Value"
		 count                         label="Daily AQS Observations"
  ;
  aqsabb='CO';
  aqsdesc='Daily Max 8-hour CO Concentration';
  input siteid aqscode poc aqs aqi count @;
  do day=1 to 244;
    date=intnx('day', '31DEC2018'd, day, 'beginning');
	stcode=input(substr(put(siteid,9.),1,2),8.);
    countycode=input(substr(put(siteid,9.),3,3),8.);
    sitenum=input(substr(put(siteid,9.),6),8.);
	if not missing(aqs) and not missing(aqi) and not missing(count) then output;
    input aqs aqi count @;
  end;
  drop day;

run;

* Transform existing horizontal PM10 data into vertical set to prepare for merging;
proc transpose data = InputDS.PM10 out=PM10(rename=(COL1=aqs COL2=aqi COL3=count _NAME_=day));
  by SiteID aqscode poc;
run;

/* Clean up new vertical PM10 data set. Extract day of observation and 
increment date (formatted as YYMMDD10). Omit observations with missing AQS/AQI/count values */
data HW07.PM10;
  set PM10;
  attrib date         format=YYMMDD10. label="Observation Date"
         siteid                        label="Site ID"
		 poc                           label="Parameter Occurance Code (Instrument Number within Site and Parameter)"
		 aqscode                       label="AQS Parameter Code"
		 aqsabb       length=$4        label="AQS Parameter Abbreviation"
		 aqsdesc      length=$40       label="AQS Measurement Description"
		 aqs                           label="AQS Observed Value"
		 aqi                           label="Daily Air Quality Index Value"
		 count                         label="Daily AQS Observations"
  ;
  day=input(scan(day,1,,'lu'),8.);
  format date YYMMDD10.;
  date=intnx('day', '31DEC2018'd, day, 'beginning');
  drop day;
  aqsabb='PM10';
  aqsdesc="Daily Mean PM10 Concentration";
  stcode=input(substr(put(siteid,9.),1,2),8.);
  countycode=input(substr(put(siteid,9.),3,3),8.);
  sitenum=input(substr(put(siteid,9.),6),8.);
  if not missing(aqs) and not missing(aqi) and not missing(count) then output;
run;

/* Combine concentration data. Concatenate CO last to
ensure that SiteID remains in sorted order */ 
data HW07.Combined;
 set HW07.SO2 HW07.O3 HW07.PM10 HW07.CO ;
run;

* Merge combined concentration data with the "AQSSites" helper file;
data HW07.MergedCombined;
  merge HW07.Combined(in=inMergedCombined)
        InputDS.AQSSites(in=inAQSSites);
  by stcode countycode sitenum;
  drop stcode countycode sitenum;
  if inMergedCombined then output;
run;

/* Sort "Methods" helper file using AQSCode, direct output to a 
new data set to avoid overwriting the original */
proc sort data=InputDS.Methods out=HW07.SortedMethods;
  by aqscode;
run;

* Sort combined concentration data using AQSCode to prepare for subsequent merging;
proc sort data=HW07.MergedCombined out=HW07.SortedMergedCombined;
  by aqscode;
run;

/* Merge combined and sorted concentration data with sorted "Methods" helper file. 
Direct complete output to HW07.FinalNikiforov data set, direct 
subset where percent=100 to HW07.FinalNikiforov100 */
data HW07.FinalNikiforov HW07.FinalNikiforov100;
  informat date;
  attrib date         format=YYMMDD10. label="Observation Date"
         siteid                        label="Site ID"
		 poc                           label="Parameter Occurance Code (Instrument Number within Site and Parameter)"
		 aqscode                       label="AQS Parameter Code"
		 parameter    length=$50       label="AQS Parameter Name"
		 aqsabb       length=$4        label="AQS Parameter Abbreviation"
		 aqsdesc      length=$40       label="AQS Measurement Description"
		 aqs                           label="AQS Observed Value"
		 aqi                           label="Daily Air Quality Index Value"
		 aqidesc      length=$30       label="Daily AQI Category"
		 count                         label="Daily AQS Observations"
		 percent                       label="Percent of AQS Observations (100*Observed/24)"
		 mode         length=$50       label="Measurement Mode"
		 collectdescr length=$50       label="Description of Collection Process"
		 analysis     length=$50       label="Analysis Technique"
		 mdl                           label="Federal Method Detection Limit"
		 localName    length=$50       label="Site Name"
		 lat                           label="Site Latitude"
		 long                          label="Site Longitude"
		 stabbrev     length=$50       label="State Abbreviation"
		 countyname   length=$50       label="County Name"
		 cityname     length=$50       label="City Name"
		 estabdate    format=YYMMDD10. label="Site Established Date"
		 closedate    format=YYMMDD10. label="Site Closed Date"
	;
  merge HW07.SortedMergedCombined(in=inSortedMergedCombined) 
        HW07.SortedMethods(in=inSortedMethods);
  by aqscode;
  if inSortedMergedCombined and inSortedMethods;  
  CollectDescr = propcase(CollectDescr);
  Analysis = propcase(Analysis);
  percent=round((100*count/24));
  cityname = scan(CBSAName, 1, ',');
  stabbrev = scan(CBSAName, 2, ',');
  drop CBSAName;
  aqidesc=put(aqi, aqicat.);
  if inSortedMergedCombined and inSortedMethods then output HW07.FinalNikiforov;
  if percent=100 then output HW07.FinalNikiforov100;
run;

* Compare complete data set against instructor's;
proc compare base=Results.HW7finalduggins compare=HW07.FinalNikiforov
             out=HW07.CompareFinal outbase outcompare outdif
			 method=absolute criterion=1E-15;
run;

* Compare partial data set (percent=100) against instructor's;
proc compare base=Results.HW7finalduggins100 compare=HW07.FinalNikiforov100
             out=HW07.CompareFinal outbase outcompare outdif
			 method=absolute criterion=1E-15;
run;

* Generate data set for the descriptor;  
ods exclude EngineHost SortedBy Attributes;
ods output Position = HW07.ContentsFinalNikiforov(drop=Member);
proc contents data=HW07.FinalNikiforov varnum;
run; 

* COmpare the data set with the descriptor against instructor's;
proc compare base=Results.HW7dugginsdesc compare=HW07.ContentsFinalNikiforov
             out=HW07.CompareDescriptor outbase outcompare outdif
			 method=absolute criterion=1E-15;
run;

quit;
