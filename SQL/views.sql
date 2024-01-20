/* Views for solar */

use solar;

/* --- */

create or replace view max_power_day as
select 
    date(`time`) as `Datum`
    , `sn` as `sn`
    , max(`now_p`) as `Power` 
from `reports`
where 
  `sn` <> ''
group by 
    `Datum`
    , `sn`;

/* --- */

create or replace view energy_day as
select 
    date(`time`) as `Datum`
    , `sn` as `sn`
    , max(`total_e`) as `Energy` 
from `reports`
where 
  `sn` <> ''
group by 
    `Datum`
    , `sn`;

/* --- */

create or replace view energy_week as
select 
      yearweek( `time`,3) as Woche
    , yearweek( adddate(`time`, INTERVAL -7 DAY),3) as Vorwoche  
    , max(`total_e`) as Energy
from reports
group by 
    Woche;
    
/* --- */

create or replace view energy_month as
select
    2023 as Jahr
    , 6 as Monat
    , 0 as Energy
union
select
      year(`time`) as Jahr
    , month(`time`) as Monat
    , max(`total_e`) as Energy
from reports
group by 
    Jahr
    , Monat
;

/* --- */

create or replace view energy_per_week as
select 
    E1.Woche as Kw
    , round(E1.Energy - E2.Energy,1) as Energy
from energy_week as E1 
join energy_week as E2
on 
    E1.Vorwoche = E2.Woche ;

/* --- */

create or replace view energy_per_month as
select 
    E1.Jahr as Jahr
    , E1.Monat as Monat
    , round(E1.Energy - E2.Energy,1) as Energy
from energy_month as E1 
join energy_month as E2
on 
    ( E1.Monat > 1 and E1.Monat = E2.Monat + 1 and E1.Jahr = E2.Jahr )
    or ( E1.Monat = 1 and E2.Monat = 12 and E1.Jahr = E2.Jahr + 1 );

/* --- */

create or replace view solarenergy as
select 
    date( R.dateutc ) as Datum 
    , year( R.dateutc ) as Jahr
    , month( R.dateutc ) as Monat
    , round( sum( delta * R.solarradiation ) / 3600000, 1 ) as Energy
    from weatherstations.reports as R
    join weatherstations.TimeUntilNextReport as T
    on T.dateutc = R.dateutc
    group by Datum
;

create or replace view solarratio as 
select
    s.Datum
    , round( max(today_e) / s.Energy * 100, 1 ) as Ratio 
from solarenergy as s 
join reports as r 
on s.Datum = date(r.time) 
group by 
    s.Datum;

create or replace view energy_year as
select
    year(adddate(datum,11)) as Jahr
    , max(Energy) as Energy
from energy_day
where
    dayofyear(adddate(datum,11)) = 1
union
select
    2023 as Jahr
    , 0 as Energy
;

create or replace view Production as

select
    P.Datum as Datum 
    , year(adddate(datum,10)) as Jahr
    , dayofyear(adddate(datum,10)) as Tag
    , P.Energy - E.Energy as Energy
from energy_day as P
join energy_year as E
on year(adddate(Datum,10)) = E.Jahr
group by 
    Jahr
    , Tag 
UNION
select
    Datum as Datum
    , year(Datum) + 1 as Jahr
    , 0 as Tag 
    , 0 as Energy
from energy_day
where
  month(Datum) = 12
  and day(Datum) = 21
 ;
