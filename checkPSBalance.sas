x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

filename fig "figures";
goptions reset = all device = png;

ods html body = "output/checkPSBalance.html" style = Statistical gpath = fig;
ods rtf body = "output/checkPSBalance.rtf" style = Statistical;

libname lib "data/processed";


title1 "Propensity score modeling: Check balance";


proc rank data = lib.propensityScore out = Work.propensityScore groups = 10;
  ranks psDecile;
  var ps;
run;

proc sql;
  create table Work.wide as
    select exposure,
           psDecile,
           count(*) as denom,
           sum(catAgeAtIndex = "<30"  ) / count(*) as propAgeLessThan30,
           sum(catAgeAtIndex = "30-39") / count(*) as propAge3039,
           sum(catAgeAtIndex = "40-49") / count(*) as propAge4049,
           sum(catAgeAtIndex = "50-59") / count(*) as propAge5059,
           sum(catAgeAtIndex = "60-69") / count(*) as propAge6069,
           sum(catAgeAtIndex = "70-79") / count(*) as propAge7079,
           sum(catAgeAtIndex = "80+"  ) / count(*) as propAge80Plus,
		   sum(sex = "M") / count(*) as propSexMale,
	   	   sum(postcode = "DD") / count(*) as propPostcodeDD,
	   	   sum(hbsimd5 = 1) / count(*) as propHBSIMD1,
	   	   sum(hbsimd5 = 2) / count(*) as propHBSIMD2,
	   	   sum(hbsimd5 = 3) / count(*) as propHBSIMD3,
	   	   sum(hbsimd5 = 4) / count(*) as propHBSIMD4,
	   	   sum(hbsimd5 = 5) / count(*) as propHBSIMD5,
           sum(indNotUrban        ) / count(*) as propNotUrban          ,
	       sum(indDiabetesType2   ) / count(*) as propDiabetesType2     ,
	       sum(indCOPD            ) / count(*) as propCOPD              ,
	       sum(indRxACEI          ) / count(*) as propRxACEI            ,
	       sum(indRxARB           ) / count(*) as propRxARB             ,
	       sum(indRxAspirin       ) / count(*) as propRxAspirin         ,
	       sum(indRxBetaBlocker   ) / count(*) as propRxBetaBlocker     ,
	       sum(indRxClopidogrel   ) / count(*) as propRxClopidogrel     ,
	       sum(indRxDihyCCB       ) / count(*) as propRxDihyCCB         ,
	       sum(indRxLoopDiur      ) / count(*) as propRxLoopDiur        ,
	       sum(indRxMinCortAntag  ) / count(*) as propRxMinCortAntag    ,
	       sum(indRxNondihyCCB    ) / count(*) as propRxNondihyCCB      ,
	       sum(indRxStatin        ) / count(*) as propRxStatin          ,
	       sum(indRxThiazideDiur  ) / count(*) as propRxThiazideDiur    ,
	       sum(indRxWarfarin      ) / count(*) as propRxWarfarin        ,
	       sum(indRxCYP3A4and5    ) / count(*) as propRxCYP3A4and5      ,
	       sum(indRxPgp           ) / count(*) as propRxPgp             ,
	       sum(indRxNSAID         ) / count(*) as propRxNSAID           ,
	       sum(indRxClariPriorYear) / count(*) as propRxClariPriorYear  ,
	       sum(indHadEchoPriorYear) / count(*) as propHadEchoPriorYear  ,
           sum(lvFunctionImpaired ) / count(*) as propLVFunctionImpaired,
           sum(lvHypertrophy      ) / count(*) as propLVHypertrophy     ,
           sum(lvDilated          ) / count(*) as propLVDilated         ,
           sum(laDilated          ) / count(*) as propLADilated         ,
           sum(mveaAbnormal       ) / count(*) as propMVEAAbnormal      ,
           sum(valveDiseaseModSev ) / count(*) as propValveDiseaseModSev
    from Work.propensityScore
    group by exposure, psDecile;
  create table Work.long as
    select exposure, psDecile, denom, "Age <30"   as variable, propAgeLessThan30 as prop from Work.wide union corr
    select exposure, psDecile, denom, "Age 30-39" as variable, propAge3039       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Age 40-49" as variable, propAge4049       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Age 50-59" as variable, propAge5059       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Age 60-69" as variable, propAge6069       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Age 70-79" as variable, propAge7079       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Age 80+"   as variable, propAge80Plus     as prop from Work.wide union corr
    select exposure, psDecile, denom, "Male" as variable, propSexMale as prop from Work.wide union corr
    select exposure, psDecile, denom, "Postcode DD" as variable, propPostcodeDD as prop from Work.wide union corr
    select exposure, psDecile, denom, "HBSIMD 1"   as variable, propHBSIMD1 as prop from Work.wide union corr
    select exposure, psDecile, denom, "HBSIMD 2"   as variable, propHBSIMD2 as prop from Work.wide union corr
    select exposure, psDecile, denom, "HBSIMD 3"   as variable, propHBSIMD3 as prop from Work.wide union corr
    select exposure, psDecile, denom, "HBSIMD 4"   as variable, propHBSIMD4 as prop from Work.wide union corr
    select exposure, psDecile, denom, "HBSIMD 5"   as variable, propHBSIMD5 as prop from Work.wide union corr
    select exposure, psDecile, denom, "Not urban" as variable, propNotUrban           as prop from Work.wide union corr
    select exposure, psDecile, denom, "Diabetes Type 2" as variable, propDiabetesType2      as prop from Work.wide union corr
    select exposure, psDecile, denom, "COPD" as variable, propCOPD               as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx ACEI" as variable, propRxACEI             as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx ARB" as variable, propRxARB              as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Aspirin" as variable, propRxAspirin          as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Beta Blocker" as variable, propRxBetaBlocker      as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Clopidogrel" as variable, propRxClopidogrel      as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Dihydropyridine CCB" as variable, propRxDihyCCB          as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Loop Diuretic" as variable, propRxLoopDiur         as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Mineral Corticoid Antagonist" as variable, propRxMinCortAntag     as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Nondihydropyridine CCB" as variable, propRxNondihyCCB       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Statin" as variable, propRxStatin           as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Thiazide Diuretic" as variable, propRxThiazideDiur     as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Warfarin" as variable, propRxWarfarin         as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx CYP3A4/5" as variable, propRxCYP3A4and5       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx PGP" as variable, propRxPgp              as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx NSAID" as variable, propRxNSAID            as prop from Work.wide union corr
    select exposure, psDecile, denom, "Rx Clarithromycin Prior Year" as variable, propRxClariPriorYear   as prop from Work.wide union corr
    select exposure, psDecile, denom, "Had Echo Prior Year" as variable, propHadEchoPriorYear   as prop from Work.wide union corr
    select exposure, psDecile, denom, "LV Function Impaired" as variable, propLVFunctionImpaired as prop from Work.wide union corr
    select exposure, psDecile, denom, "LV Hypertrophy" as variable, propLVHypertrophy      as prop from Work.wide union corr
    select exposure, psDecile, denom, "LV Dilated" as variable, propLVDilated          as prop from Work.wide union corr
    select exposure, psDecile, denom, "LA Dilated" as variable, propLADilated          as prop from Work.wide union corr
    select exposure, psDecile, denom, "MVEA Abnormal" as variable, propMVEAAbnormal       as prop from Work.wide union corr
    select exposure, psDecile, denom, "Valve Disease Mod/Sev" as variable, propValveDiseaseModSev as prop from Work.wide ;
quit;

proc sgpanel data = Work.long;
  panelby variable;
  vline psDecile / response = prop group = exposure;
run;

proc sql;
  drop table Work.propensityScore;
  drop table Work.wide;
  drop table Work.long;
  drop table Work._sgsort_;
quit;



ods html close;
ods rtf close;
