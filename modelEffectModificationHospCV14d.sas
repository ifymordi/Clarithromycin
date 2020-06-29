x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

filename fig "figures";
goptions reset = all device = png;

ods html body = "output/modelEffectModificationHospCV14d.html" style = Statistical gpath = fig;
ods rtf body = "output/modelEffectModificationHospCV14d.rtf" style = Statistical;

libname lib "data/processed";


title1 "Cox PH regression: 14-day CV hospitalization";
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



%macro foo(t, y, x);
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
  		  &x exposure * &x
		  sex exposure * sex
		  catAgeAtIndex exposure * catAgeAtIndex
  		/ ties = efron risklimits;
    id prochi;
    weight iptw;
    hazardratio "&x" exposure / at (&x = "0" "1" 
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
  run;
  proc sql;
    create table Work.betas&x as
      select "&y" as outcome, "&x" as pgpDrug, * from Work.betas;
    drop table Work.betas;
    create table Work.HRs&x as
      select "&y" as outcome, "&x" as pgpDrug, * from Work.hazardRatios;
    drop table Work.hazardRatios;
  quit;
%mend foo;


%foo(daysHospCV, indHospCV14d, indRxDipine);
%foo(daysHospCV, indHospCV14d, indRxAtorvastatin);
%foo(daysHospCV, indHospCV14d, indRxDiltiazem);
%foo(daysHospCV, indHospCV14d, indRxDigoxin);
%foo(daysHospCV, indHospCV14d, indRxAmiodarone);


proc sql;
  create table Work.effModBetas as
    select * from Work.betasindRxDipine union corr 
    select * from Work.betasindRxAtorvastatin union corr 
    select * from Work.betasindRxDiltiazem union corr 
    select * from Work.betasindRxDigoxin union corr 
    select * from Work.betasindRxAmiodarone ;
  create table Work.effModHRs as
    select * from Work.HRsindRxDipine union corr 
    select * from Work.HRsindRxAtorvastatin union corr 
    select * from Work.HRsindRxDiltiazem union corr 
    select * from Work.HRsindRxDigoxin union corr 
    select * from Work.HRsindRxAmiodarone ;
  drop table Work.betasindRxDipine;
  drop table Work.betasindRxAtorvastatin;
  drop table Work.betasindRxDiltiazem;
  drop table Work.betasindRxDigoxin;
  drop table Work.betasindRxAmiodarone;
  drop table Work.HRsindRxDipine;
  drop table Work.HRsindRxAtorvastatin;
  drop table Work.HRsindRxDiltiazem;
  drop table Work.HRsindRxDigoxin;
  drop table Work.HRsindRxAmiodarone;
quit;


proc export data = Work.effModBetas outfile = "data/processed/effectModificationBetasHospCV14d.csv" dbms = csv replace;
  delimiter = ",";
run;
proc export data = Work.effModHRs outfile = "data/processed/effectModificationHazardRatiosHospCV14d.csv" dbms = csv replace;
  delimiter = ",";
run;



ods html close;
ods rtf close;
