* Author: Maksim V. Nikiforov;
* Date Created: 2020-04-25;
* Purpose: Final Exam;

* Modification Date: N/A;
* Reason for Modification: N/A;

* Establish librefs and filerefs for incoming data;
x 'cd L:\ST555';
libname InputDS 'Data'; 
libname Results 'Results';
filename RawData 'Data';

* Establish librefs and filerefs for HW08;
x 'cd C:\Users\mvnikifo\';
libname Final 'Final';
filename Final 'Final';

* Ingest raw Movies.dat file and output a SAS "Movies" data set;
data Final.NikiforovFinalMovies;
  infile RawData("Movies.dat") dsd dlm='09'x firstobs=7 truncover;
  attrib Title        length=$68 format=$68. label="Movie Title"
         Studio       length=$25 format=$25. label="Lead Studio Name"
         Rotten       length=8               label="Rotten Tomatoes Score"
         Audience     length=8               label="Audience Score"
		 ScoreDiff    length=8               label="Score Difference (Rotten - Audience)"
		 Theme        length=$18 format=$18. label="Movie Theme"
		 Genre        length=$9  format=$9.  label="Movie Genre"
		 _Scores_     length=$8
		 _GenreTheme_ length=$30
		 _Studio_     length=$250;
  ;
  input Title $
        / _Scores_ $
        / _GenreTheme_ $
        / _Studio_ $;
  Rotten = scan(_Scores_,1,'--');
  Audience = scan(_Scores_,2,'--');
  ScoreDiff = sum(Rotten, -Audience);
  Genre = scan(_GenreTheme_,1,'--');
  Theme = scan(_GenreTheme_,2,'--');
  Studio = compbl(_Studio_);
  drop _Scores_ _GenreTheme_ _Studio_;
run;

* Compare new data set against instructor's;
proc compare base=Results.DugginsFinalMovies compare=Final.NikiforovFinalMovies
             out=Final.CompareFinalMovie outbase outcompare outdif
			 method=absolute criterion=1E-10;
run;

* Generate statistics for min, max, ansd mean;
ods output summary = Final.MovieStats;
proc means data=Final.NikiforovFinalMovies min max mean;
  class Studio;
  var Rotten Audience;
run;

* Sort FinalMovies data set in alphabetical order by studio;
proc sort data=Final.NikiforovFinalMovies out=Final.SortedNikiforovFinalMovies;
  by Studio;
run;

* Create cross-frequency table;
ods output CrossTabFreqs = Final.CrossTabFreqMovies(drop=Table);
proc freq data=Final.NikiforovFinalMovies;
  table Studio*Genre;
run;

* Sort cross-frequency table using studio name;
proc sort data=Final.CrossTabFreqMovies out=Final.SortedCrossTabFreqMovies;
  by Studio;
run;

* Merge movie database with statistics, exclude the "adventure" genre;
data Final.Movies;
  merge Final.SortedNikiforovFinalMovies
        Final.MovieStats;
  by Studio;
  Rotten_Min_Max = cat('(', Rotten_Min, ', ', Rotten_Max, ')');
  Audience_Min_Max = cat('(', Audience_Min, ', ', Audience_Max, ')');
  Rotten_Mean_Char = put(Rotten_Mean,4.1);
  Audience_Mean_Char = put(Audience_Mean,4.1);
  if Genre ne 'Adventure';
  if Title ne '';
run;

* Create arrays for (Min, Max) and Mean fields to be used in tables;
data Final.TestMovies;
  set Final.Movies;
  array RottenMinsMaxsMeans[*] Rotten_Min_Max Rotten_Mean_Char;
  array AudienceMinsMaxsMeans[*] Audience_Min_Max Audience_Mean_Char;

  do i=1 to dim(RottenMinsMaxsMeans);
    RottenStats = RottenMinsMaxsMeans[i];
    AudienceStats = AudienceMinsMaxsMeans[i];
	if i = 1 then Description = '(Min, Max)';
	else if i =2 then Description = 'Mean';
    output; 
  end;  
run;

* Create custom format for first table;
proc format;
  value genre .=cxedf8e9
              0=cxedf8e9
              1=cxbae4b3
              2=cx74c476
              3=cx31a354
			  4-high=cx006d2c;
run;

* Create first table without colored studio fields;
ods listing close;
options nodate orientation=landscape;
ods pdf dpi = 300 file = "Final/Nikiforov COVID Final.pdf";
title "Genres and Movie Ratings by Studio";
title2 "Traficlighting based on Genre";
footnote j=l h=10pt "The Adventure genre was excluded as it only applied to one movie";

proc report data=Final.TestMovies nowd;
  columns Studio Description RottenStats AudienceStats Genre Color;
  define Studio / group 'Lead Studio Name'   
                  style=[cellwidth=1.6in];
  define Description / group 'Score Statistics'
                       style=[cellwidth=0.8in textalign=right];
  define RottenStats / group 'Rotten Tomatoes Score'
                       style=[cellwidth=0.8in textalign=center];
  define AudienceStats / group 'Audience Score'
                         style=[cellwidth=0.8in textalign=center];
  define Genre / across style(column)=[backgroundcolor=genre. textalign=center] ""; 
  define Color / computed noprint;
  compute Color;
	if _c5_ = '.' then _c5_ = '0';
	if _c5_ ge 3 then call define('_c5_','style','style=[color=cxFFFFFF]');
	if _c6_ = '.' then _c6_ = '0';
	if _c6_ ge 3 then call define('_c6_','style','style=[color=cxFFFFFF]');
	if _c7_ = '.' then _c7_ = '0';
	if _c7_ ge 3 then call define('_c7_','style','style=[color=cxFFFFFF]');
	if _c8_ = '.' then _c8_ = '0';
	if _c8_ ge 3 then call define('_c8_','style','style=[color=cxFFFFFF]');
	if _c9_ = '.' then _c9_ = '0';
	if _c9_ ge 3 then call define('_c9_','style','style=[color=cxFFFFFF]');
	if _c10_ = '.' then _c10_ = '0';
	if _c10_ ge 3 then call define('_c10_','style','style=[color=cxFFFFFF]');
	if _c11_ = '.' then _c11_ = '0';
	if _c11_ ge 3 then call define('_c11_','style','style=[color=cxFFFFFF]');
	if _c12_ = '.' then _c12_ = '0';
	if _c12_ ge 3 then call define('_c12_','style','style=[color=cxFFFFFF]');
  endcomp;
run;

title;
footnote;

* Create second report with colored studio fields;
title "Genres and Movie Ratings by Studio";
title2 "Traficlighting based on Genre and Average Rotten Tomatoes Score";
footnote j=l h=10pt "The Adventure genre was excluded as it only applied to one movie";
footnote2 j=l h=10pt "Studio Color Key: Below 60 (Darkest), 60-70, 70-80, 80-90, 90-100 (Lightest)";
footnote3 j=l h=10pt "Studio names were colored based on mean Rotten Tomatoes score using intervals that excluded the right endpoint";

proc report data=Final.TestMovies nowd;
  columns Studio Description Rotten_Mean RottenStats AudienceStats Genre GenreColor StudioColor;
  define Studio / group 'Lead Studio Name'
                  style=[cellwidth=1.6in];
  define Description / group 'Score Statistics'
                       style=[cellwidth=0.8in textalign=right];
  define Rotten_Mean / noprint group 'RottenMean';
  define RottenStats /  group 'Rotten Tomatoes Score'
                        style=[cellwidth=0.8in textalign=center];
  define AudienceStats / group 'Audience Score'
                         style=[cellwidth=0.8in textalign=center];
  define Genre / across style(column)=[backgroundcolor=genre. textalign=center] "Frequency By Genre"; 
  define GenreColor / computed noprint;
  define StudioColor / computed noprint;
  compute GenreColor;
	if _c6_ = '.' then _c6_ = '0';
	if _c6_ ge 3 then call define('_c6_','style','style=[color=cxFFFFFF]');
	if _c7_ = '.' then _c7_ = '0';
	if _c7_ ge 3 then call define('_c7_','style','style=[color=cxFFFFFF]');
	if _c8_ = '.' then _c8_ = '0';
	if _c8_ ge 3 then call define('_c8_','style','style=[color=cxFFFFFF]');
	if _c9_ = '.' then _c9_ = '0';
	if _c9_ ge 3 then call define('_c9_','style','style=[color=cxFFFFFF]');
	if _c10_ = '.' then _c10_ = '0';
	if _c10_ ge 3 then call define('_c10_','style','style=[color=cxFFFFFF]');
	if _c11_ = '.' then _c11_ = '0';
	if _c11_ ge 3 then call define('_c11_','style','style=[color=cxFFFFFF]');
	if _c12_ = '.' then _c12_ = '0';
	if _c12_ ge 3 then call define('_c12_','style','style=[color=cxFFFFFF]');
	if _c13_ = '.' then _c13_ = '0';
	if _c13_ ge 3 then call define('_c13_','style','style=[color=cxFFFFFF]');
  endcomp;

  compute StudioColor;
    StudioColor = Rotten_Mean;
	if StudioColor lt 60 then call define('_c1_','style','style=[backgroundcolor=cxa50f15 color=cxFFFFFF]');
	if StudioColor ge 60 and StudioColor lt 70 then call define('_c1_','style','style=[backgroundcolor=cxde2d26 color=cxFFFFFF]');
	if StudioColor ge 70 and StudioColor lt 80 then call define('_c1_','style','style=[backgroundcolor=cxfb6a4a color=cxFFFFFF]');
	if StudioColor ge 80 and StudioColor lt 90 then call define('_c1_','style','style=[backgroundcolor=cxfc9272 color=cxFFFFFF]');
	if StudioColor ge 90 then call define('_c1_','style','style=[backgroundcolor=cxfcbba1 color=cxFFFFFF]');
  endcomp;
run;

title;
footnote;

* Set graphic size, create vbar plot;
ods graphics / reset width = 9in height = 7.5in;

proc sgplot data = Final.NikiforovFinalMovies;
  vbar Genre / response = ScoreDiff
               stat = median
               fillattrs = (color = aqua)
               outlineattrs = (color = aqua);
  yaxis label = 'Median Score Difference (Rotten - Audience)' 
        labelattrs = (size = 16pt) valueattrs = (size = 12pt);
  xaxis label = 'Movie Genre' 
        labelattrs = (size = 16pt) valueattrs = (size = 12pt);
run;

ods pdf close;
ods listing;

quit;
