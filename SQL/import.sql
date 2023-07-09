use DEYE;

drop table if exists deye;
-- 
create table if not exists deye 
(
    `time` DATETIME NOT NULL
    , sn CHAR(64) DEFAULT '' NOT NULL
    , msvn CHAR(64) DEFAULT '' NOT NULL
    , ssvn CHAR(64) DEFAULT '' NOT NULL
    , pv_type CHAR(64) DEFAULT '' NOT NULL
    , rate_p DOUBLE DEFAULT 0
    , now_p DOUBLE DEFAULT 0
    , today_e DOUBLE DEFAULT 0
    , total_e DOUBLE DEFAULT 0
    , alarm CHAR(64) DEFAULT ''
    , utime INT(11) DEFAULT 0
    , primary key (`time`, sn ) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

LOAD DATA LOCAL 
INFILE '/tmp/deye.csv'      
INTO TABLE `deye`
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

delete from deye where sn = '';
