
create view dbo.vERVisitsASDB as


/*****
Important website resources

	https://med.noridianmedicare.com/web/jea/topics/claim-submission/revenue-codes --rev codes
	https://www.cms.gov/Medicare/Coding/place-of-service-codes/Place_of_Service_Code_Set.html --location codes
	https://www.resdac.org/cms-data/variables/patient-discharge-status-code --patientstatus (discharge status codes)
	https://www.ncbi.nlm.nih.gov/pmc/articles/PMC5905698/ --Has different methods for identifying EM claims

	01 - Routine Discharge to Home
*****/

/*

ED classification using the NYU Billing algorithm: http://wagner.nyu.edu/faculty/billings/nyued-background.


Things to include?
	--via Ambulance
	--Discharge Home/IP/other	


Include Costs?
	--1 way to identify all costs is to join from the ER view to claims and match any claim on the same DOS where the group fedid is the same.
		--Get all claims from FormType 1500 where Location = 23 or COEDesc = 'Emergency Department Services'
		--Get all claims from FormType UB04 where COEDesc = 'Emergency Room'
		--Attempt to assign Ambulace/Transportation claims (multiple ER visits same day will have to be handled)

*/




with cte_ER1 as (
	select 
		  Memid
		, CarrierMemid
		, Enrollid
		, ASDB_Svc_Prov_Key
		, DosFrom
		, Claimid
		, ClaimLine
		, ServCode
		, ERServCode = case when ServCode in ('99281', '99282', '99283', '99284', '99285', '99291') then ServCode else '0-' + ServCode end --this code will help sort in later steps
		, Provid
		, ProvName
		, ProvNPI
		, Groupid
		, DiagCode
		, DiagDesc
		, DiagSubCat
		, BH_Indicator
		, ParStatus
		, Contractid
		, ContractDesc
		, PatientStatus 
		, ModCode
		, ModCode2 
		, RateCode
		, RateCatGroup
		, Segtype
		, MemZip
		, MemRegion
		, MemAge
		, PCP_key
	from la_temp.dbo.vOpsClaims 
	where ASDB_COE_Id = 20100 --COEDESC is Emergency Room	
		and FormType = 'ub04'--If there weren't any claims at the facility then its hard to say if it was an ER visit
		and RevCode not in ('0516','0526', '0456') --(Urgent Care)
		and (billtype between '130' and '14z' or billtype between '450' and '459') 
		and ClaimLineResult = 'paid'
		and	(	(revcode between '0450' and '0459' or revcode = '0981')
				or ServCode in ('99281', '99282', '99283', '99284', '99285', '99291')
				--or Location	= '23' --Not used by informatics or the most used methodologies such as CMS Research Data Assistance Center (ResDAC) 
			)
),


--Get distinct visits and the highest level ER ServCode (disitinct visit = unique Memid + DosFrom + Povid)
--very small chance to have multiple visits in a day - we can work on updating the logic later to seperate these into individual visits
cte_er2 as (
	select  
		e.memid
		, e.dosfrom
		, e.Provid 
		, MaxERServCode = max(ERServCode) 
	from cte_er1 e
	group by 
		e.memid
		, e.dosfrom
		, e.Provid 
),

--small chance that there are multiple claims per combination of unique Memid + DosFrom + Povid + MaxERServCode
--This arbitrarily choses the max claimid + claimline
cte_er3 as (
	select  
		e2.memid
		, e2.dosfrom
		, e2.Provid 
		, e2.MaxERServCode
		, MinClaimidLine= min(claimid + '-' + cast(ClaimLine as varchar)) --Informatics uses this logic 
	from cte_er2 e2
		left join cte_er1 e
			on e2.memid = e.memid 
			and e2.DosFrom = e.DosFrom
			and e2.Provid = e.Provid 
			and e2.MaxERServCode = e.ERServCode
	group by 
		e2.memid
		, e2.dosfrom
		, e2.Provid 
		, e2.MaxERServCode
)

--295465

select  
	e3.Memid
	, e.CarrierMemid
	, e.Enrollid
	, e3.DosFrom
	, e.Claimid
	, e.ClaimLine
	, ERServCode = case when e.ERServCode like '9%' then e.ERServCode else '' end 
	, VisitSeverity = --ordered in case statement by frequency for query optimization
		case	when e.ERServCode = '99283' then 'Med'	-- ~41%
				when e.ERServCode = '99284' then 'Med/High' -- ~29%
				when e.ERServCode = '99282' then 'Low/Med' -- ~13%
				when e.ERServCode in ('99285', '99291') then 'High' -- ~13
				when e.ERServCode = '99281' then 'Low' -- ~4%
				else 'Unknown' end 
	, e.ASDB_Svc_Prov_Key
	, e3.Provid
	, e.ProvName
	, e.ProvNPI
	, e.Groupid
	, e.DiagCode
	, e.DiagDesc
	, e.DiagSubCat
	, e.BH_Indicator
	, e.ParStatus
	, e.Contractid
	, e.ContractDesc
	, e.PatientStatus 
	, IsRoutineDC = case when e.PatientStatus = '01' then 'Yes' else 'No' end 
	, SameDayAmbulance = case when amb.Memid is not null then 'Yes' else 'No' end 
	, WithinOneDayAmbulance = case when coalesce(amb.memid, amb2.Memid) is not null then 'Yes' else 'No' end 
	, e.ModCode
	, e.ModCode2 
	, e.RateCode
	, e.RateCatGroup
	, e.SegType
	, e.MemZip
	, e.MemRegion
	, e.MemAge
	, e.PCP_key
from cte_er3 e3 
	left join cte_ER1 e --match distinct list w/ first claim id & claim line back to the first table for detail information such as diag
		on e3.MinClaimidLine = e.Claimid + '-' + cast(e.ClaimLine as varchar) 
	left join  --this yields ~10% ambulance same day (CDC says ~15%)
		(	select distinct memid, DosFrom 
			from la_temp.dbo.vOpsClaims
			where ClaimLineResult = 'paid'
				and (	ASDB_COE_Id in ('92200', '21800') 
						or location in ('41','42')
					) --Ambulance/Transportation
		) amb
		on amb.memid = e3.memid
		and amb.DosFrom = e3.DosFrom
	left join  --this yields ~11% ambulance same day (CDC says ~15%)
		(	select distinct memid, DosFrom 
			from la_temp.dbo.vOpsClaims
			where ClaimLineResult = 'paid'
				and (	ASDB_COE_Id in ('92200', '21800') 
						or location in ('41','42')
					) --Ambulance/Transportation
		) amb2
		on amb2.memid = e3.memid
		and e3.DosFrom = dateadd(d,-1,amb2.DosFrom)
