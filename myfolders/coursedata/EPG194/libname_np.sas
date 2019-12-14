libname NP xlsx "/folders/myfolders/coursedata/EPG194/data/np_info.xlsx";
run;

options validvarname=v7;

proc contents data=np.parks;
run;

libname np clear;




