proc sort data=pg1.eu_occ (keep=Geo Country) out=countrylist nodupkey;
  by Geo Country;
run;