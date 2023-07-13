create database if not exists solar;

grant all on solar.* to 'statistik'@'localhost' ;

use solar;

drop table if exists stations;
 
create table if not exists stations 
(   `id` BIGINT(20) NOT NULL AUTO_INCREMENT
    , name CHAR(64) DEFAULT ''
    , sn CHAR(64) DEFAULT ''
    , msvn CHAR(64) DEFAULT ''
    , ssvn CHAR(64) DEFAULT ''
    , pv_type CHAR(64) DEFAULT ''
    , software CHAR(64) DEFAULT ''
    , location_lat DOUBLE DEFAULT 0
    , location_lon DOUBLE DEFAULT 0
    , primary key ( `id` ) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

/* Include my micro-inverter as DEFAULT */

insert into stations values (1,'Mittelerde','2304037831','','','','',50.62094487,6.9616949 );
