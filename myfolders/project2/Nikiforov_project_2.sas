**********
SAS program to process USEuropeCars.csv for ST513 mini-project 2
REFLINE colors in SGPLOT referenced at 
https://blogs.sas.com/content/iml/2017/02/06/group-colors-sgplot.html

Authored by Maksim Nikiforov
March, 2021
**********;

* Create a permanent library;
LIBNAME ST513 '/folders/myfolders/ST513/project2';

* Read data into a temporary library;
FILENAME REFFILE '/folders/myfolders/ST513/project2/USEuropeCars.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=USEuropeCars;
	GETNAMES=YES;
RUN;

/* Create a data set in the permanent library. Label the variables
for display in the Jupyter notebook.
Remove the observation variable. 
Remove the observation that has Asia as the region.
Remove the outlier where mpg_before = 999 */
DATA ST513.USEuropeCars;
	SET USEuropeCars;
	DROP observation;
	WHERE region NE "Asia";
	IF mpg_before = 999 OR mpg_after = 999 then delete;
	average_mpg = (mpg_before + mpg_after)/2;
	LABEL horsepower="The horsepower of the car"
	      region="Where the car is from - USA, Europe"
	      mpg_before="The average miles per gallon before the car reached 75,000 miles"
	      mpg_after="The average miles per gallon after the car reached 75,000 miles"
	      average_mpg="Average gas mileage";
RUN;

/* Create histograms for horsepower, mpg_before, mpg_after, and average mpg.
Include different coloring for each region. Overlay smoothed density plots.*/

*Histogram for horsepower with different coloring for each region and smoothed density plots;
PROC SGPLOT DATA = ST513.USEuropeCars;
  HISTOGRAM horsepower / GROUP = region
                         TRANSPARENCY = 0.6;
  DENSITY horsepower / GROUP = region
                       TYPE = kernel;
  REFLINE 268.5 / AXIS = x
                 LABEL = "268.5"
                 LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cx445694);
  REFLINE 223.35 / AXIS = x
                  LABEL = "223.4"
                  LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cxA23A2E);
  XAXIS LABEL = "horsepower";
RUN;

* Calculate means for horsepower REFLINE;
PROC MEANS DATA=ST513.USEuropeCars MEAN MEDIAN;
  CLASS region;
  VAR horsepower;
RUN;

*Histogram for mpg_before;
PROC SGPLOT DATA = ST513.USEuropeCars;
  HISTOGRAM mpg_before / GROUP = region
                         TRANSPARENCY = 0.6;
  DENSITY mpg_before / GROUP = region
                       TYPE = kernel;
  REFLINE 29.4 / AXIS = x
                 LABEL = "29.40"
                 LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cx445694);
  REFLINE 32.96 / AXIS = x
                  LABEL = "32.96"
                  LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cxA23A2E);
  XAXIS LABEL = "mpg_before";
RUN;

* Calculate means for mpg_before REFLINE;
PROC MEANS DATA=ST513.USEuropeCars MEAN MEDIAN;
  CLASS region;
  VAR mpg_before;
RUN;

*Histogram for mpg_after;
PROC SGPLOT DATA = ST513.USEuropeCars;
  HISTOGRAM mpg_after / GROUP = region
                         TRANSPARENCY = 0.6;
  DENSITY mpg_after / GROUP = region
                       TYPE = kernel;
  REFLINE 29.46 / AXIS = x
                 LABEL = "29.46"
                 LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cx445694);
  REFLINE 32.94 / AXIS = x
                  LABEL = "32.94"
                  LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cxA23A2E);
  XAXIS LABEL = "mpg_after";
RUN;

* Calculate means for mpg_after REFLINE;
PROC MEANS DATA=ST513.USEuropeCars MEAN MEDIAN;
  CLASS region;
  VAR mpg_after;
RUN;

*Histogram for average_mpg;
PROC SGPLOT DATA = ST513.USEuropeCars;
  HISTOGRAM average_mpg / GROUP = region
                         TRANSPARENCY = 0.6;
  DENSITY average_mpg / GROUP = region
                       TYPE = kernel;
  REFLINE 29.46 / AXIS = x
                 LABEL = "29.46"
                 LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cx445694);
  REFLINE 32.95 / AXIS = x
                  LABEL = "32.95"
                  LINEATTRS = (Pattern = 4
                              Thickness = 3
                              Color = cxA23A2E);
  XAXIS LABEL = "average_mpg";
RUN;

* Calculate means for average_mpg REFLINE;
PROC MEANS DATA=ST513.USEuropeCars MEAN MEDIAN;
  CLASS region;
  VAR average_mpg;
RUN;

/* Create scatterplots to assess the relationship between the numeric variable. Color
the points by the region variable (check SGSCATTER procedure). */
PROC SGSCATTER DATA=ST513.USEuropeCars;
  PLOT average_mpg*horsepower / GROUP=region;
RUN;

PROC CORR DATA=ST513.USEuropeCars;
    VAR average_mpg horsepower;
RUN;

* Fit a gamma distribution to the horsepower variable;
PROC UNIVARIATE DATA=ST513.USEuropeCars ;
      VAR horsepower;
      CDFPLOT / GAMMA;
      QQPLOT / GAMMA(ALPHA=EST THRESHOLD=EST SCALE=EST);
RUN;

* Fit a gamma distribution to the mpg_before variable;
PROC UNIVARIATE DATA=ST513.USEuropeCars;
      VAR mpg_before;
      CDFPLOT / GAMMA;
      QQPLOT / GAMMA(ALPHA=EST);
RUN;

* Fit a weibull distribution to the mpg_before variable;
PROC UNIVARIATE DATA=ST513.USEuropeCars;
      VAR mpg_before;
      CDFPLOT / WEIBULL;
      QQPLOT / WEIBULL(C=EST THRESHOLD=EST SCALE=EST);
RUN;

* Create a 90% confidence interval for the mean horsepower for all cars;
PROC MEANS DATA=ST513.USEuropeCars MEAN CLM ALPHA=0.1;
  VAR horsepower;
RUN;

* Create a 95% confidence interval to inspect the relationship between
the average overall gas mileage between European and US cars;
PROC TTEST DATA=ST513.USEuropeCars PLOTS = all;
	CLASS region;
	VAR average_mpg;
RUN;

* Create a 99% confidence interval to investigate the average of the
differences between after and before gas mileage;
PROC TTEST DATA=ST513.USEuropeCars PLOTS = all ALPHA=0.01;
	PAIRED mpg_after*mpg_before;
RUN;