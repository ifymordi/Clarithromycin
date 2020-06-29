proc sql;
  create table Work.causeOfDeath as
    select distinct OriginalCauseOfDeath
	from (select OriginalCauseOfDeathA as OriginalCauseOfDeath from lib.GRO union corr
	      select OriginalCauseOfDeathB as OriginalCauseOfDeath from lib.GRO union corr
	      select OriginalCauseOfDeathC as OriginalCauseOfDeath from lib.GRO union corr
	      select OriginalCauseOfDeathD as OriginalCauseOfDeath from lib.GRO )
	order by OriginalCauseOfDeath;
  * select * from Work.causeOfDeath;
quit;

proc freq data =  lib.GRO;
  table icdcucd;
run;
