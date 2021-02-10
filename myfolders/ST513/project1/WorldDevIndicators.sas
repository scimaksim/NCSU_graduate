*********************

*********************;
LIBNAME ST513 '/folders/myfolders/ST513';

FILENAME REFFILE 'https://www4.stat.ncsu.edu/~online/datasets/StudentData.txt';

DATA REFFILE;
  SET ST513.WorldDevIndicators;
RUN;


******************************************;
DATA ST513.GlobalDeathRate;
  SET ST513.WorldDevIndicators;
  WHERE (Indicator_Name = 'Number of deaths ages 10-14 years' AND (Year = 1990 OR Year = 2000 OR Year = 2017))OR (Indicator_Name = 'Number of deaths ages 5-9 years' AND (Year = 1990 OR Year = 2000 OR Year = 2017));
RUN;

PROC SGPLOT DATA=ST513.GlobalDeathRate;
  VBAR Year / RESPONSE = Value
      group=year;
RUN;
******************************************;

DATA ST513.SurgicalWorkforce;
  SET ST513.WorldDevIndicators;
  WHERE Indicator_Name = 'Specialist surgical workforce (per 100,000 population)' AND (Country_Name = 'Low income' OR Country_Name = 'Lower middle income' OR Country_Name = 'Upper middle income' OR Country_Name = 'Middle income' OR Country_Name = 'High income');
RUN;

PROC SGPLOT DATA=ST513.SurgicalWorkforce;
  VBAR Country_Name / RESPONSE = Value;
RUN;
******************************************;


