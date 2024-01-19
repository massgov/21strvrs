
  CREATE VIEW "RVRS"."VU_AUDIT_DCURRENT_MULTIPLE" ("INTERNAL_CASE_NUMBER", "CURRENTCOUNT") AS 
  (
select INTERNAL_CASE_NUMBER, count(*) as CurrentCount
from RVRS.VIP_VRV_Death_Tbl
where fl_current=1
and fl_voided<> 1
and fl_abandoned ='N'
group by internal_case_number
having count(*) > 1
);


  