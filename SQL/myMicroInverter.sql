-- Insert my micro inverter

use solar;

insert into stations 
set sn = '2304037831'
    , name = 'Mittelerde'
    , location_lat = 50.62094487
    , location_lon = 6.9616949 
    , TS = now();
