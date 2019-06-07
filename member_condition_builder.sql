
create view dbo.vOpsMemberConditions as

with cte_diagtypes as ( 
	--Asthma
		select distinct diag_code = Diag_Code, DiagType = 'Asthma'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes
		where Aetna_GrpDesc = 'Asthma'

		union

	--Cancer
		select distinct diag_code = Diag_Code, DiagType = 'Cancer'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes
		where Aetna_GrpDesc in ('Brain Cancer','Breast Cancer','Colorectal Cancer', 
			'Gastrointestinal Cancer - Other','Gynecologic Cancer','Head & Neck Cancer'
			,'Hematologic Cancer','Lung Cancer','Metastatic Cancer','Oral Cancer'
			,'Prostate Cancer')

		union

	--COPD
		select distinct diag_code = Diag_Code, DiagType = 'COPD'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc = 'Chronic Obstructive Pulmonary Disease'
 
		union

	--CKD
		select distinct diag_code = Diag_Code, DiagType = 'CKD'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc = 'Chronic Renal Failure' 

		union

		select distinct  diag_code = codeid, DiagType = 'CKD'
		from planreport_QNXT_LA.dbo.diagcode
		where codeid in ('O10.211','O10.212','O10.213','O10.219','O10.22','O10.23'
			,'O10.311','O10.312','O10.313','O10.319','O10.32','O10.33')

		union

	--Diabetes
		select distinct diag_code = Diag_Code, DiagType = 'Diabetes'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc = 'Diabetes Mellitus' 

		union

	--ESRD
		select distinct diag_code = Diag_Code, DiagType = 'ESRD'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc = 'Acute Renal Failure' 

		union

	--HIV
		select distinct diag_code = codeid, DiagType = 'HIV'
		from planreport_QNXT_LA.dbo.diagcode
		where (codeid like 'B20%' or codeid like 'B21%'
			or codeid like 'B22%' or codeid like 'B23%'
			or codeid like 'B24%' or codeid like 'R75%'
			or codeid like 'Z21%'
			or codeid in ('O98.711','O98.712','O98.713','O98.719','O98.72','O98.73'))

		union

		select distinct diag_code = Diag_Code, DiagType = 'HIV'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc = 'AIDS' 

		union

	--HCV
		select distinct diag_code = codeid, DiagType = 'HCV'
		from planreport_QNXT_LA.dbo.diagcode
		where codeid in ('B18.2','V02.62','070.41','070.44','070.51','070.70','070.71')

		union
	
	--SMI	
		select distinct diag_code = Diag_Code, DiagType = 'SMI'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc in ('BIPOLAR DISORDERS', 'Schizophrenia/Other Psychotic Disorders','Depression')	
			and Diag_Code not in ('F34.8','F34.89','F34.9','F39')-- not major depressive  

		union

	--HTN
		select distinct diag_code = codeid, DiagType = 'HTN'
		from planreport_QNXT_LA.dbo.diagcode
		where codeid in ('O10.011','O10.012','O10.013','O10.019','O10.02','O10.03',
			'O10.111','O10.112','O10.113','O10.119','O10.12','O10.13',
			'O10.411','O10.412','O10.413','O10.419','O10.42','O10.43',
			'O10.911','O10.912','O10.913','O10.919','O10.92','O10.93',
			'O11.1','O11.2','O11.3','O11.4','O11.5','O11.9',
			'O10.311','O10.312','O10.313','O10.319','O10.32','O10.33')

		union
		select distinct diag_code = Diag_Code, DiagType = 'HTN'
		from ASDB_LA.dbo.ASDB_Grouper_Dx_Codes 
		where Aetna_GrpDesc = 'Hypertension'
),

cte_diags as (
	select  
		m.Memid
		, dt.DiagType
		, mindate = min(c.startdate)
		, maxdate = max(c.startdate)
	from planreport_QNXT_LA.dbo.member m
		inner join PlanReport_QNXT_LA.dbo.enrollkeys e
			on m.memid = e.memid
		inner join PlanReport_QNXT_LA.dbo.Claim c
			on e.MemID = c.MemID
		inner join PlanReport_QNXT_LA.dbo.ClaimDiag cd
			on c.ClaimID = cd.ClaimID
		inner join cte_diagtypes dt
			on dt.diag_code = cd.codeid 
	where c.Status <> 'void'
	group by m.Memid
		, dt.DiagType
	
	union

	select  
		m.memid
		, dt.DiagType
		, mindate = min(clm.startdate)
		, maxdate = max(clm.startdate)
	from planreport_QNXT_LA.dbo.member m
		inner join ASDB_LA.dbo.ASDB_Clm_Data_Stage clm
			on m.memid= clm.memid
		inner join ASDB_LA.dbo.ASDB_ClaimDiag cd
			on clm.ClaimID = cd.ClaimID
		inner join cte_diagtypes dt
			on dt.diag_code = cd.codeid 
	where clm.Status_Header <> 'Void'
		or clm.Status_Detail <> 'Void'
	group by m.memid
		, dt.DiagType
)

select 
	Memid
	, Condition = diagtype
	, MinDate = min(mindate) --first known date of diag
	, MaxDate = max(maxdate) --last known date of diag
from cte_diags 
group by memid, diagtype





