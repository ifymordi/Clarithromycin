x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/analyzeSubgroup.html" style = Statistical;
ods rtf body = "output/analyzeSubgroup.rtf" style = Statistical;

libname lib "data/processed";


title1 "Subgroup: Clarithromycin exposed";


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
	     Work.subgroupCovariates B on (A.indexID = B.indexID)
    where exposure = "CLARITHROMYCIN";
  update Work.analyticDataset
    set catAgeAtIndex = case
	                      when catAgeAtIndex = "<30" then "<50"
						  when catAgeAtIndex = "30-39" then "<50"
						  when catAgeAtIndex = "40-49" then "<50"
						  else catAgeAtIndex
						  end;
quit;


proc freq data =  Work.analyticDataset;
  table catAgeAtIndex sex 
	    indPriorHospCOPD indPriorHospMI indPriorHospHeartFailure
        indDiabetesType2
        indHadEchoPriorYear lvFunctionImpaired lvHypertrophy valveDiseaseModSev 
        indRxCYP3A4and5 indRxPgp;
run;


proc sql;
  create table Work.phregParameterEstimates (outcome varchar(32));
quit;


%macro foo (t, y);
  ods output ParameterEstimates = Work.temp;
  proc phreg data = Work.analyticDataset covsandwich(aggregate);
    class catAgeAtIndex (ref = "70-79")
	      sex (ref = "F")
          / param = ref;
    model &t * &y(0) = catAgeAtIndex sex 
	 	    	       indPriorHospCOPD indPriorHospMI indPriorHospHeartFailure
    	    	       indDiabetesType2
    	    	       indHadEchoPriorYear lvFunctionImpaired lvHypertrophy valveDiseaseModSev 
 	    	           indRxCYP3A4and5 indRxPgp
                       / ties = efron risklimits;
    id prochi;
  run;
  proc sql;
    alter table Work.temp add outcome varchar(32);
	update Work.temp set outcome = "&y";
  quit;
  data Work.phregParameterEstimates;
    set Work.phregParameterEstimates Work.temp;
  run;
  proc sql;
    drop table Work.temp;
  quit;
%mend foo;

%foo(daysMortalityAllCause, indMortalityAllCause1y);
%foo(daysMortalityCV, indMortalityCV1y);
%foo(daysHospVentArrhythmia, indHospVentArrhythmia1y);
%foo(daysHospSuddenCardiacArrest, indHospSuddenCardiacArrest1y);
%foo(daysHospMI, indHospMI1y);
%foo(daysHospCV, indHospCV1y);


proc export data = Work.phregParameterEstimates outfile = "data/processed/analyzeSubgroups.csv" dbms = csv replace;
  delimiter = ",";
run;


ods html close;
ods rtf close;
