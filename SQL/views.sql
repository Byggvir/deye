/* Views for solar */

use solar;

create or replace view max_power_day as

select 
    date(`time`) as `Datum`
    , `sn` as `sn`
    , max(`now_p`) as `Power` 
from `reports`
group by 
    `Datum`
    , `sn`;
