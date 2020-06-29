x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/summarizeAnalyticDataset.html" style = Statistical;
ods rtf body = "output/summarizeAnalyticDataset.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  select A.exposure,
         count(distinct A.prochi) as countProchi,
         count(distinct A.prochi) / B.countProchi format = percent8.1 as pctProchi,
         count(*) as countRows,
         count(*) / B.countRows format = percent8.1 as pctRows,
         count(*) / count(distinct A.prochi) format = 8.1 as recordsPerProchi
    from lib.analyticDataset A,
         (select count(distinct prochi) as countProchi, count(*) as countRows 
          from lib.analyticDataset) B
    group by A.exposure;
  select A.exposure,
         A.indMortalityCV1y,
         A.indMortalityAllCause1y,
         count(distinct A.prochi) as countProchi,
         count(distinct A.prochi) / B.countProchi format = percent8.1 as pctProchi,
         count(*) as countRows,
         count(*) / B.countRows format = percent8.1 as pctRows,
         count(*) / count(distinct A.prochi) format = 8.1 as recordsPerProchi
    from lib.analyticDataset A inner join
         (select exposure, count(distinct prochi) as countProchi, count(*) as countRows 
          from lib.analyticDataset
          group by exposure) B on (A.exposure = B.exposure)
    group by A.exposure,
             A.indMortalityCV1y,
             A.indMortalityAllCause1y;
  select A.exposure,
         A.indMortalityCV30d,
         A.indMortalityAllCause30d,
         count(distinct A.prochi) as countProchi,
         count(distinct A.prochi) / B.countProchi format = percent8.1 as pctProchi,
         count(*) as countRows,
         count(*) / B.countRows format = percent8.1 as pctRows,
         count(*) / count(distinct A.prochi) format = 8.1 as recordsPerProchi
    from lib.analyticDataset A inner join
         (select exposure, count(distinct prochi) as countProchi, count(*) as countRows 
          from lib.analyticDataset
          group by exposure) B on (A.exposure = B.exposure)
    group by A.exposure,
             A.indMortalityCV30d,
             A.indMortalityAllCause30d;
  select A.exposure,
         A.indMortalityCV14d,
         A.indMortalityAllCause14d,
         count(distinct A.prochi) as countProchi,
         count(distinct A.prochi) / B.countProchi format = percent8.1 as pctProchi,
         count(*) as countRows,
         count(*) / B.countRows format = percent8.1 as pctRows,
         count(*) / count(distinct A.prochi) format = 8.1 as recordsPerProchi
    from lib.analyticDataset A inner join
         (select exposure, count(distinct prochi) as countProchi, count(*) as countRows 
          from lib.analyticDataset
          group by exposure) B on (A.exposure = B.exposure)
    group by A.exposure,
             A.indMortalityCV14d,
             A.indMortalityAllCause14d;
quit;

proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure indMortalityCV1y indMortalityCV30d indMortalityCV14d;
  var daysMortalityCV;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure indMortalityAllCause1y indMortalityAllCause30d indMortalityAllCause14d;
  var daysMortalityAllCause;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure indHospVentArrhythmia1y indHospVentArrhythmia30d indHospVentArrhythmia14d;
  var daysHospVentArrhythmia;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure indHospSuddenCardiacArrest1y indHospSuddenCardiacArrest30d indHospSuddenCardiacArrest14d;
  var daysHospSuddenCardiacArrest;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure indHospMI1y indHospMI30d indHospMI14d;
  var daysHospMI;
run;
proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure indHospCV1y indHospCV30d indHospCV14d;
  var daysHospCV;
run;


proc means data =  lib.analyticDataset n mean std median min max q1 q3 maxdec = 1;
  class exposure;
  var ageAtIndex;
run;
proc freq data = lib.analyticDataset;
  table (catAgeAtIndex sex postcode hbsimd5 scsimd5) *
        exposure /
		nopercent norow missprint;
run;
proc means data =  lib.analyticDataset n mean std maxdec = 3;
  class exposure;
  var indNotUrban
	  indDiabetesType1 indDiabetesType2
	  indCOPD
	  indRxACEI
	  indRxARB
	  indRxAspirin
	  indRxBetaBlocker
	  indRxClopidogrel
	  indRxDihyCCB
	  indRxLoopDiur
	  indRxMinCortAntag
	  indRxNondihyCCB
	  indRxStatin
	  indRxThiazideDiur
	  indRxWarfarin
	  indRxCYP3A4and5
	  indRxPgp
	  indRxDipine      
	  indRxAtorvastatin
	  indRxDiltiazem   
	  indRxDigoxin     
	  indRxAmiodarone  
	  indRxNSAID
	  indRxClariPriorYear
	  indHadEchoPriorYear
      lvFunctionImpaired
      lvHypertrophy
      lvDilated
      laDilated
      mveaAbnormal
      valveDiseaseAny
      valveDiseaseModSev;
run;
proc freq data = lib.analyticDataset;
  table (lvhGrade lvefGrade valveDiseaseGrade) *
        exposure /
		nopercent norow missprint;
run;



ods html close;
ods rtf close;
