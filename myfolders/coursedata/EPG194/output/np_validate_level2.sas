/* Invalid values for Reg:  */
/* Invalid values for Type:  */

proc freq data=pg1.np_summary;
 tables Reg Type;
run;

/* Smallest park: observation 78 */
/* Largest park: observation 6 */
proc univariate data=pg1.np_summary;
  var Acres;
run;

/* Name of smallest park: */
/* Size of smallest park */

/* Name of largest park: */
/* Size of largest park: */
proc print data=pg1.np_summary;
run;
