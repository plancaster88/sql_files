

CREATE view [dbo].[vOpsObservationClaims] as 

select  c.*, d.*
from la_temp.dbo.vOpsClaims c
	left join asdb_la.[dbo].[ASDB_Grouper_Dx_Codes]  d
		on d.diag_code = c.diagcode 
		and d.aetna_catdesc in ('Obstetric Care','Newborn Care')  --Informatics excludes these... should we?
where revcode in ('0760','0761','0762','0769') --informatics logic
	and (BillType like '13%' or BillType like '85%') --informatics logic
	and servcode in ('99217','99218','99219','99220','g0378','g0379') --informatics logic
	and ClaimLineResult = 'Paid'
