x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

filename fig "figures";
goptions reset = all device = png;

ods html body = "output/modelPropensityScore.html" style = Statistical gpath = fig;
ods rtf body = "output/modelPropensityScore.rtf" style = Statistical;

libname lib "data/processed" filelockwait = 30;


title1 "Propensity score modeling";


ods output Statistics = Work.Statistics TTests = Work.TTests;
proc ttest data = lib.analyticDataset;
  class exposure;
  var ageAtIndex;
run;
proc sql;
  create table Work.ageAtIndex as
    select "ageAtIndex" as var, 1 as col, strip(put(mean, 8.1)) || " (" || strip(put(stddev, 8.1)) || ")" as text from Work.Statistics where class = "CLARITHROMYCIN" union corr
	select "ageAtIndex" as var, 2 as col, strip(put(mean, 8.1)) || " (" || strip(put(stddev, 8.1)) || ")" as text from Work.Statistics where class = "AMOXICILLIN" union corr
	select "ageAtIndex" as var, 3 as col, case when probt < 0.0001 then "< 0.0001" else strip(put(probt, 8.4)) end as text from Work.TTests where variances = "Unequal";
  drop table Work.Statistics;
  drop table Work.TTests;
quit;

ods output Chisq = Work.Chisq CrossTabFreqs = Work.CrossTabFreqs;
proc freq data = lib.analyticDataset;
  table sex * exposure / chisq;
run;
proc sql;
  create table Work.sexMale as
    select "sexMale" as var, 1 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where sex = "M" & exposure = "CLARITHROMYCIN" union corr
	select "sexMale" as var, 2 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where sex = "M" & exposure = "AMOXICILLIN" union corr
	select "sexMale" as var, 3 as col, case when prob < 0.0001 then "< 0.0001" else strip(put(prob, 8.4)) end as text from Work.Chisq where statistic = "Chi-Square";
  drop table Work.Chisq;
  drop table Work.CrossTabFreqs;
quit;

ods output Chisq = Work.Chisq CrossTabFreqs = Work.CrossTabFreqs;
proc freq data = lib.analyticDataset;
  table postcode * exposure / chisq;
run;
proc sql;
  create table Work.postcodeDD as
    select "postcodeDD" as var, 1 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where postcode = "DD" & exposure = "CLARITHROMYCIN" union corr
	select "postcodeDD" as var, 2 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where postcode = "DD" & exposure = "AMOXICILLIN" union corr
	select "postcodeDD" as var, 3 as col, case when prob < 0.0001 then "< 0.0001" else strip(put(prob, 8.4)) end as text from Work.Chisq where statistic = "Chi-Square";
  drop table Work.Chisq;
  drop table Work.CrossTabFreqs;
quit;

ods output Chisq = Work.Chisq CrossTabFreqs = Work.CrossTabFreqs;
proc freq data = lib.analyticDataset;
  table hbsimd5 * exposure / chisq;
run;
proc sql;
  create table Work.hbsimd5 as
    select "hbsimd5" as var, 1 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where hbsimd5 = 5 & exposure = "CLARITHROMYCIN" union corr
	select "hbsimd5" as var, 2 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where hbsimd5 = 5 & exposure = "AMOXICILLIN" union corr
	select "hbsimd5" as var, 3 as col, case when prob < 0.0001 then "< 0.0001" else strip(put(prob, 8.4)) end as text from Work.Chisq where statistic = "Chi-Square";
  drop table Work.Chisq;
  drop table Work.CrossTabFreqs;
quit;

%macro chisq (x);
  ods output Chisq = Work.Chisq CrossTabFreqs = Work.CrossTabFreqs;
  proc freq data = lib.analyticDataset;
    table &x * exposure / chisq;
  run;
  proc sql;
    create table Work.&x as
      select "&x" as var, 1 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where &x = 1 & exposure = "CLARITHROMYCIN" union corr
  	  select "&x" as var, 2 as col, strip(put(colpercent, 8.1)) || "%" || " (" || strip(put(frequency, comma10.)) || ")" as text from Work.CrossTabFreqs where &x = 1 & exposure = "AMOXICILLIN" union corr
  	  select "&x" as var, 3 as col, case when prob < 0.0001 then "< 0.0001" else strip(put(prob, 8.4)) end as text from Work.Chisq where statistic = "Chi-Square";
    drop table Work.Chisq;
    drop table Work.CrossTabFreqs;
  quit;
%mend chisq;

%chisq(indNotUrban);
%chisq(indDiabetesType2);
%chisq(indCOPD);
%chisq(indRxACEI);
%chisq(indRxARB);
%chisq(indRxAspirin);
%chisq(indRxBetaBlocker);
%chisq(indRxClopidogrel);
%chisq(indRxDihyCCB);
%chisq(indRxLoopDiur);
%chisq(indRxMinCortAntag);
%chisq(indRxNondihyCCB);
%chisq(indRxStatin);
%chisq(indRxThiazideDiur);
%chisq(indRxWarfarin);
%chisq(indRxCYP3A4and5);
%chisq(indRxPgp);
%chisq(indRxNSAID);
%chisq(indRxClariPriorYear);
%chisq(indHadEchoPriorYear);
%chisq(lvFunctionImpaired);
%chisq(lvHypertrophy);
%chisq(lvDilated);
%chisq(laDilated);
%chisq(mveaAbnormal);
%chisq(valveDiseaseModSev);

proc sql;
  create table Work.table1Long as
    select  1 as row, * from Work.ageAtIndex union corr
	select  2 as row, * from Work.sexMale union corr
	select  3 as row, * from Work.postcodeDD union corr
	select  4 as row, * from Work.hbsimd5 union corr
    select  5 as row, * from Work.indNotUrban union corr
    select  6 as row, * from Work.indDiabetesType2 union corr
    select  7 as row, * from Work.indCOPD union corr
    select  8 as row, * from Work.indRxACEI union corr
    select  9 as row, * from Work.indRxARB union corr
    select 10 as row, * from Work.indRxAspirin union corr
    select 11 as row, * from Work.indRxBetaBlocker union corr
    select 12 as row, * from Work.indRxClopidogrel union corr
    select 13 as row, * from Work.indRxDihyCCB union corr
    select 14 as row, * from Work.indRxLoopDiur union corr
    select 15 as row, * from Work.indRxMinCortAntag union corr
    select 16 as row, * from Work.indRxNondihyCCB union corr
    select 17 as row, * from Work.indRxStatin union corr
    select 18 as row, * from Work.indRxThiazideDiur union corr
    select 19 as row, * from Work.indRxWarfarin union corr
    select 20 as row, * from Work.indRxCYP3A4and5 union corr
    select 21 as row, * from Work.indRxPgp union corr
    select 22 as row, * from Work.indRxNSAID union corr
    select 23 as row, * from Work.indRxClariPriorYear union corr
    select 24 as row, * from Work.indHadEchoPriorYear union corr
    select 25 as row, * from Work.lvFunctionImpaired union corr
    select 26 as row, * from Work.lvHypertrophy union corr
    select 27 as row, * from Work.lvDilated union corr
    select 28 as row, * from Work.laDilated union corr
    select 29 as row, * from Work.mveaAbnormal union corr
    select 30 as row, * from Work.valveDiseaseModSev 
	order by row, col;
    drop table Work.ageAtIndex;
	drop table Work.sexMale;
	drop table Work.postcodeDD;
	drop table Work.hbsimd5;
    drop table Work.indNotUrban;
    drop table Work.indDiabetesType2;
    drop table Work.indCOPD;
    drop table Work.indRxACEI;
    drop table Work.indRxARB;
    drop table Work.indRxAspirin;
    drop table Work.indRxBetaBlocker;
    drop table Work.indRxClopidogrel;
    drop table Work.indRxDihyCCB;
    drop table Work.indRxLoopDiur;
    drop table Work.indRxMinCortAntag;
    drop table Work.indRxNondihyCCB;
    drop table Work.indRxStatin;
    drop table Work.indRxThiazideDiur;
    drop table Work.indRxWarfarin;
    drop table Work.indRxCYP3A4and5;
    drop table Work.indRxPgp;
    drop table Work.indRxNSAID;
    drop table Work.indRxClariPriorYear;
    drop table Work.indHadEchoPriorYear;
    drop table Work.lvFunctionImpaired;
    drop table Work.lvHypertrophy;
    drop table Work.lvDilated;
    drop table Work.laDilated;
    drop table Work.mveaAbnormal;
    drop table Work.valveDiseaseModSev;
quit;
proc transpose data = Work.table1Long out= Work.table1;
  by row var;
  var text;
run;
proc sql;
  drop table Work.table1Long;
run;
data Work.table1;
  set Work.table1;
  rename col1 = expClari;
  rename col2 = expAmoxi;
  rename col3 = pValue;
  drop row _name_:
run;
proc export data = Work.table1 outfile = "data/processed/modelPropensityScoreCovariatesTable1.csv" dbms = csv replace;
  delimiter = ",";
run;


proc logistic data = lib.analyticDataset;
  class catAgeAtIndex (ref = "80+")
        sex (ref = "M")
     	postcode (ref = "DD")
		hbsimd5 (ref = last)
		scsimd5 (ref = last)
        / param = ref;
  model exposure (event = "CLARITHROMYCIN") =
		catAgeAtIndex
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
        valveDiseaseModSev;
  output out = lib.propensityScore predicted = ps;
run;

/* Common support region */
proc means data = lib.propensityScore n nmiss mean std min q1 median q3 max maxdec = 3;
  class exposure;
  var ps;
run;
proc sql;
  create table Work.commonSupportRegion as
    select max(minPS) as commonSupportLowerBound, 
           min(maxPS) as commonSupportUpperBound
    from (select exposure, min(ps) as minPS, max(ps) as maxPS
          from lib.propensityScore
          group by exposure);
  select * from Work.commonSupportRegion;
  alter table lib.propensityScore add commonSupportLowerBound numeric;
  alter table lib.propensityScore add commonSupportUpperBound numeric;
  alter table lib.propensityScore add indCommonSupport integer;
  update lib.propensityScore
    set commonSupportLowerBound = (select commonSupportLowerBound from Work.commonSupportRegion),
        commonSupportUpperBound = (select commonSupportUpperBound from Work.commonSupportRegion);
  update lib.propensityScore
    set indCommonSupport = case
                             when ps = . then .
                             when commonSupportLowerBound <= ps <= commonSupportUpperBound then 1
                             else 0
                             end;
  select exposure,
         sum(indCommonSupport = 1) as n1,
         sum(indCommonSupport = 1) / sum(^missing(indCommonSupport)) format = percent9.3 as pct1,
         sum(indCommonSupport = 0) as n0,
         sum(indCommonSupport = 0) / sum(^missing(indCommonSupport)) format = percent9.3 as pct0
    from lib.propensityScore
    group by exposure;
quit;

/* Calculate IPTW */
proc sql;
  alter table lib.propensityScore add iptw numeric;
  update lib.propensityScore
    set iptw = (exposure = "CLARITHROMYCIN") / ps +
               (exposure = "AMOXICILLIN") / (1 -  ps);
quit;
proc means data = lib.propensityScore n nmiss mean std min q1 median q3 max maxdec = 3;
  class indCommonSupport exposure;
  var ps iptw;
run;


proc sgpanel data = lib.propensityScore;
  panelby exposure;
  density ps / type = kernel;
run;
proc sgpanel data = lib.propensityScore;
  where indCommonSupport;
  panelby exposure;
  density ps / type = kernel;
run;


proc sql;
  create table Work.temp as select * from lib.analyticDataset;
  create table lib.analyticDataset as
    select A.*, B.ps, B.indCommonSupport, B.iptw
    from Work.temp A inner join
         lib.propensityScore B on (A.indexID = B.indexID);
  drop table Work.temp;
quit;




ods html close;
ods rtf close;
proc datasets lib = Work nolist nodetails;
  delete _DOCTMP:;
run;
