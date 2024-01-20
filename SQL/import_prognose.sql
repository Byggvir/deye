use solar;

drop table if exists DEUSolarPrognose;

create table if not exists DEUSolarPrognose 
(
    `Beginn` DATETIME NOT NULL
    , `Ende` DATETIME NOT NULL
    , `Leistung` DOUBLE DEFAULT 0 COMMENT 'MW'
    , primary key ( `Beginn` ) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/Deye/data/Solarenergie_Prognose.csv'      
INTO TABLE `DEUSolarPrognose`
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

update DEUSolarPrognose set Ende =  adddate(Ende,  interval 1 day) where time(Ende) = '00:00:00';

create or replace view DEUSolarEnergie as
select 
    date(Beginn) as Datum
    , sum(Leistung) * timestampdiff(MINUTE,Beginn,Ende) / 60 as Energie
from DEUSolarPrognose 
group by Datum;
