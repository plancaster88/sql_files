USE [LA_Ops_Temp]
GO

/****** Object:  View [hedis].[vEDUtilization]    Script Date: 06/07/2019 11:28:44 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*


Author:			Philip Lancaster
Create Date:	03/14/2019
Health Plan:	Aetna Better Health of Louisiana

Description:	


Change Log:
11/11/2011	PL	Description



HEDIS Details:
Step 1 Count each visit to an ED once, regardless of the intensity or duration of the visit. Count multiple
ED visits on the same date of service as one visit. Identify all ED visits during the measurement
year using either of the following:
	• An ED Visit (ED Value Set).
	• A procedure code (ED Procedure Code Value Set) with an ED place of service code (ED
POS Value Set).
Do not include ED visits that result in an inpatient stay (Inpatient Stay Value Set). When an ED
visit and an inpatient stay are billed on separate claims, the visit results in an inpatient stay when
the admission date for the inpatient stay occurs on the ED date of service or one calendar day
after. An ED visit billed on the same claim as an inpatient stay is considered a visit that resulted in
an inpatient stay.
Step 2 Exclude encounters with any of the following:
	• A principal diagnosis of mental health or chemical dependency (Mental and Behavioral Disorders Value Set).
	• Psychiatry (Psychiatry Value Set).
	• Electroconvulsive therapy (Electroconvulsive Therapy Value Set)
*/


CREATE view [hedis].[vEDUtilization] as 

with cte_Hedis as (
	select ValueSetName, Code, CodeSystem 
	from la_temp.dbo.HEDIS_Value_Sets_2019 where valuesetname in ('ED','ED Procedure Code','Mental and Behavioral Disorders','Psychiatry','Electroconvulsive Therapy')   
)


select  
		c.*
from la_ops_temp.dbo.vClaimsAll c
where c.DosFrom > '1/1/2017'
	--HEDIS ED  Utilization - Calculation of Observed Events 
	--Step 1
		and	(	c.servcode in (select code from cte_Hedis where valuesetname = 'ED' and CodeSystem = 'cpt')	
				or c.revcode in (select code from cte_Hedis where valuesetname = 'ED' and CodeSystem = 'UBREV')		
				or 	(	c.location = '23'
						and servcode in (select code from cte_Hedis where valuesetname = 'ED Procedure Code' and CodeSystem = 'cpt')				
					)
		)
	--Step 2
	and c.ServCode not in 
		(select code from cte_Hedis where valuesetname in ('Psychiatry','Electroconvulsive Therapy') and CodeSystem = 'cpt')
	and c.diagcode not in 
		(select code from cte_Hedis where valuesetname in ('Mental and Behavioral Disorders','Psychiatry','Electroconvulsive Therapy') and CodeSystem like 'icd%')
	and c.revcode not in 
		(select code from cte_Hedis where valuesetname in ('Psychiatry','Electroconvulsive Therapy') and CodeSystem like 'ubrev')

GO


