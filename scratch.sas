x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";
libname lib "data/processed";


/* proc sql;
  create table Work.approved_name as
    select approved_name,
           count(*) as n
    from lib.Prescribing
    group by approved_name;
quit; */


proc sql;
  create table Work.main_condition as
    select main_condition, 
           count(*) as n, 
           count(*) / (select count(*) from lib.SMR) format = percent10.2 as pct
	from lib.SMR
	where main_condition like "I%"
	group by main_condition;
quit;


proc sql;
  create table Work.SMRLong as
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
    union corr
    select prochi, 3 as conditionPosition, other_condition_3 as icd10Code, admission_date, discharge_date, episode_record_key 
    from lib.SMR 
    where ^missing(other_condition_3) 
    union corr
    select prochi, 4 as conditionPosition, other_condition_4 as icd10Code, admission_date, discharge_date, episode_record_key 
    from lib.SMR 
    where ^missing(other_condition_4) 
    union corr
    select prochi, 5 as conditionPosition, other_condition_5 as icd10Code, admission_date, discharge_date, episode_record_key 
    from lib.SMR 
    where ^missing(other_condition_5)
    order by prochi, episode_record_key, conditionPosition;
  create table Work.hospVentArrhythmia as
    select A.indexID,
	       1 as indVentArrhythmia1y,
           B.*
	from lib.exposureTimelines A left join
         (select * from  Work.SMRLong where icd10Code like "I490%" | strip(icd10Code) = "I472") B on (A.prochi = B.prochi)
    where 0 <= B.admission_date - A.indexStart <= 365 &
	      B.admission_date <= A.indexEnd
    order by A.indexID, B.prochi, B.admission_date, B.conditionPosition;
  select count(distinct indexID) as countDistinctIndexID, count(*) as countRows from Work.hospVentArrhythmia;
  create table Work.hospVentArrhythmia2 as
    select A.indexID,
	       1 as indVentArrhythmia1y,
		   B.discharge_date - A.indexStart as daysVentArrhythmia,
		   B.*
	from lib.exposureTimelines A left join
         lib.SMRLong B on (A.prochi = B.prochi)
    where 0 <= B.discharge_date - A.indexStart <= 365 &
	      B.discharge_date <= A.indexEnd &
          (B.icd10Code like "I490%" | strip(B.icd10Code) = "I472")
    order by A.indexID, B.admission_date, B.conditionPosition;
