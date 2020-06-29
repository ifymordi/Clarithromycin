x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/buildExposureTimelines.html" style = Statistical;
ods rtf body = "output/buildExposureTimelines.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  create table Work.exposureTimeline0 as
    select distinct 
           prochi, 
           "CLARITHROMYCIN" as exposure,
           datepart(corrected_prescribed_date) format = yymmdd10. as exposureStartDate
    from lib.Prescribing
    where Approved_Name = "CLARITHROMYCIN"
    union corr
    select distinct 
           prochi, 
           "AMOXICILLIN" as exposure,
           datepart(corrected_prescribed_date) format = yymmdd10. as exposureStartDate
    from lib.Prescribing
    where Approved_Name in ("AMOXICILLIN", "CO-AMOXICLAV")
    order by prochi, calculated exposureStartDate;
quit;


data Work.exposureTimeline1 (drop =  exclCoRx nextProchi nextExposure nextExpStartDate);
  merge Work.exposureTimeline0 (rename = (exposureStartDate = indexStart))
        Work.exposureTimeline0 (firstobs = 2
                                rename = (prochi = nextProchi
                                          exposure = nextExposure
                                          exposureStartDate = nextExpStartDate));
  format indexStart indexEnd yymmdd10.;
  indexEnd = indexStart + 365 - 1;
  if prochi ^= nextProchi then do;
    nextExposure = "";
    nextExpStartDate = .;
  end;
  else do;
    indexEnd = min(nextExpStartDate - 1, indexStart + 365 - 1);
    if exposure = "AMOXICILLIN" &
       nextExposure = "CLARITHROMYCIN" &
       abs(indexStart - nextExpStartDate) <= 7 then exclCoRx = 1;
  end;
  if exclCoRx = 1 then delete;
run;
proc sort data =  Work.exposureTimeline1;
  by prochi indexStart;
run;
data Work.exposureTimeline1;
  set Work.exposureTimeline1;
  indexID = _n_;
run;

proc sql;
  create table Work.exposureTimeline2 as
    select A.indexID,
           A.prochi,
           A.exposure,
           A.indexStart,
           min(B.date_of_death, A.indexEnd) format yymmdd10. as indexEnd,
           calculated indexEnd - A.indexStart + 1 as indexDuration,
           case
             when A.indexStart <= B.date_of_death <= A.indexEnd then 1
             when missing(B.date_of_death) then 0
             when A.indexEnd < B.date_of_death then 0
             else .
             end as indDied
    from Work.exposureTimeline1 A left join
         lib.chiDeaths B on (A.prochi = B.prochi)
	where A.indexStart <= B.date_of_death
    order by A.indexID;
quit;

proc sql;
  select exposure, 
         count(distinct indexID) as n,
         sum(indDied) as sumDied
         from Work.exposureTimeline2
    group by exposure;
  create table lib.exposureTimelines as
    select * from Work.exposureTimeline2;
  drop table Work.exposureTimeline0;
  drop table Work.exposureTimeline1;
  drop table Work.exposureTimeline2;
quit;

proc contents data = lib.exposureTimelines order = varnum;
run;

proc freq data = lib.exposureTimelines;
  format indexStart year4.;
  table indexStart;
run;


ods html close;
ods rtf close;
