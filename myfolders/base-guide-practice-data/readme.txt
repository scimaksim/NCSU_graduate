/*******************************************************************\           
| Copyright (C) 2018 by SAS Institute Inc., Cary, NC, USA.          |           
|                                                                   |           
| SAS (R) is a registered trademark of SAS Institute Inc.           |           
|                                                                   |           
|This readme file contains instructions for creating practice data  |
|sets, Excel Files, CSV, and TXT files for some of the examples in: |
| - SAS Certification Prep Guide: Base Programming for SAS 9        |
|       							    |
|                                                                   |
| Last updated: September 4, 2018                                   |
\*******************************************************************/  

CONTENTS OF THIS FILE
---------------------
   
 * Requirements
 * Practice Data ZIP File
 * Instructions

REQUIREMENTS
-----------------------
To complete the examples in this book, you must have access to SAS Studio, SAS Enterprise Guide, or the SAS windowing environment. 


Practice Data ZIP File
----------------------
The ZIP file includes SAS data sets, SAS programs, Microsoft Excel workbooks (.xlsx), CSV files (.csv), and TXT files (.txt) files that are used in the examples throughout this book.
To access the files that are used in this book, follow the instructions to create the practice data. 


INSTRUCTIONS
------------------------
1. Unzip the practice-data zip file to a location that is accessible to SAS.
2. Open the cre8data.sas program in the SAS environment of your choice.
	-SAS Studio: In the Navigation pane, expand Files and Folders and then navigate to the Cert folder in the practice-data folder.
	-SAS Enterprise Guide: In the Servers list, expand Servers > Local > Files, and then navigate to the Cert folder in the practice-data folder.
	-SAS windowing environment: Click File > Open Program, and then navigate to the Cert folder in the practice-data folder.
3. In the Path macro variable, replace /folders/myfolders with the path to the cert folder and run the program.
	%let path=/folders/myfolders/cert;

Note:The location you specify for the Path macro variable and the location of your downloaded SAS programs should be the same location. Otherwise, the cre8data.sas cannot create the practice data.

Your practice data is now created and ready for you to use.

Tip: When you end your SAS session, the Path macro variable in the cre8data.sas program is reset. To avoid having to rerun cre8data.sas every time, run the libname.sas program from the Cert folder to restore the libraries.