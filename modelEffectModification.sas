x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

filename fig "figures";
goptions reset = all device = png;

ods html body = "output/modelEffectModification.html" style = Statistical gpath = fig;
ods rtf body = "output/modelEffectModification.rtf" style = Statistical;

libname lib "data/processed";


title1 "Cox PH regression: 1-year outcomes";
title2 "With effect modification";


proc sql;
  create table Work.subgroupCovariates as
    select A.indexID,
	       max(prxmatch("/^J4[0-4]/", B.icd10code) > 0) as indPriorHospCOPD,
	       max(prxmatch("/^I2[0-5]/", B.icd10code) > 0) as indPriorHospMI,
	       max(prxmatch("/^I50/", B.icd10code) > 0) as indPriorHospHeartFailure
	from lib.exposureTimelines A left join
         lib.SMRLong B on (A.prochi = B.prochi)
    where B.discharge_date < A.indexStart
    group by A.indexID;
  create table Work.analyticDataset as
    select A.*,
	       max(0, B.indPriorHospCOPD) as indPriorHospCOPD,
		   max(0, B.indPriorHospMI) as indPriorHospMI,
		   max(0, B.indPriorHospHeartFailure) as indPriorHospHeartFailure
	from lib.analyticDataset A left join
	     Work.subgroupCovariates B on (A.indexID = B.indexID);
  update Work.analyticDataset
    set catAgeAtIndex = case
	                      when catAgeAtIndex = "<30"   then "<60"
						  when catAgeAtIndex = "30-39" then "<60"
						  when catAgeAtIndex = "40-49" then "<60"
						  when catAgeAtIndex = "50-59" then "<60"
						  when catAgeAtIndex = "60-69" then "60+"
						  when catAgeAtIndex = "70-79" then "60+"
			              when catAgeAtIndex = "80+"   then "60+"
						  else ""
						  end;
quit;


/* 
proc freq data= Work.analyticDataset;
    where indCommonSupport = 1;
  table exposure * indHospMI1y * (lvFunctionImpaired lvHypertrophy valveDiseaseModSev) / relrisk;
run;
 */


title3 "Inverse propensity score weighted";


%macro foo(t, y);
  ods output ParameterEstimates = Work.betas;
  ods output HazardRatios = Work.hazardRatios;
  proc phreg data = Work.analyticDataset covsandwich(aggregate);
    where indCommonSupport = 1;
    class exposure (ref = "AMOXICILLIN") 
          indPriorHospCOPD (ref = "0") 
          indPriorHospMI (ref = "0") 
          indPriorHospHeartFailure (ref = "0") 
          indDiabetesType2 (ref = "0") 
          indHadEchoPriorYear (ref = "0") 
          /* lvFunctionImpaired (ref = "0") 
          lvHypertrophy (ref = "0") 
          valveDiseaseModSev (ref = "0") */
          indRxCYP3A4and5 (ref = "0") 
          indRxPgp (ref = "0") 
		  indRxDipine (ref = "0") 
		  indRxAtorvastatin (ref = "0") 
		  indRxDiltiazem (ref = "0") 
		  indRxDigoxin (ref = "0") 
		  indRxAmiodarone (ref = "0") 
		  sex (ref = "M")
		  catAgeAtIndex (ref = "<60") / param = ref;
    model &t * &y(0) =
          exposure
  		  indPriorHospCOPD exposure * indPriorHospCOPD
  		  indPriorHospMI exposure * indPriorHospMI
  		  indPriorHospHeartFailure exposure * indPriorHospHeartFailure
  		  indDiabetesType2 exposure * indDiabetesType2
  		  indHadEchoPriorYear exposure * indHadEchoPriorYear
  		  /* lvFunctionImpaired exposure * lvFunctionImpaired
  		  lvHypertrophy exposure * lvHypertrophy
  		  valveDiseaseModSev exposure * valveDiseaseModSev */
  		  indRxCYP3A4and5 exposure * indRxCYP3A4and5
  		  indRxPgp exposure * indRxPgp
		  sex exposure * sex
		  catAgeAtIndex exposure * catAgeAtIndex
  		/ ties = efron risklimits;
    id prochi;
    weight iptw;
    hazardratio "indPriorHospCOPD" exposure / at (indPriorHospCOPD = "0" "1" 
                                                  indPriorHospMI = ref 
  												  indPriorHospHeartFailure = ref 
  												  indDiabetesType2 = ref 
  												  indHadEchoPriorYear = ref 
  												  /* lvFunctionImpaired = ref 
  												  lvHypertrophy = ref 
  												  valveDiseaseModSev = ref */
  												  indRxCYP3A4and5 = ref 
  												  indRxPgp = ref
												  sex = ref
												  catAgeAtIndex = ref) diff = ref;
    hazardratio "indPriorHospMI" exposure / at (indPriorHospMI = "0" "1"  
  											    indPriorHospCOPD = ref 
                                                indPriorHospHeartFailure = ref 
  											    indDiabetesType2 = ref 
  											    indHadEchoPriorYear = ref 
  											    /* lvFunctionImpaired = ref 
  												lvHypertrophy = ref 
  												valveDiseaseModSev = ref */
  											    indRxCYP3A4and5 = ref 
  											    indRxPgp = ref
												sex = ref
												catAgeAtIndex = ref) diff = ref;
    hazardratio "indPriorHospHeartFailure" exposure / at (indPriorHospHeartFailure = "0" "1"  
  												          indPriorHospCOPD = ref 
                                                          indPriorHospMI = ref 
  												          indDiabetesType2 = ref 
  												          indHadEchoPriorYear = ref 
  												          /* lvFunctionImpaired = ref 
  												          lvHypertrophy = ref 
  												          valveDiseaseModSev = ref */
  												          indRxCYP3A4and5 = ref 
  												          indRxPgp = ref
												          sex = ref
												          catAgeAtIndex = ref) diff = ref;
    hazardratio "indDiabetesType2" exposure / at (indDiabetesType2 = "0" "1"  
  												  indPriorHospCOPD = ref 
                                                  indPriorHospMI = ref 
  												  indPriorHospHeartFailure = ref 
  												  indHadEchoPriorYear = ref 
  												  /* lvFunctionImpaired = ref 
  												  lvHypertrophy = ref 
  												  valveDiseaseModSev = ref */
  												  indRxCYP3A4and5 = ref 
  												  indRxPgp = ref
												  sex = ref
												  catAgeAtIndex = ref) diff = ref;
    hazardratio "indHadEchoPriorYear" exposure / at (indHadEchoPriorYear = "0" "1"  
  												     indPriorHospCOPD = ref 
                                                     indPriorHospMI = ref 
  												     indPriorHospHeartFailure = ref 
  												     indDiabetesType2 = ref 
  												     /* lvFunctionImpaired = ref 
  												     lvHypertrophy = ref 
  												     valveDiseaseModSev = ref */
  												     indRxCYP3A4and5 = ref 
  												     indRxPgp = ref
												     sex = ref
												     catAgeAtIndex = ref) diff = ref;
    /* hazardratio "lvFunctionImpaired" exposure / at (lvFunctionImpaired = "0" "1"  
  												    indPriorHospCOPD = ref 
                                                    indPriorHospMI = ref 
  												    indPriorHospHeartFailure = ref 
  												    indDiabetesType2 = ref 
  												    indHadEchoPriorYear = ref 
  												    lvHypertrophy = ref 
  												    valveDiseaseModSev = ref
  												    indRxCYP3A4and5 = ref 
  												    indRxPgp = ref
												    sex = ref
												    catAgeAtIndex = ref) diff = ref;
    hazardratio "lvHypertrophy" exposure / at (lvHypertrophy = "0" "1"  
  											   indPriorHospCOPD = ref 
                                               indPriorHospMI = ref 
  											   indPriorHospHeartFailure = ref 
  											   indDiabetesType2 = ref 
  											   indHadEchoPriorYear = ref 
  											   lvFunctionImpaired = ref 
  											   valveDiseaseModSev = ref
  											   indRxCYP3A4and5 = ref 
  											   indRxPgp = ref
											   sex = ref
											   catAgeAtIndex = ref) diff = ref;
    hazardratio "valveDiseaseModSev" exposure / at (valveDiseaseModSev = "0" "1" 
  												    indPriorHospCOPD = ref 
                                                    indPriorHospMI = ref 
  												    indPriorHospHeartFailure = ref 
  												    indDiabetesType2 = ref 
  												    indHadEchoPriorYear = ref 
  												    lvFunctionImpaired = ref 
  												    lvHypertrophy = ref 
  												    indRxCYP3A4and5 = ref 
  												    indRxPgp = ref
												    sex = ref
												    catAgeAtIndex = ref) diff = ref; */
    hazardratio "indRxCYP3A4and5" exposure / at (indRxCYP3A4and5 = "0" "1"  
  											     indPriorHospCOPD = ref 
                                                 indPriorHospMI = ref 
  											     indPriorHospHeartFailure = ref 
  											     indDiabetesType2 = ref 
  											     indHadEchoPriorYear = ref 
  											     /* lvFunctionImpaired = ref 
  											     lvHypertrophy = ref 
  											     valveDiseaseModSev = ref */
  											     indRxPgp = ref
												 sex = ref
												 catAgeAtIndex = ref) diff = ref;
    hazardratio "indRxPgp" exposure / at (indRxPgp = "0" "1" 
  										  indPriorHospCOPD = ref 
                                          indPriorHospMI = ref 
  										  indPriorHospHeartFailure = ref 
  										  indDiabetesType2 = ref 
  										  indHadEchoPriorYear = ref 
  										  /* lvFunctionImpaired = ref 
  										  lvHypertrophy = ref 
  										  valveDiseaseModSev = ref */
  										  indRxCYP3A4and5 = ref
										  sex = ref
										  catAgeAtIndex = ref) diff = ref;
    hazardratio "sex" exposure / at (sex = "M" "F" 
  									 indPriorHospCOPD = ref 
                                     indPriorHospMI = ref 
  									 indPriorHospHeartFailure = ref 
  									 indDiabetesType2 = ref 
  									 indHadEchoPriorYear = ref 
  									 /* lvFunctionImpaired = ref 
  									 lvHypertrophy = ref 
  									 valveDiseaseModSev = ref */
  									 indRxCYP3A4and5 = ref
									 indRxPgp = ref
									 catAgeAtIndex = ref) diff = ref;
    hazardratio "catAgeAtIndex" exposure / at (catAgeAtIndex = "<60" "60+" 
  									           indPriorHospCOPD = ref 
                                               indPriorHospMI = ref 
  									           indPriorHospHeartFailure = ref 
  									           indDiabetesType2 = ref 
  									           indHadEchoPriorYear = ref 
  									           /* lvFunctionImpaired = ref 
  									           lvHypertrophy = ref 
  									           valveDiseaseModSev = ref */
  									           indRxCYP3A4and5 = ref
									           indRxPgp = ref
									           sex = ref) diff = ref;
  run;
  proc sql;
    create table Work.betas&y as
      select "&y" as outcome, * from Work.betas;
    drop table Work.betas;
    create table Work.HRs&y as
      select "&y" as outcome, * from Work.hazardRatios;
    drop table Work.hazardRatios;
  quit;
%mend foo;


%foo(daysMortalityAllCause, indMortalityAllCause1y);
%foo(daysMortalityCV, indMortalityCV1y);
%foo(daysHospCV, indHospCV1y);
%foo(daysHospMI, indHospMI1y);
%foo(daysMortalityAllCause, indMortalityAllCause30d);
%foo(daysMortalityCV, indMortalityCV30d);
%foo(daysHospCV, indHospCV30d);
%foo(daysHospMI, indHospMI30d);
%foo(daysMortalityAllCause, indMortalityAllCause14d);
%foo(daysMortalityCV, indMortalityCV14d);
%foo(daysHospCV, indHospCV14d);
%foo(daysHospMI, indHospMI14d);




proc sql;
  create table Work.effModBetas as
    select * from Work.betasindMortalityAllCause1y union corr 
    select * from Work.betasindMortalityCV1y union corr 
    select * from Work.betasindHospCV1y union corr 
    select * from Work.betasindHospMI1y union corr 
    select * from Work.betasindMortalityAllCause30d union corr 
    select * from Work.betasindMortalityCV30d union corr 
    select * from Work.betasindHospCV30d union corr 
    select * from Work.betasindHospMI30d union corr 
    select * from Work.betasindMortalityAllCause14d union corr 
    select * from Work.betasindMortalityCV14d union corr 
    select * from Work.betasindHospCV14d union corr 
    select * from Work.betasindHospMI14d ;
  create table Work.effModHRs as
    select * from Work.HRsindMortalityAllCause1y union corr 
    select * from Work.HRsindMortalityCV1y union corr 
    select * from Work.HRsindHospCV1y union corr 
    select * from Work.HRsindHospMI1y union corr
    select * from Work.HRsindMortalityAllCause30d union corr 
    select * from Work.HRsindMortalityCV30d union corr 
    select * from Work.HRsindHospCV30d union corr 
    select * from Work.HRsindHospMI30d union corr
    select * from Work.HRsindMortalityAllCause14d union corr 
    select * from Work.HRsindMortalityCV14d union corr 
    select * from Work.HRsindHospCV14d union corr 
    select * from Work.HRsindHospMI14d ;
  drop table Work.betasindMortalityAllCause1y;
  drop table Work.HRsindMortalityAllCause1y;
  drop table Work.betasindMortalityCV1y;
  drop table Work.HRsindMortalityCV1y;
  drop table Work.betasindHospCV1y;
  drop table Work.HRsindHospCV1y;
  drop table Work.betasindHospMI1y;
  drop table Work.HRsindHospMI1y;
  drop table Work.betasindMortalityAllCause30d;
  drop table Work.HRsindMortalityAllCause30d;
  drop table Work.betasindMortalityCV30d;
  drop table Work.HRsindMortalityCV30d;
  drop table Work.betasindHospCV30d;
  drop table Work.HRsindHospCV30d;
  drop table Work.betasindHospMI30d;
  drop table Work.HRsindHospMI30d;
  drop table Work.betasindMortalityAllCause14d;
  drop table Work.HRsindMortalityAllCause14d;
  drop table Work.betasindMortalityCV14d;
  drop table Work.HRsindMortalityCV14d;
  drop table Work.betasindHospCV14d;
  drop table Work.HRsindHospCV14d;
  drop table Work.betasindHospMI14d;
  drop table Work.HRsindHospMI14d;
  drop table Work.subgroupCovariates;
  drop table Work.analyticDataset;
quit;


proc export data = Work.effModBetas outfile = "data/processed/effectModificationBetas.csv" dbms = csv replace;
  delimiter = ",";
run;
proc export data = Work.effModHRs outfile = "data/processed/effectModificationHazardRatios.csv" dbms = csv replace;
  delimiter = ",";
run;



ods html close;
ods rtf close;
