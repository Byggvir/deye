use solar;

drop table if exists daily_yield;

create table if not exists daily_yield 
(
    `time` DATETIME NOT NULL
    , `sn` CHAR(64) DEFAULT '' NOT NULL
    , `today_e` DOUBLE DEFAULT 0
    , `manual` BOOLEAN DEFAULT TRUE
    , primary key (`time`,`sn`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

LOAD DATA LOCAL 
INFILE '/data/git/R/Deye/data/daily_yield.csv'      
INTO TABLE `daily_yield`
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;
