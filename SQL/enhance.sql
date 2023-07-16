use solar;

drop table if exists stations;
 
create table if not exists stations 
(   `id` BIGINT(20) NOT NULL AUTO_INCREMENT
    , name CHAR(64) DEFAULT ''
    , sn CHAR(64) DEFAULT ''
    , msvn CHAR(64) DEFAULT ''
    , ssvn CHAR(64) DEFAULT ''
    , pv_type CHAR(64) DEFAULT ''
    , mid CHAR(64) DEFAULT ""
    , ver CHAR(64) DEFAULT ""
    , wmode CHAR(64) DEFAULT ""
    , ap_ssid CHAR(64) DEFAULT ""
    , ap_ip4 CHAR(15) DEFAULT ""
    , ap_mac CHAR(17) DEFAULT ""
    , sta_ssid CHAR(64) DEFAULT ""
    , sta_rssi FLOAT DEFAULT 0
    , sta_ip4 CHAR(15) DEFAULT ""
    , sta_mac CHAR(17) DEFAULT ""
    , TS DATETIME DEFAULT NULL
    , location_lat DOUBLE DEFAULT 0
    , location_lon DOUBLE DEFAULT 0
    , primary key ( `id` ) 
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;
