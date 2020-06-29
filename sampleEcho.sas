

proc sort data =  Work.echo;
  by lvFunctionImpaired;
run;
proc surveyselect data =  Work.echo (keep = prochi lvFunctionImpaired lvefGrade lvText)
  seed = 20180411 method = srs n = 20 out = Work.sampleEchoLVEF;
  strata lvFunctionImpaired;
run;
proc export data = Work.sampleEchoLVEF outfile = "data/processed/sampleEchoLVEF.csv" dbms = tab replace;
run;

proc sort data =  Work.echo;
  by lvHypertrophy;
run;
proc surveyselect data =  Work.echo (keep = prochi lvHypertrophy lvhGrade lvText)
  seed = 20180411 method = srs n = 20 out = Work.sampleEchoLVH;
  strata lvHypertrophy;
run;
proc export data = Work.sampleEchoLVH outfile = "data/processed/sampleEchoLVH.csv" dbms = tab replace;
run;

proc sort data =  Work.echo;
  by lvDilated;
run;
proc surveyselect data =  Work.echo (keep = prochi lvDilated lviddundefined lvText)
  seed = 20180411 method = srs n = 20 out = Work.sampleEchoLVDilated;
  strata lvDilated;
run;
proc export data = Work.sampleEchoLVDilated outfile = "data/processed/sampleEchoLVDilated.csv" dbms = tab replace;
run;

proc sort data =  Work.echo;
  by laDilated;
run;
proc surveyselect data =  Work.echo (keep = prochi laDilated la_dimensionundefined lvText)
  seed = 20180411 method = srs n = 20 out = Work.sampleEchoLADilated;
  strata laDilated;
run;
proc export data = Work.sampleEchoLADilated outfile = "data/processed/sampleEchoLADilated.csv" dbms = tab replace;
run;

proc sort data =  Work.echo;
  by mveaAbnormal;
run;
proc surveyselect data =  Work.echo (keep = prochi mveaAbnormal mv_ea)
  seed = 20180411 method = srs n = 20 out = Work.sampleEchoMVEAAbnormal;
  strata mveaAbnormal;
run;
proc export data = Work.sampleEchoMVEAAbnormal outfile = "data/processed/sampleEchoMVEAAbnormal.csv" dbms = tab replace;
run;

proc sort data =  Work.echo;
  by valveDiseaseModSev;
run;
proc surveyselect data =  Work.echo (keep = prochi valveDiseaseAny valveDiseaseModSev valveDiseaseGrade valveDiseaseText)
  seed = 20180411 method = srs n = 20 out = Work.sampleEchoValveDisease;
  strata valveDiseaseModSev;
run;
proc export data = Work.sampleEchoValveDisease outfile = "data/processed/sampleEchoValveDisease.csv" dbms = tab replace;
run;
