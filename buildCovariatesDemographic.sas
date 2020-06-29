x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/buildCovariatesDemographic.html" style = Statistical;
ods rtf body = "output/buildCovariatesDemographic.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  create table lib.covariatesDemographic as
    select A.indexID,
           A.prochi,
           B.sex,
           floor((A.indexStart - B.anon_date_of_birth) / 365.25) as ageAtIndex,
           B.hbsimd5,
           B.hbsimd10,
           B.scsimd5,
           B.scsimd10,
           case
             when B.seur6 = 1 then "Large Urban Area"
             when B.seur6 = 2 then "Other Urban Area"
             when B.seur6 = 3 then "Accessible Small Town"
             when B.seur6 = 4 then "Remote Small Town"
             when B.seur6 = 5 then "Accessible Rural"
             when B.seur6 = 6 then "Remote Rural"
             else ""
             end as rurality,
           B.currentRecord,
           case
             when prxmatch("/^DD/", B.postcode_district) then "DD"
             when prxmatch("/^PH/", B.postcode_district) then "PH"
             else ""
             end as postcode
    from lib.exposureTimelines A left join 
         lib.demography B on (A.prochi = B.prochi)
    order by A.indexID;
quit;


proc contents data = lib.covariatesDemographic order = varnum;
run;


ods html close;
ods rtf close;
