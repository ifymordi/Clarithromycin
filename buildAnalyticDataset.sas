x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/buildAnalyticDataset.html" style = Statistical;
ods rtf body = "output/buildAnalyticDataset.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  create table lib.analyticDataset as
    select A.indexID,
           A.prochi,
           A.exposure,
           A.indexStart,
           A.indexEnd,
           A.indexDuration,
           A.indDied,
           B.dateDeathCHI,
           B.icdcucd,
		   B.indMortalityCV1y,
		   B.indMortalityCV30d,
		   B.indMortalityCV14d,
		   B.daysMortalityCV,
		   B.indMortalityAllCause1y,
		   B.indMortalityAllCause30d,
		   B.indMortalityAllCause14d,
		   B.daysMortalityAllCause,
		   B.indHospVentArrhythmia1y,
		   B.indHospVentArrhythmia30d,
		   B.indHospVentArrhythmia14d,
		   B.daysHospVentArrhythmia,
		   B.indHospSuddenCardiacArrest1y,
		   B.indHospSuddenCardiacArrest30d,
		   B.indHospSuddenCardiacArrest14d,
		   B.daysHospSuddenCardiacArrest,
		   B.indHospMI1y,
		   B.indHospMI30d,
		   B.indHospMI14d,
		   B.daysHospMI,
		   B.indHospCV1y,
		   B.indHospCV30d,
		   B.indHospCV14d,
		   B.daysHospCV,
           C.sex,
           C.ageAtIndex,
		   case
		     when 19 <= C.ageAtIndex < 30 then "<30"
		     when 30 <= C.ageAtIndex < 40 then "30-39"
		     when 40 <= C.ageAtIndex < 50 then "40-49"
		     when 50 <= C.ageAtIndex < 60 then "50-59"
		     when 60 <= C.ageAtIndex < 70 then "60-69"
		     when 70 <= C.ageAtIndex < 80 then "70-79"
			 when 80 <= C.ageAtIndex      then "80+"
			 else ""
			 end as catAgeAtIndex,
           C.hbsimd5 label = "Health Board SIMD Quintile",
           C.hbsimd10 label = "Health Board SIMD Decile",
           C.scsimd5 label = "Scotland SIMD Quintile",
           C.scsimd10 label = "Scotland SIMD Decile",
           C.rurality,
		   prxmatch("/Urban/", C.rurality) = 0 as indNotUrban,
           C.currentRecord,
           C.postcode,
		   D.diabDate,
           D.diabType,
           D.diabTreatment,
		   prxmatch("/Type 1/", D.diabType) > 0 as indDiabetesType1,
		   prxmatch("/Type 2/", D.diabType) > 0 as indDiabetesType2,
           D.copdDate,
           D.copdDiagnosis,
           D.copdFollowUp,
		   D.copdDiagnosis = "COPD" as indCOPD,
		   max(0, E.indRxACEI) as indRxACEI,
		   max(0, E.indRxARB) as indRxARB,
		   max(0, E.indRxAspirin) as indRxAspirin,
		   max(0, E.indRxBetaBlocker) as indRxBetaBlocker,
		   max(0, E.indRxClopidogrel) as indRxClopidogrel,
		   max(0, E.indRxDihyCCB) as indRxDihyCCB,
		   max(0, E.indRxLoopDiur) as indRxLoopDiur,
		   max(0, E.indRxMinCortAntag) as indRxMinCortAntag,
		   max(0, E.indRxNondihyCCB) as indRxNondihyCCB,
		   max(0, E.indRxStatin) as indRxStatin,
		   max(0, E.indRxThiazideDiur) as indRxThiazideDiur,
		   max(0, E.indRxWarfarin) as indRxWarfarin,
		   max(0, E.indRxCYP3A4and5) as indRxCYP3A4and5,
		   max(0, E.indRxPgp) as indRxPgp,
		   max(0, E.indRxDipine) as indRxDipine,
		   max(0, E.indRxAtorvastatin) as indRxAtorvastatin,
		   max(0, E.indRxDiltiazem) as indRxDiltiazem,
		   max(0, E.indRxDigoxin) as indRxDigoxin,
		   max(0, E.indRxAmiodarone) as indRxAmiodarone,
		   max(0, E.indRxNSAID) as indRxNSAID,
		   max(0, E.indRxClariPriorYear) as indRxClariPriorYear,
		   ^missing(F.indexID) as indHadEchoPriorYear,
		   datepart(F.eventDt) format = yymmdd10. as echoDate,
		   F.lvefGrade,
		   max(0, F.lvFunctionImpaired) as lvFunctionImpaired,
		   F.lvhGrade,
		   max(0, F.lvHypertrophy) as lvHypertrophy,
		   max(0, F.lvDilated) as lvDilated,
		   max(0, F.laDilated) as laDilated,
		   max(0, F.mveaAbnormal) as mveaAbnormal,
		   F.valveDiseaseGrade,
		   max(0, F.valveDiseaseModSev) as valveDiseaseModSev,
		   max(0, F.valveDiseaseAny) as valveDiseaseAny,
		   max(0, G.indHospPrior) as indHospPrior
    from lib.exposureTimelines A left join
         lib.outcomes B on (A.indexID = B.indexID) left join 
         lib.covariatesDemographic C on (A.indexID = C.indexID) left join
		 lib.covariatesClinical D on (A.indexID = D.indexID) left join
		 lib.covariatesMedications E on (A.indexID = E.indexID) left join
		 lib.covariatesEcho F on (A.indexID = F.indexID) left join
		 lib.hospPrior G on (A.indexID = G.indexID)
    where C.ageAtIndex > 18 &
          C.postcode ^= ""
    order by A.indexID;
quit;

proc export data = lib.analyticDataset outfile = "data/processed/analyticDataset.dta" replace;
run;

proc contents data = lib.analyticDataset order = varnum;
run;


proc sql;
  select A.postcode,
         A.indMortalityCV1y,
         A.indMortalityAllCause1y,
         count(distinct A.prochi) as countProchi,
         count(distinct A.prochi) / B.countProchi format = percent8.1 as pctProchi,
         count(*) as countRows,
         count(*) / B.countRows format = percent8.1 as pctRows,
         count(*) / count(distinct A.prochi) format = 8.1 as recordsPerProchi
    from lib.analyticDataset A inner join
         (select postcode, count(distinct prochi) as countProchi, count(*) as countRows 
          from lib.analyticDataset
          group by postcode) B on (A.postcode = B.postcode)
    group by A.postcode,
             A.indMortalityCV1y,
             A.indMortalityAllCause1y;
quit;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class indMortalityCV1y indMortalityCV30d indMortalityCV14d;
  var daysMortalityCV;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class indMortalityAllCause1y indMortalityAllCause30d indMortalityAllCause14d;
  var daysMortalityAllCause;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class indHospVentArrhythmia1y indHospVentArrhythmia30d indHospVentArrhythmia14d;
  var daysHospVentArrhythmia;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class indHospSuddenCardiacArrest1y indHospSuddenCardiacArrest30d indHospSuddenCardiacArrest14d;
  var daysHospSuddenCardiacArrest;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class indHospMI1y indHospMI30d indHospMI14d;
  var daysHospMI;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class indHospCV1y indHospCV30d indHospCV14d;
  var daysHospCV;
run;


ods html close;
ods rtf close;
