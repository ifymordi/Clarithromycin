x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

filename fig "figures";
goptions reset = all device = png;

ods html body = "output/modelHospCV.html" style = Statistical gpath = fig;
ods rtf body = "output/modelHospCV.rtf" style = Statistical;

libname lib "data/processed";




proc sql;
  create table Work.phregParameterEstimates (model varchar(94));
quit;

%include "lib/updateTable.sas";


title1 "Cox PH regression: Hospitalization for Any Cardiovascular Disease, 1-year";
title2 "Unadjusted";
proc lifetest data = lib.analyticDataset notable plots = survival cs = none;
  time daysHospCV * indHospCV1y(0);
  strata exposure;
  id prochi;
run;
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV1y(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(A Unadjusted);

title2 "Adjusted for demographic characteristics";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV1y(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(B Adjusted for demographic characteristics);

title2 "Adjusted for demographic & clinical characteristics";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV1y(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    indDiabetesType2
	    indCOPD
	    / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(C Adjusted for demographic & clinical characteristics);

title2 "Adjusted for demographic & clinical characteristics, medications, and echocardiogram results";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV1y(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    indDiabetesType2
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
	    indRxNSAID
	    indRxClariPriorYear
	    indHadEchoPriorYear
        lvFunctionImpaired
        lvHypertrophy
        lvDilated
        laDilated
        mveaAbnormal
        valveDiseaseModSev
        / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(%quote(D Adjusted for demographic & clinical characteristics, medications, and echocardiogram results));

title2 "Inverse propensity score weighted";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  where indCommonSupport = 1;
  class exposure (ref = "AMOXICILLIN") / param = ref;
  model daysHospCV * indHospCV1y(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  weight iptw;
  hazardratio exposure / diff = ref;
run;
%updateTable(E Inverse propensity score weighted);

title2 "Inverse propensity score weighted, stratified by prior hospitalization";
proc sort data = lib.analyticDataset out = lib.analyticDataset;
  by indHospPrior;
run;
proc freq data = lib.analyticDataset;
  table indHospPrior * exposure * indHospCV1y / nopercent nocol riskdiff relrisk;
run;
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  where indCommonSupport = 1;
  by indHospPrior;
  class exposure (ref = "AMOXICILLIN") / param = ref;
  model daysHospCV * indHospCV1y(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  weight iptw;
  hazardratio exposure / diff = ref;
run;
%updateTable(%quote(F Inverse propensity score weighted, stratified by prior hospitalization));

proc sql;
  create table Work.phregHospCV1y as
    select "Hospitalization for any cardiovascular disease, 1-year" as outcome,
	       A.*
	from Work.phregParameterEstimates A;
  drop table Work.phregParameterEstimates;
  create table Work.phregParameterEstimates (model varchar(94));
quit;


title1 "Cox PH regression: Hospitalization for Any Cardiovascular Disease, 30-day";
title2 "Unadjusted";
proc lifetest data = lib.analyticDataset notable plots = survival cs = none;
  time daysHospCV * indHospCV30d(0);
  strata exposure;
  id prochi;
run;
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV30d(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(A Unadjusted);

title2 "Adjusted for demographic characteristics";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV30d(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(B Adjusted for demographic characteristics);

title2 "Adjusted for demographic & clinical characteristics";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV30d(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    indDiabetesType2
	    indCOPD
	    / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(C Adjusted for demographic & clinical characteristics);

title2 "Adjusted for demographic & clinical characteristics, medications, and echocardiogram results";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV30d(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    indDiabetesType2
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
	    indRxNSAID
	    indRxClariPriorYear
	    indHadEchoPriorYear
        lvFunctionImpaired
        lvHypertrophy
        lvDilated
        laDilated
        mveaAbnormal
        valveDiseaseModSev
        / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(%quote(D Adjusted for demographic & clinical characteristics, medications, and echocardiogram results));

title2 "Inverse propensity score weighted";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  where indCommonSupport = 1;
  class exposure (ref = "AMOXICILLIN") / param = ref;
  model daysHospCV * indHospCV30d(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  weight iptw;
  hazardratio exposure / diff = ref;
run;
%updateTable(E Inverse propensity score weighted);

title2 "Inverse propensity score weighted, stratified by prior hospitalization";
proc sort data = lib.analyticDataset out = lib.analyticDataset;
  by indHospPrior;
run;
proc freq data = lib.analyticDataset;
  table indHospPrior * exposure * indHospCV30d / nopercent nocol riskdiff relrisk;
run;
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  where indCommonSupport = 1;
  by indHospPrior;
  class exposure (ref = "AMOXICILLIN") / param = ref;
  model daysHospCV * indHospCV30d(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  weight iptw;
  hazardratio exposure / diff = ref;
run;
%updateTable(%quote(F Inverse propensity score weighted, stratified by prior hospitalization));

proc sql;
  create table Work.phregHospCV30d as
    select "Hospitalization for any cardiovascular disease, 30-day" as outcome,
	       A.*
	from Work.phregParameterEstimates A;
  drop table Work.phregParameterEstimates;
  create table Work.phregParameterEstimates (model varchar(94));
quit;


title1 "Cox PH regression: Hospitalization for Any Cardiovascular Disease, 14-day";
title2 "Unadjusted";
proc lifetest data = lib.analyticDataset notable plots = survival cs = none;
  time daysHospCV * indHospCV14d(0);
  strata exposure;
  id prochi;
run;
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV14d(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(A Unadjusted);

title2 "Adjusted for demographic characteristics";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV14d(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(B Adjusted for demographic characteristics);

title2 "Adjusted for demographic & clinical characteristics";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV14d(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    indDiabetesType2
	    indCOPD
	    / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(C Adjusted for demographic & clinical characteristics);

title2 "Adjusted for demographic & clinical characteristics, medications, and echocardiogram results";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  class exposure (ref = "AMOXICILLIN")
        sex (ref = "M")
		postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
		/ param = ref;
  model daysHospCV * indHospCV14d(0) =
        exposure
		ageAtIndex
		sex
		postcode
		hbsimd5
        indNotUrban
	    indDiabetesType2
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
	    indRxNSAID
	    indRxClariPriorYear
	    indHadEchoPriorYear
        lvFunctionImpaired
        lvHypertrophy
        lvDilated
        laDilated
        mveaAbnormal
        valveDiseaseModSev
        / ties = efron risklimits;
  id prochi;
  hazardratio exposure / diff = ref;
run;
%updateTable(%quote(D Adjusted for demographic & clinical characteristics, medications, and echocardiogram results));

title2 "Inverse propensity score weighted";
ods output ParameterEstimates = Work.temp;
proc phreg data = lib.analyticDataset covsandwich(aggregate);
  where indCommonSupport = 1;
  class exposure (ref = "AMOXICILLIN") / param = ref;
  model daysHospCV * indHospCV14d(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  weight iptw;
  hazardratio exposure / diff = ref;
run;
%updateTable(E Inverse propensity score weighted);

title2 "Inverse propensity score weighted, stratified by prior hospitalization";
proc sort data = lib.analyticDataset out = Work.analyticDatasetSorted;
  by indHospPrior;
run;
proc freq data = Work.analyticDatasetSorted;
  table indHospPrior * exposure * indHospCV14d / nopercent nocol riskdiff relrisk;
run;
ods output ParameterEstimates = Work.temp;
proc phreg data = Work.analyticDatasetSorted covsandwich(aggregate);
  where indCommonSupport = 1;
  by indHospPrior;
  class exposure (ref = "AMOXICILLIN") / param = ref;
  model daysHospCV * indHospCV14d(0) =
        exposure
		/ ties = efron risklimits;
  id prochi;
  weight iptw;
  hazardratio exposure / diff = ref;
run;
%updateTable(%quote(F Inverse propensity score weighted, stratified by prior hospitalization));

proc sql;
  create table Work.phregHospCV14d as
    select "Hospitalization for any cardiovascular disease, 14-day" as outcome,
	       A.*
	from Work.phregParameterEstimates A;
  create table lib.phregHospCV as
    select * from Work.phregHospCV1y union corr
	select * from Work.phregHospCV30d union corr
	select * from Work.phregHospCV14d;
  drop table Work.phregParameterEstimates;
  drop table Work.phregHospCV1y;
  drop table Work.phregHospCV30d;
  drop table Work.phregHospCV14d;
  drop table Work.analyticDatasetSorted;
quit;




ods html close;
ods rtf close;
