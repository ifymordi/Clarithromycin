x cd "P:\Project 3393 - CV risk prediction score for use in patients prescribed macrolide antibiotics";

ods html body = "output/samplePROCHI.html" style = Statistical;

libname lib "data/processed";

proc sql;
  select case
           when 0 <= input(substr(prochi, length(prochi) - 1, 2), 2.) < 1 then "00"
           else "01-99"
           end as last2digits,
         count(distinct prochi) as n,
         count(distinct prochi) / (select count(distinct prochi) from lib.demography) format = percent8.1 as pct
    from lib.demography
    group by calculated last2digits;
  create table lib.samplePROCHI as
    select prochi
    from lib.demography
    where 0 <= input(substr(prochi, length(prochi) - 1, 2), 2.) <  1;
quit;

ods html close;
