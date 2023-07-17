use solar;

update reports as R1 
join reports as R2 
on 
    R2.time = addtime(R1.time,"00:01:00")
join reports as R3 
on 
    R1.time = addtime(R3.time,"00:01:00")
set 
    R1.sn = R2.sn
    , R1.total_e = R3.total_e
    , R1.today_e = R3.today_e
    , R1.now_p  = (R2.now_p + R3.now_p) / 2
    , R1.alarm = concat(R1.alarm, "Fixed/")
where 
    R1.total_e = 0 and R2.total_e <> 0 and R3.today_e;
