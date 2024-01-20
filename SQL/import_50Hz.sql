use solar;


drop table if exists HRSolar;

create  TEMPORARY table if not exists HRSolar 
(
    `Beginn` DATETIME NOT NULL
    , `Ende` DATETIME NOT NULL
    , `Energie` DOUBLE DEFAULT 0 COMMENT 'MW'
    , primary key ( `Beginn` ) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

drop table if exists PgSolar;

create  TEMPORARY table if not exists PgSolar 
(
    `Beginn` DATETIME NOT NULL
    , `Ende` DATETIME NOT NULL
    , `Energie` DOUBLE DEFAULT 0 COMMENT 'MW'
    , primary key ( `Beginn` ) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/Deye/data/50HzHRSolar.csv'      
INTO TABLE `HRSolar`
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

LOAD DATA LOCAL 
INFILE '/data/git/R/Deye/data/50HzPgSolar.csv'      
INTO TABLE `PgSolar`
FIELDS TERMINATED BY ';'
IGNORE 1 ROWS;

update HRSolar set Ende =  adddate(Ende,  interval 1 day) where time(Ende) = '00:00:00';
update PgSolar set Ende =  adddate(Ende,  interval 1 day) where time(Ende) = '00:00:00';

drop table if exists Hz50Solar;

create table if not exists Hz50Solar 
(
    `Beginn` DATETIME NOT NULL
    , `Ende` DATETIME NOT NULL
    , `Prognose` BOOLEAN NOT NULL DEFAULT FALSE
    , `Leistung` DOUBLE DEFAULT 0 COMMENT 'MW'
    , primary key ( `Beginn` , `Prognose`) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 

select 
    `Beginn` as `Beginn`
    , `Ende` as `Ende`
    , FALSE as `Prognose`
    , `Energie` as `Energie`
from HRSolar
union
select 
    `Beginn` as `Beginn`
    , `Ende` as `Ende`
    , TRUE as `Prognose`
    , `Energie` as `Energie`
from PgSolar
;

create or replace view HZ50Energie as
select 
    date(Beginn) as Datum
    , Prognose as Prognose
    , sum(`Energie`) * timestampdiff(MINUTE,Beginn,Ende) / 60 as Energie
from Hz50Solar
group by 
    Datum
    , Prognose;
