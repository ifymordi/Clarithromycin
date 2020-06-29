x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/importEchoData.html" style = Statistical;
ods rtf body = "output/importEchoData.rtf" style = Statistical;

libname lib "data/processed";

proc import datafile = "2018-04-24_LINK-4385\Echo Data 220318_11745\Echo (Tayside to March 2013)\ECHO_Tayside_Mar13.csv"
            out = lib.ECHO_Tayside_Mar13
            dbms = csv
            replace;
  guessingrows = all;
run;
proc contents data = lib.ECHO_Tayside_Mar13 order = varnum;
run;


proc import datafile = "2018-04-24_LINK-4385\Echo Data 220318_11745\Echo (Tayside From Nov 2014 - Cardio Reporting System)\ECHO_Tayside_2014.csv"
            out = lib.ECHO_Tayside_2014
            dbms = csv
            replace;
  guessingrows = all;
run;
proc contents data = lib.ECHO_Tayside_2014 order = varnum;
run;


proc sql;
  create table lib.ECHO_Tayside as
    select prochi, 
           . format = datetime. as saveTime, 
           DatePerformed format = datetime. as eventDt,  
           Conclusion as comments,  
           LVFunction as left_ventricle,  
           LVIDD as lviddundefined,  
           LeftAtrium as atria,  
           input(LA, 8.2) as la_dimensionundefined,  
           input(EA, 8.2) as mv_ea,  
           MVRegurgitation as mitral_valve,  
           AVRegurgitation as aortic_valve 
    from lib.ECHO_Tayside_Mar13 
    union corr
    select prochi, saveTime, eventDt, comments, left_ventricle, lviddundefined, atria, la_dimensionundefined, mv_ea, mitral_valve, aortic_valve
    from lib.ECHO_Tayside_2014;
quit;
proc contents data = lib.ECHO_Tayside order = varnum;
run;


proc format;
  value $missfmt " " = "MISSING" other = "Not missing";
  value missfmt   .  = "MISSING" other = "Not missing";
run;
proc freq data = lib.ECHO_Tayside;
  format _char_ $missfmt.;
  tables _char_ / missing missprint;
  format _numeric_ missfmt.;
  tables _numeric_ / missing missprint;
run;
proc freq data = lib.ECHO_Tayside;
  format EventDt savetime dtyear4.;
  table EventDt savetime;
run;


ods html close;
ods rtf close;
