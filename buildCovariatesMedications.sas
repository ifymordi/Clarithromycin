x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/buildCovariatesMedications.html" style = Statistical;
ods rtf body = "output/buildCovariatesMedications.rtf" style = Statistical;

libname lib "data/processed";


proc sql;
  create table Work.approved_name as
    select approved_name,
           count(*) as n
    from lib.Prescribing
    group by approved_name;
  create table Work.lookupRx as
    select "ACE inhibitor" as class, * 
      from Work.approved_name 
      where prxmatch("/PRIL\b/", approved_name) union corr
    select "ARB" as class, * 
      from Work.approved_name 
      where prxmatch("/SARTAN\b/", approved_name) union corr
    select "Beta blocker" as class, * 
	  from Work.approved_name 
	  where prxmatch("/[AO]LOL\b/", approved_name) union corr
    select "Dihydropyridine CCB" as class, * 
	  from Work.approved_name 
	  where prxmatch("/DIPINE\b/", approved_name) union corr
    select "Non-dihydropyridine CCB" as class, * 
	  from Work.approved_name 
	  where prxmatch("/(FENDILINE)|(PAMIL)\b/", approved_name) union corr
    select "Non-dihydropyridine CCB" as class, * 
	  from Work.approved_name 
	  where prxmatch("/(FENDILINE)|(PAMIL)\b/", approved_name) union corr
    select "Statin" as class, * 
	  from Work.approved_name 
	  where prxmatch("/STATIN\b/", approved_name) union corr
    select "Loop diuretic" as class, * 
	  from Work.approved_name 
	  where prxmatch("/FUROSEMIDE|BUMETANIDE|ETHACRYNIC|TORSEMIDE\b/", approved_name) union corr
    select "Thiazide diuretic" as class, * 
	  from Work.approved_name 
	  where prxmatch("/THIAZIDE\b/", approved_name) union corr
    select "Mineralcorticoid antagonist" as class, * 
	  from Work.approved_name 
	  where prxmatch("/SPIRONOLACTONE|EPLERENONE|CANRENONE|FINERENONE\b/", approved_name) union corr
    select "Aspirin" as class, * 
	  from Work.approved_name 
	  where prxmatch("/\bASPIRIN\b/", approved_name) union corr
    select "Clopidogrel" as class, * 
	  from Work.approved_name 
	  where prxmatch("/\bCLOPIDOGREL\b/", approved_name) union corr
    select "Warfarin" as class, * 
	  from Work.approved_name 
	  where prxmatch("/\bWARFARIN\b/", approved_name) union corr
    select "CYP3A4/5" as class, * 
      from Work.approved_name 
      where prxmatch("/KETOCONAZOLE|FLUCONAZOLE|VERAPAMIL|DILTIAZEM|CIMETIDINE|GABAPENTIN|PREBABALIN/", approved_name) union corr
    select "P Glycoprotein" as class, * 
      from Work.approved_name 
      where prxmatch("/DIGOXIN|DABIGATRAN|XABAN\b|AMIODARONE|ATORVASTATIN|OMEPRAZOLE|VERAPAMIL|DILTIAZEM|DIPINE\b/", approved_name) union corr
    select "Dipine" as class, * 
      from Work.approved_name 
      where prxmatch("/DIPINE\b/", approved_name) union corr
    select "Atorvastatin" as class, * 
      from Work.approved_name 
      where prxmatch("/ATORVASTATIN/", approved_name) union corr
    select "Diltiazem" as class, * 
      from Work.approved_name 
      where prxmatch("/DILTIAZEM/", approved_name) union corr
    select "Digoxin" as class, * 
      from Work.approved_name 
      where prxmatch("/DIGOXIN/", approved_name) union corr
    select "Amiodarone" as class, * 
      from Work.approved_name 
      where prxmatch("/AMIODARONE/", approved_name) union corr
    select "NSAID" as class, * 
      from Work.approved_name 
      where prxmatch("/\bASPIRIN\b|DIFLUNISAL|PRO[FXZ]EN\b|INDOMETACIN|TOLMETIN|((ND)|(OL)|(FEN))AC\b|NABUMETONE|OXICAM\b|COXIB\b/", approved_name);
  select class, count(*) as countApprovedNames
    from Work.lookupRx
	group by class;
quit;

proc export data = Work.approved_name outfile = "data/processed/approved_name.csv" dbms = csv replace;
run;
proc export data = Work.lookupRx outfile = "data/processed/lookupRx.csv" dbms = csv replace;
run;


proc sql;
  create table Work.medications as
    select A.indexID,
           A.prochi,
           A.indexStart,
           C.class,
           max(datepart(B.corrected_prescribed_date)) format = yymmdd10. as mostRecentRxDate
    from lib.exposureTimelines A inner join 
         lib.Prescribing B on (A.prochi = B.prochi &
                               datepart(B.corrected_prescribed_date) <= A.indexStart) inner join
         Work.lookupRx C on (B.approved_name = C.approved_name)
    group by A.indexID,
             A.prochi,
             A.indexStart,
             C.class;
  create table Work.clarithromycinStartDate as
    select distinct 
           prochi, 
           datepart(corrected_prescribed_date) format = yymmdd10. as clarithromycinStartDate
    from lib.Prescribing
    where Approved_Name = "CLARITHROMYCIN"
    order by prochi, calculated clarithromycinStartDate;
  create table lib.covariatesMedications as
    select A.*,
		   max(0, B.indRxACEI) as indRxACEI,
		   max(0, C.indRxARB) as indRxARB,
		   max(0, D.indRxAspirin) as indRxAspirin,
		   max(0, E.indRxBetaBlocker) as indRxBetaBlocker,
		   max(0, F.indRxClopidogrel) as indRxClopidogrel,
		   max(0, G.indRxDihyCCB) as indRxDihyCCB,
		   max(0, H.indRxLoopDiur) as indRxLoopDiur,
		   max(0, I.indRxMinCortAntag) as indRxMinCortAntag,
		   max(0, J.indRxNondihyCCB) as indRxNondihyCCB,
		   max(0, K.indRxStatin) as indRxStatin,
		   max(0, L.indRxThiazideDiur) as indRxThiazideDiur,
		   max(0, M.indRxWarfarin) as indRxWarfarin,
		   max(0, N.indRxCYP3A4and5) as indRxCYP3A4and5,
		   max(0, O.indRxPgp) as indRxPgp,
		   max(0, P.indRxNSAID) as indRxNSAID,
		   /* max(0, Q.indRxSteroid) as indRxSteroid, */
		   max(0, R.indRxDipine) as indRxDipine,
		   max(0, S.indRxAtorvastatin) as indRxAtorvastatin,
		   max(0, T.indRxDiltiazem) as indRxDiltiazem,
		   max(0, U.indRxDigoxin) as indRxDigoxin,
		   max(0, V.indRxAmiodarone) as indRxAmiodarone,
		   max(max(0, intnx("YEAR", A.indexStart, -1) <=  ZZ.clarithromycinStartDate < A.indexStart)) as indRxClariPriorYear,
		   count(distinct ZZ.clarithromycinStartDate) as countRxClarithromycin
    from (select distinct indexID, prochi, indexStart from Work.medications) A left join
	     (select indexID, 1 as indRxACEI         from Work.medications where class = "ACE inhibitor"              ) B on (A.indexID = B.indexID) left join
	     (select indexID, 1 as indRxARB          from Work.medications where class = "ARB"                        ) C on (A.indexID = C.indexID) left join
	     (select indexID, 1 as indRxAspirin      from Work.medications where class = "Aspirin"                    ) D on (A.indexID = D.indexID) left join
	     (select indexID, 1 as indRxBetaBlocker  from Work.medications where class = "Beta blocker"               ) E on (A.indexID = E.indexID) left join
	     (select indexID, 1 as indRxClopidogrel  from Work.medications where class = "Clopidogrel"                ) F on (A.indexID = F.indexID) left join
	     (select indexID, 1 as indRxDihyCCB      from Work.medications where class = "Dihydropyridine CCB"        ) G on (A.indexID = G.indexID) left join
	     (select indexID, 1 as indRxLoopDiur     from Work.medications where class = "Loop diuretic"              ) H on (A.indexID = H.indexID) left join
	     (select indexID, 1 as indRxMinCortAntag from Work.medications where class = "Mineralcorticoid antagonist") I on (A.indexID = I.indexID) left join
	     (select indexID, 1 as indRxNondihyCCB   from Work.medications where class = "Non-dihydropyridine CCB"    ) J on (A.indexID = J.indexID) left join
	     (select indexID, 1 as indRxStatin       from Work.medications where class = "Statin"                     ) K on (A.indexID = K.indexID) left join
	     (select indexID, 1 as indRxThiazideDiur from Work.medications where class = "Thiazide diuretic"          ) L on (A.indexID = L.indexID) left join
	     (select indexID, 1 as indRxWarfarin     from Work.medications where class = "Warfarin"                   ) M on (A.indexID = M.indexID) left join
	     (select indexID, 1 as indRxCYP3A4and5   from Work.medications where class = "CYP3A4/5"                   ) N on (A.indexID = N.indexID) left join
	     (select indexID, 1 as indRxPgp          from Work.medications where class = "P Glycoprotein"             ) O on (A.indexID = O.indexID) left join
	     (select indexID, 1 as indRxNSAID        from Work.medications where class = "NSAID"                      ) P on (A.indexID = P.indexID) left join
	     /* (select indexID, 1 as indRxSteroid      from Work.medications where class = "Steroid"                    ) Q on (A.indexID = Q.indexID) left join */
	     (select indexID, 1 as indRxDipine       from Work.medications where class = "Dipine"                     ) R on (A.indexID = R.indexID) left join
	     (select indexID, 1 as indRxAtorvastatin from Work.medications where class = "Atorvastatin"               ) S on (A.indexID = S.indexID) left join
	     (select indexID, 1 as indRxDiltiazem    from Work.medications where class = "Diltiazem"                  ) T on (A.indexID = T.indexID) left join
	     (select indexID, 1 as indRxDigoxin      from Work.medications where class = "Digoxin"                    ) U on (A.indexID = U.indexID) left join
	     (select indexID, 1 as indRxAmiodarone   from Work.medications where class = "Amiodarone"                 ) V on (A.indexID = V.indexID) left join
		 Work.clarithromycinStartDate ZZ on (A.prochi = ZZ.prochi & ZZ.clarithromycinStartDate < A.indexStart)
	group by A.indexID, A.prochi, A.indexStart;
  drop table Work.lookupRx;
  drop table Work.medications;
  drop table Work.clarithromycinStartDate;
  drop table Work.approved_name;
quit;


proc contents data = lib.covariatesMedications order = varnum;
run;

proc means data = lib.covariatesMedications n nmiss mean min max;
  var _numeric_;
run;

proc freq data = lib.covariatesMedications;
  table countRxClarithromycin;
run;

 

ods html close;
ods rtf close;
