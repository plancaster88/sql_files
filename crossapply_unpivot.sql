/*************** UnPivot w/ Cross Apply ********************/	
create table #UnPivot (
	  Member varchar(20)	
	, Diagnosis1 varchar(20) NULL
	, Diagnosis2 varchar(20) NULL
	, Diagnosis3 varchar(20) NULL
	, Diagnosis4 varchar(20) NULL
	, Diagnosis5 varchar(20) NULL
)

insert into #UnPivot values 
('g100000001','E87.2','A41.9','R65.20','R79.89','C34.90'),	
('g100000002','H66.93','H10.9','R50.9','H92.03',NULL),
('g100000003','F32.9','Z13.89',NULL,NULL,NULL)

Select 
	  Member
	, Diagnosis
	, DiagnosisSequence
from #UnPivot
cross apply
(
  values
          (Diagnosis1, 1)
	, (Diagnosis2, 2)
	, (Diagnosis3, 3)
	, (Diagnosis4, 4)
	, (Diagnosis5, 5)

) c (Diagnosis, DiagnosisSequence)
where c.Diagnosis is not null
