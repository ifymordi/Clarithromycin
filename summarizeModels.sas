x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/summarizeModels.html" style = Statistical;
ods rtf body = "output/summarizeModels.rtf" style = Statistical;

libname lib "data/processed";


title1 "Model summaries";
title2 "Only the Clarithromycin exposure parameter shown";


proc sql;
  create table lib.modelSummaries as
    select * from lib.phregMortalityAllCause union corr
	select * from lib.phregMortalityCV union corr
	select * from lib.phregHospVentArrhythmia union corr
	select * from lib.phregHospSuddenCardiacArrest union corr
	select * from lib.phregHospMI union corr
	select * from lib.phregHospCV;
  alter table lib.modelSummaries add outcomeTimeFrame varchar(7);
  update lib.modelSummaries 
    set outcomeTimeFrame = case
                             when prxmatch("/1-year/", outcome) then "1 year"
                             when prxmatch("/30-day/", outcome) then "30 days"
                             when prxmatch("/14-day/", outcome) then "14 days"
                             else ""
                             end;
  select * from lib.modelSummaries where parameter = "exposure";
quit;

proc export data = lib.modelSummaries outfile = "data/processed/modelSummaries.csv" dbms = csv replace;
  delimiter = ",";
run;


ods html close;
ods rtf close;
