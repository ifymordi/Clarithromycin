x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

title1;

ods html body = "output/buildOutcomes.html" style = Statistical;
ods rtf body = "output/buildOutcomes.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  create table lib.SMRLong as
    select prochi, 0 as conditionPosition, main_condition as icd10Code, admission_date, discharge_date, episode_record_key
    from lib.SMR 
    where ^missing(main_condition) 
    union corr
    select prochi, 1 as conditionPosition, other_condition_1 as icd10Code, admission_date, discharge_date, episode_record_key 
    from lib.SMR 
    where ^missing(other_condition_1) 
    union corr
    select prochi, 2 as conditionPosition, other_condition_2 as icd10Code, admission_date, discharge_date, episode_record_key 
    from lib.SMR 
    where ^missing(other_condition_2)
    order by prochi, episode_record_key, conditionPosition;
  select conditionPosition, count(*) as n from lib.SMRLong group by conditionPosition;
  create table Work.hospVentArrhythmia as
    select A.indexID,
		   min(B.discharge_date - A.indexStart) as daysHospVentArrhythmia
	from lib.exposureTimelines A left join
         lib.SMRLong B on (A.prochi = B.prochi)
    where 0 <= B.discharge_date - A.indexStart <= 365 &
	      B.discharge_date <= A.indexEnd &
          (B.icd10Code like "I490%" | strip(B.icd10Code) = "I472")
    group by A.indexID;
  alter table Work.hospVentArrhythmia
    add indHospVentArrhythmia1y numeric, 
	    indHospVentArrhythmia30d numeric, 
		indHospVentArrhythmia14d numeric;
  update Work.hospVentArrhythmia
    set indHospVentArrhythmia1y = case
	                                when 31 <= daysHospVentArrhythmia <= 365 then 1
									else 0
									end;
  update Work.hospVentArrhythmia
    set indHospVentArrhythmia30d = case
	                                 when 15 <= daysHospVentArrhythmia <= 30 then 1
									 else 0
									 end;
  update Work.hospVentArrhythmia
    set indHospVentArrhythmia14d = case
	                                 when 0 <= daysHospVentArrhythmia <= 14 then 1
									 else 0
									 end;
  select indHospVentArrhythmia1y, indHospVentArrhythmia30d, indHospVentArrhythmia14d, count(distinct indexID) as n, min(daysHospVentArrhythmia) as minDays, max(daysHospVentArrhythmia) as maxDays
    from Work.hospVentArrhythmia
	group by indHospVentArrhythmia1y, indHospVentArrhythmia30d, indHospVentArrhythmia14d;
  create table Work.hospSuddenCardiacArrest as
    select A.indexID,
		   min(B.discharge_date - A.indexStart) as daysHospSuddenCardiacArrest
	from lib.exposureTimelines A left join
         lib.SMRLong B on (A.prochi = B.prochi)
    where 0 <= B.discharge_date - A.indexStart <= 365 &
	      B.discharge_date <= A.indexEnd &
          strip(B.icd10Code) = "I469"
    group by A.indexID;
  alter table Work.hospSuddenCardiacArrest
    add indHospSuddenCardiacArrest1y numeric, 
	    indHospSuddenCardiacArrest30d numeric, 
		indHospSuddenCardiacArrest14d numeric;
  update Work.hospSuddenCardiacArrest
    set indHospSuddenCardiacArrest1y = case
	                                     when 31 <= daysHospSuddenCardiacArrest <= 365 then 1
									     else 0
									     end;
  update Work.hospSuddenCardiacArrest
    set indHospSuddenCardiacArrest30d = case
	                                      when 15 <= daysHospSuddenCardiacArrest <= 30 then 1
									      else 0
									      end;
  update Work.hospSuddenCardiacArrest
    set indHospSuddenCardiacArrest14d = case
	                                      when 0 <= daysHospSuddenCardiacArrest <= 14 then 1
									      else 0
									      end;
  select indHospSuddenCardiacArrest1y, indHospSuddenCardiacArrest30d, indHospSuddenCardiacArrest14d, count(distinct indexID) as n, min(daysHospSuddenCardiacArrest) as minDays, max(daysHospSuddenCardiacArrest) as maxDays
    from Work.hospSuddenCardiacArrest
	group by indHospSuddenCardiacArrest1y, indHospSuddenCardiacArrest30d, indHospSuddenCardiacArrest14d;
  create table Work.hospMI as
    select A.indexID,
		   min(B.discharge_date - A.indexStart) as daysHospMI
	from lib.exposureTimelines A left join
         lib.SMRLong B on (A.prochi = B.prochi)
    where 0 <= B.discharge_date - A.indexStart <= 365 &
	      B.discharge_date <= A.indexEnd &
          (B.icd10Code like "I21%" | B.icd10Code like "I22%")
    group by A.indexID;
  alter table Work.hospMI
    add indHospMI1y numeric, 
	    indHospMI30d numeric, 
		indHospMI14d numeric;
  update Work.hospMI
    set indHospMI1y = case
	                    when 31 <= daysHospMI <= 365 then 1
						else 0
						end;
  update Work.hospMI
    set indHospMI30d = case
	                     when 15 <= daysHospMI <= 30 then 1
						 else 0
						 end;
  update Work.hospMI
    set indHospMI14d = case
	                     when 0 <= daysHospMI <= 14 then 1
						 else 0
						 end;
  select indHospMI1y, indHospMI30d, indHospMI14d, count(distinct indexID) as n, min(daysHospMI) as minDays, max(daysHospMI) as maxDays
    from Work.hospMI
	group by indHospMI1y, indHospMI30d, indHospMI14d;
  create table Work.hospCV as
    select A.indexID,
		   min(B.discharge_date - A.indexStart) as daysHospCV
	from lib.exposureTimelines A left join
         lib.SMRLong B on (A.prochi = B.prochi)
    where 0 <= B.discharge_date - A.indexStart <= 365 &
	      B.discharge_date <= A.indexEnd &
          B.icd10Code like "I%"
    group by A.indexID;
  alter table Work.hospCV
    add indHospCV1y numeric, 
	    indHospCV30d numeric, 
		indHospCV14d numeric;
  update Work.hospCV
    set indHospCV1y = case
	                    when 31 <= daysHospCV <= 365 then 1
						else 0
						end;
  update Work.hospCV
    set indHospCV30d = case
	                     when 15 <= daysHospCV <= 30 then 1
						 else 0
						 end;
  update Work.hospCV
    set indHospCV14d = case
	                     when 0 <= daysHospCV <= 14 then 1
						 else 0
						 end;
  select indHospCV1y, indHospCV30d, indHospCV14d, count(distinct indexID) as n, min(daysHospCV) as minDays, max(daysHospCV) as maxDays
    from Work.hospCV
	group by indHospCV1y, indHospCV30d, indHospCV14d;
  create table Work.hospCVCodes as
    select B.indexID, B.dateDischargeFirstHospCV, A.*
    from (select * from lib.SMRLong where icd10Code like "I%") A inner join
	     (select A.indexID, 
                 B.indexStart + A.daysHospCV format = ddmmyy10. as dateDischargeFirstHospCV, 
                 B.prochi 
          from Work.hospCV A inner join 
               lib.exposureTimelines B on (A.indexID = B.indexID)) B  on (A.prochi = B.prochi & 
                                                                          A.discharge_date = B.dateDischargeFirstHospCV);
  create table lib.outcomes as
    select A.indexID,
           A.prochi,
           B.date_of_death format = yymmdd10. as dateDeathCHI,
           C.icdcucd,
           C.icdcucd like "I%" & 
             31 <= B.date_of_death - A.indexStart <= 365 & 
             B.date_of_death <= A.indexEnd 
             as indMortalityCV1y,
           C.icdcucd like "I%" & 
             15 <= B.date_of_death - A.indexStart <= 30 & 
             B.date_of_death <= A.indexEnd 
             as indMortalityCV30d,
           C.icdcucd like "I%" & 
             0 <= B.date_of_death - A.indexStart <= 14 & 
             B.date_of_death <= A.indexEnd 
             as indMortalityCV14d,
           case
             when B.date_of_death < A.indexStart then .
             when C.icdcucd like "I%" & 
                  0 <= B.date_of_death - A.indexStart <= 365 & 
                  B.date_of_death <= A.indexEnd then B.date_of_death - A.indexStart
             else A.indexDuration
             end as daysMortalityCV,
           31 <= B.date_of_death - A.indexStart <= 365 & 
             B.date_of_death <= A.indexEnd 
             as indMortalityAllCause1y,
           15 <= B.date_of_death - A.indexStart <= 30 & 
             B.date_of_death <= A.indexEnd 
             as indMortalityAllCause30d,
           0 <= B.date_of_death - A.indexStart <= 14 & 
             B.date_of_death <= A.indexEnd 
             as indMortalityAllCause14d,
           case
             when B.date_of_death < A.indexStart then .
             when 0 <= B.date_of_death - A.indexStart <= 365 & 
                  B.date_of_death <= A.indexEnd then B.date_of_death - A.indexStart
             else A.indexDuration
             end as daysMortalityAllCause,
           max(0, D.indHospVentArrhythmia1y) as indHospVentArrhythmia1y,
           max(0, D.indHospVentArrhythmia30d) as indHospVentArrhythmia30d,
           max(0, D.indHospVentArrhythmia14d) as indHospVentArrhythmia14d,
		   case
		     when D.indHospVentArrhythmia1y | D.indHospVentArrhythmia30d | D.indHospVentArrhythmia14d then D.daysHospVentArrhythmia
             when B.date_of_death <= A.indexEnd then B.date_of_death - A.indexStart
             else A.indexDuration
             end as daysHospVentArrhythmia,
           max(0, E.indHospSuddenCardiacArrest1y) as indHospSuddenCardiacArrest1y,
           max(0, E.indHospSuddenCardiacArrest30d) as indHospSuddenCardiacArrest30d,
           max(0, E.indHospSuddenCardiacArrest14d) as indHospSuddenCardiacArrest14d,
		   case
		     when E.indHospSuddenCardiacArrest1y | E.indHospSuddenCardiacArrest30d | E.indHospSuddenCardiacArrest14d then E.daysHospSuddenCardiacArrest
             when B.date_of_death <= A.indexEnd then B.date_of_death - A.indexStart
             else A.indexDuration
             end as daysHospSuddenCardiacArrest,
           max(0, F.indHospMI1y) as indHospMI1y,
           max(0, F.indHospMI30d) as indHospMI30d,
           max(0, F.indHospMI14d) as indHospMI14d,
		   case
		     when F.indHospMI1y | F.indHospMI30d | F.indHospMI14d then F.daysHospMI
             when B.date_of_death <= A.indexEnd then B.date_of_death - A.indexStart
             else A.indexDuration
             end as daysHospMI,
           max(0, G.indHospCV1y) as indHospCV1y,
           max(0, G.indHospCV30d) as indHospCV30d,
           max(0, G.indHospCV14d) as indHospCV14d,
		   case
		     when G.indHospCV1y | G.indHospCV30d | G.indHospCV14d then G.daysHospCV
             when B.date_of_death <= A.indexEnd then B.date_of_death - A.indexStart
             else A.indexDuration
             end as daysHospCV
    from lib.exposureTimelines A left join
         lib.CHIDeaths B on (A.prochi = B.prochi) left join
         lib.GRO C on (A.prochi = C.prochi) left join
		 Work.hospVentArrhythmia D on (A.indexID = D.indexID) left join
		 Work.hospSuddenCardiacArrest E on (A.indexID = E.indexID) left join
		 Work.hospMI F on (A.indexID = F.indexID) left join
		 Work.hospCV G on (A.indexID = G.indexID)
	where A.indexStart <= B.date_of_death;
quit;

proc means data = lib.outcomes maxdec = 1;
  class indMortalityCV1y indMortalityCV30d indMortalityCV14d;
  var daysMortalityCV;
run;
proc means data = lib.outcomes maxdec = 1;
  class indMortalityAllCause1y indMortalityAllCause30d indMortalityAllCause14d;
  var daysMortalityAllCause;
run;
proc means data = lib.outcomes maxdec = 1;
  class indHospVentArrhythmia1y indHospVentArrhythmia30d indHospVentArrhythmia14d;
  var daysHospVentArrhythmia;
run;
proc means data = lib.outcomes maxdec = 1;
  class indHospSuddenCardiacArrest1y indHospSuddenCardiacArrest30d indHospSuddenCardiacArrest14d;
  var daysHospSuddenCardiacArrest;
run;
proc means data = lib.outcomes maxdec = 1;
  class indHospMI1y indHospMI30d indHospMI14d;
  var daysHospMI;
run;
proc means data = lib.outcomes maxdec = 1;
  class indHospCV1y indHospCV30d indHospCV14d;
  var daysHospCV;
run;
proc sql;
  select substr(icd10code, 1, 3) as icd10CodeFirst3Chr, 
         count(distinct indexID) as numer,
		 (select count(distinct indexID) from Work.hospCVCodes) as denom,
		 calculated numer / calculated denom format = percent10.2 as pct
  from Work.hospCVCodes
  group by calculated icd10CodeFirst3Chr
  order by calculated pct descending;
quit;


proc contents data = lib.outcomes order = varnum;
run;


proc sql;
  drop table Work.hospVentArrhythmia;
  drop table Work.hospSuddenCardiacArrest;
  drop table Work.hospMI;
  drop table Work.hospCV;
  drop table Work.hospCVCodes;
quit;


ods html close;
ods rtf close;
