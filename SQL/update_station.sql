USE solar;

drop table if exists status_station_last;
create temporary table if not exists status_station_last 
( TS DATETIME DEFAULT NULL
    , sn CHAR(64) DEFAULT ""
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
    , primary key (TS, sn)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 
;

LOAD DATA LOCAL 
INFILE '/tmp/status_station_last.csv'      
INTO TABLE status_station_last
FIELDS TERMINATED BY ','
IGNORE 0 ROWS;

update stations as S1 
join status_station_last as S2 
on S1.sn = S2.sn 
set 
    S1.msvn = S2.msvn
    , S1.ssvn = S2.ssvn
    , S1.pv_type = S2.pv_type
    , S1.mid = S2.mid
    , S1.ver = S2.ver
    , S1.wmode = S2.wmode
    , S1.ap_ssid = S2.ap_ssid
    , S1.ap_ip4 = S2.ap_ip4
    , S1.ap_mac = S2.ap_mac
    , S1.sta_ssid = S2.sta_ssid
    , S1.sta_rssi = S2.sta_rssi
    , S1.sta_ip4 = S2.sta_ip4
    , S1.sta_mac = S2.sta_mac
    , S1.TS = S2.TS 
where 
    S1.msvn <> S2.msvn
    or S1.ssvn <> S2.ssvn
    or S1.pv_type <> S2.pv_type
    or S1.mid <> S2.mid
    or S1.ver <> S2.ver
    or S1.wmode <> S2.wmode
    or S1.ap_ssid <> S2.ap_ssid
    or S1.ap_ip4 <> S2.ap_ip4
    or S1.ap_mac <> S2.ap_mac
    or S1.sta_ssid <> S2.sta_ssid
    or S1.sta_rssi <> S2.sta_rssi
    or S1.sta_ip4 <> S2.sta_ip4
    or S1.sta_mac <> S2.sta_mac
;
