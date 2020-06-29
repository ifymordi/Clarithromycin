x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/buildCovariatesClinical.html" style = Statistical;
ods rtf body = "output/buildCovariatesClinical.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  create table Work.lookup as
    select A.indexID,
           A.prochi,
           A.indexStart,
           max(B.Date_of_Diagnosis) format = yymmdd10. as mostRecentDiabDate
    from lib.exposureTimelines A inner join 
         lib.CDDiabSummary B on (A.prochi = B.prochi &
                                 B.Date_of_Diagnosis <= A.indexStart)
    group by A.indexID,
             A.prochi,
             A.indexStart;
  create table Work.covariatesDiabetes as
    select A.*,
           B.Date_of_Diagnosis format = yymmdd10. as diabDate,
           B.DiabetesMellitusType as diabType,
           B.DiabetesTreatmentType as diabTreatment
    from Work.lookup A inner join 
         lib.CDDiabSummary B on (A.prochi = B.prochi &
                                 A.mostRecentDiabDate = B.Date_of_Diagnosis);
quit;


proc sql;
  create table Work.lookup as
    select A.indexID,
           A.prochi,
           A.indexStart,
           max(C.Date) format = yymmdd10. as mostRecentCOPDDate
    from lib.exposureTimelines A inner join 
         lib.copd C on (A.prochi = C.prochi &
                        C.Date <= A.indexStart)
    group by A.indexID,
             A.prochi,
             A.indexStart;
  create table Work.covariatesCOPD as
    select A.*,
           C.Date format = yymmdd10. as copdDate,
           case
             when C.Diagnosis = 0 then "None"
             when C.Diagnosis = 1 then "COPD"
             when C.Diagnosis = 2 then "COPD with significant reversibility"
             when C.Diagnosis = 3 then "Asthma"
             when C.Diagnosis = 4 then "Unsure"
             when C.Diagnosis = 9 then "Other"
             else ""
             end as copdDiagnosis,
           C.FollowUp as copdFollowUp
    from Work.lookup A inner join 
         lib.copd C on (A.prochi = C.prochi &
                        A.mostRecentCOPDDate = C.Date);
quit;


proc sql;
  create table lib.covariatesClinical as
    select coalesce(A.indexID, B.indexID) as indexID,
           coalesce(A.prochi, B.prochi) as prochi,
           coalesce(A.indexStart, B.indexStart) format = yymmdd10. as indexStart,
           A.diabDate,
           A.diabType,
           A.diabTreatment,
           B.copdDate,
           B.copdDiagnosis,
           B.copdFollowUp
    from Work.covariatesDiabetes A full join
         Work.covariatesCOPD B on (A.indexID = B.indexID &
                                   A.prochi = B.prochi &
                                   A.indexStart = B.indexStart)
    order by calculated indexID;
  drop table Work.lookup;
  drop table Work.covariatesDiabetes;
  drop table Work.covariatesCOPD;
quit;


/*
proc sql;
  create table lib.covariatesClinical as
    select A.indexID,
           A.prochi,
           A.indexStart,
           B.Date_of_Diagnosis format = yymmdd10. as diabetesDate,
           B.DiabetesMellitusType as diabType,
           B.DiabetesTreatmentType as diabTreatment,
           C.Date format = yymmdd10. as copdDate,
           case
             when C.Diagnosis = 0 then "None"
             when C.Diagnosis = 1 then "COPD"
             when C.Diagnosis = 2 then "COPD with significant reversibility"
             when C.Diagnosis = 3 then "Asthma"
             when C.Diagnosis = 4 then "Unsure"
             when C.Diagnosis = 9 then "Other"
             else ""
             end as copdDiagnosis,
           C.FollowUp as copdFollowUp,
           D.DATE format = yymmdd10. as htwtspiromDate,
           D.HEIGHT,
           D.WEIGHT,
           D.BaseFEV1,
           D.BaseFVC,
           D.BaseFEV1PercentPred,
           D.PostFEV1,
           D.PostFVC,
           D.PostFEV1PercentPred,
           E.DATE format = yymmdd10. as oxygenDate,
           E.OxygenAtHome,
           E.OxygenNeedAssessed,
           case
             when E.OxygenType = 1 then "Cylinders"
             when E.OxygenType = 2 then "Concentrators"
             else ""
             end as oxygenType,
           E.OxygenUsage,
           case
             when E.OxygenFlowRate = 1 then "2 litres"
             when E.OxygenFlowRate = 2 then "4 litres"
             else ""
             end as oxygenFlowRate
    from lib.exposureTimelines A left join 
         lib.CDDiabSummary B on (A.prochi = B.prochi &
                                 B.Date_of_Diagnosis <= A.indexStart) left join
         lib.copd C on (A.prochi = C.prochi &
                        C.Date <= A.indexStart) left join
         lib.HtWtSpirom D on (A.prochi = D.prochi &
                              D.Date <= A.indexStart) left join
         lib.oxygen E on (A.prochi = E.prochi &
                          E.Date <= A.indexStart)
    order by A.indexID;
quit;


proc contents data = lib.covariatesClinical order = varnum;
run;
*/


ods html close;
ods rtf close;
