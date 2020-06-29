x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/buildEchoVariables.html" style = Statistical;
ods rtf body = "output/buildEchoVariables.rtf" style = Statistical;

libname lib "data/processed";


proc format;
  value echo6cat
    0 = "Normal"
	1 = "Mild"
	2 = "Mild-Moderate"
	3 = "Moderate"
	4 = "Moderate-Severe"
	5 = "Severe";
  value echo4cat
    0 = "Normal"
	1 = "Mild"
	2 = "Moderate"
	3 = "Severe";
run;


%let regex1 = (\s*|\s*lv\s*)(systolic|impairment);
%let regex2 = (\s*|\s*concentric\s*)(hypertroph|lvh);
%let regex3 = (?<!un)dilat(ed|ion);
%let regex4 = \s*(mitral|aortic)\s+(stenosis|regurgitation);


proc sql;
  create table Work.echo as
    select A.indexID,
           A.prochi,
           A.indexStart,
	       B.saveTime,
		   B.eventDt,
		   strip(B.left_ventricle) || "***" || strip(B.comments) as lvText,
		   case
		     when prxmatch("/severe(ly)*&regex1/", lower(calculated lvText)) then 3
		     when prxmatch("/moderate(ly)*&regex1/", lower(calculated lvText)) then 2
		     when prxmatch("/mild(ly)*&regex1/", lower(calculated lvText)) then 1
			 else 0
			 end format = echo4cat. as lvefGrade,
		   calculated lvefGrade > 0 | prxmatch("/lvsd code 0/", lower(calculated lvText)) as lvFunctionImpaired,
		   case
		     when prxmatch("/severe(ly)*&regex2/", lower(calculated lvText)) then 3
		     when prxmatch("/moderate(ly)*&regex2/", lower(calculated lvText)) then 2
		     when prxmatch("/(mild(ly)*)*&regex2/", lower(calculated lvText)) then 1
			 else 0
			 end format = echo4cat. as lvhGrade,
		   calculated lvhGrade > 0 as lvHypertrophy,
		   B.lviddundefined,
		   prxmatch("/&regex3 lv/", lower(calculated lvText)) | 
		     prxmatch("/\s*lv&regex3/", lower(calculated lvText)) |
             B.lviddundefined > 6
             as lvDilated,
		   strip(B.atria) || "***" || strip(B.comments) as atriaText,
		   B.la_dimensionundefined,
		   prxmatch("/&regex3 la/", lower(calculated atriaText)) |
		     prxmatch("/\s*la&regex3/", lower(calculated atriaText)) |
             B.la_dimensionundefined > 4
             as laDilated,
		   B.mv_ea,
		   B.mv_ea > 1 as mveaAbnormal,
		   strip(B.mitral_valve) || "***" || strip(B.aortic_valve) || "***" || strip(B.comments) as valveDiseaseText,
		   case
		     when prxmatch("/severe(ly)*&regex4/", lower(calculated valveDiseaseText)) then 3
		     when prxmatch("/moderate(ly)*&regex4/", lower(calculated valveDiseaseText)) then 2
		     when prxmatch("/mild(ly)*&regex4/", lower(calculated valveDiseaseText)) then 1
			 else 0
			 end format = echo4cat. as valveDiseaseGrade,
		   calculated valveDiseaseGrade > 1 as valveDiseaseModSev,
		   calculated valveDiseaseGrade > 0 as valveDiseaseAny
      from lib.exposureTimelines A inner join 
           lib.ECHO_Tayside B on (A.prochi = B.prochi &
                                  intnx("year", A.indexStart, -1, "sameday") <= datepart(B.eventDt) < A.indexStart);
  create table Work.denom as select count(*) as denom from Work.echo;
  select lvFunctionImpaired, lvefGrade, count(*) as n, count(*) / (select denom from Work.denom) format = percent8.1 as pct
    from Work.echo
    group by lvFunctionImpaired, lvefGrade;
  select lvHypertrophy, lvhGrade, count(*) as n, count(*) / (select denom from Work.denom) format = percent8.1 as pct
    from Work.echo
    group by lvHypertrophy, lvhGrade;
  select lvDilated, count(*) as n, count(*) / (select denom from Work.denom) format = percent8.1 as pct
    from Work.echo
    group by lvDilated;
  select laDilated, count(*) as n, count(*) / (select denom from Work.denom) format = percent8.1 as pct
    from Work.echo
    group by laDilated;
  select mveaAbnormal, count(*) as n, count(*) / (select denom from Work.denom) format = percent8.1 as pct
    from Work.echo
    group by mveaAbnormal;
  select valveDiseaseAny, valveDiseaseModSev, valveDiseaseGrade, count(*) as n, count(*) / (select count(*) from Work.echo) format = percent8.1 as pct
    from Work.echo
    group by valveDiseaseAny, valveDiseaseModSev, valveDiseaseGrade;
  create table Work.covariatesEcho as
    select distinct
           B.indexID,
           B.prochi,
           B.indexStart,
	       B.saveTime,
		   B.eventDt,
		   B.lvefGrade,
		   B.lvFunctionImpaired,
		   B.lvhGrade,
		   B.lvHypertrophy,
		   B.lvDilated,
		   B.laDilated,
		   B.mveaAbnormal,
		   B.valveDiseaseGrade,
		   B.valveDiseaseModSev,
		   B.valveDiseaseAny
    from (select indexID, 
                 max(eventDt) as latestEventDt,
				 max(saveTime) as latestSaveTime
          from Work.echo 
          group by indexID) A inner join
	     Work.echo B on (A.indexID = B.indexID & 
                         A.latestEventDt = B.eventDt &
                         A.latestSaveTime = B.saveTime)
    order by B.indexID, B.eventDt, B.saveTime;
  select count(indexID) as n1, count(distinct indexID) as n2
    from Work.covariatesEcho;
/* 
Remarkably, there are some duplicate echocardiograms.
Keep the last record of duplicates
 */
quit;


/* De-duplicate */
proc sql;
  create table Work.hasDupe as
    select B.*
	from (select indexID, count(*) as n from Work.covariatesEcho group by indexID having calculated n > 1) A inner join
	     Work.covariatesEcho B on (A.indexID = B.indexID);
quit;
data Work.deDupe;
  set Work.hasDupe;
  by indexID;
  if last.indexID then output;
run;
proc sql;
  create table lib.covariatesEcho as
    select B.*
	from (select indexID, count(*) as n from Work.covariatesEcho group by indexID having calculated n = 1) A inner join
	     Work.covariatesEcho B on (A.indexID = B.indexID)
    union corr
    select * from Work.deDupe;
  select count(indexID) as n1, count(distinct indexID) as n2
    from lib.covariatesEcho;
quit;


proc contents data = lib.covariatesEcho order = varnum;
run;


ods html close;
ods rtf close;
