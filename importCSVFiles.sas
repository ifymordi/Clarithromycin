x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/importCSVFiles.html" style = Statistical;
ods rtf body = "output/importCSVFiles.rtf" style = Statistical;

libname lib "data/processed";

%include "lib/import.sas";

%import(CD Diabetes Summary/CD Diabetes Summary.csv, CDDiabSummary);
%import(CHI Deaths/CHI Deaths.csv, CHIDeaths);
%import(demography/demography.csv, demography);
%import(GRO (new)/GRO (new).csv, GRO);
%import(Prescribing/Precribing.csv, Prescribing);
%import(SMR01/SMR01.csv, SMR);
%import(TARDIS_COPD_Diagnosis/TARDIS_COPD_Diagnosis.csv, COPD);
%import(TARDIS_Height_Weight_Spirometry_2001_2014/TARDIS_Height_Weight_Spirometry_2001_2014.csv, HtWtSpirom);
%import(TARDIS_Oxygen/TARDIS_Oxygen.csv, Oxygen);

ods html close;
ods rtf close;
