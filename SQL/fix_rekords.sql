use solar;

update reports as R1 
join reports as R2 
on 
    R2.time = addtime(R1.time,"00:01:00")
set 
    R1.sn = R2.sn
    , R1.total_e = R2.total_e 
where R1.total_e = 0 and R2.total_e <> 0;
