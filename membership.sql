USE [LA_Temp]
GO

/****** Object:  View [dbo].[vOpsMembership]    Script Date: 06/07/2019 11:32:10 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO






/*
Created by: Philip Lancaster
Date Created: 9/26/2018

Notes:	Only has monthly membership for enrollkeys where segtype = 'int'. 
		Member attributes are as of the start of the eligibility period which is EligStart (not start of month). 
		A member can have multiple eligibilty periods in the month if their enrollid changes mid-month.
	
Keys: Enrollid, EligStart, EligEnd

Update Log: 
	10/26/2018 - PL: 

*/


CREATE view [dbo].[vOpsMembership] as

--Step 1: Get enrollment by month
with cte_eligibility as (
	SELECT distinct 
		dt.StartOfMonth
		, dt.EndOfMonth
		, ek.Memid
		, ek.carriermemid
		, EligStart = case when dt.StartOfMonth >= ek.effdate then dt.StartOfMonth	else ek.effdate end 
		, EligEnd = case when dt.EndOfMonth <= ek.termdate then dt.EndOfMonth else ek.termdate end
		, ek.Enrollid 
	--	, ec2.RateCode 
	FROM planreport_QNXT_LA.dbo.enrollkeys ek (nolock)
		inner join planreport_QNXT_LA.dbo.enrollcoverage ec
			on ek.enrollid = ec.enrollid 
		inner join (	select distinct yyyymm, startofmonth, endofmonth 
						from la_temp.dbo.vopsdates (nolock)
						where StartOfMonth between '2014-01-01' and getdate()
					) dt
			on dt.YYYYMM between convert(char(6), ek.effdate, 112) and CONVERT(char(6), ek.termdate, 112)
	where ek.enrollid <> '' 
		and ek.segtype = 'int'
)


--Step 2: Start appending important information and attributes
select 
	  el.StartOfMonth
	, el.Memid
	, ek.CarrierMemid 
	, el.EligStart
	, el.EligEnd
	, el.Enrollid 
	, EnrollidEffdate = ek.effdate
	, EnrollidTermdate = ek.termdate
	, RateCode = case when ec.RateCode is null or ec.ratecode = '' then '00000' else ec.ratecode End--enrollid ek vs ec discrepancies in ratecodes appear as ec in QNXT front end 
	, Zip = isnull(r.Zip, '00000')
	, Region = isnull(r.RegionShort, 'Out of State/Unknown')
	, GeoRegion = isnull(r.GeoRegion, 'Out of State/Unknown')
	, Age = --la_ops_temp.dbo.fnAgeYears(m.dob, el.EligStart)
	--This is confusing but it works...
		case	
			when m.dob > el.EligStart then 0  --sometimes an enroll period start date falls before a dob
			else 
				DATEDIFF(YY, m.dob, el.EligStart) 
				-	
				CASE --This sub case statement enforces proper rounding
					WHEN RIGHT(CONVERT(CHAR(6), el.EligStart , 12), 4) 
						>= RIGHT(CONVERT(CHAR(6), m.dob, 12), 4) 
					THEN 0 ELSE 1 
				END 
		end 
	, MM = (datediff(d, el.EligStart, el.EligEnd) + 1.0) / (datediff(d, el.StartOfMonth, el.EndOfMonth) + 1.0)
	, PCP_Key = isnull(p.PCP_key, 'NOPCP' + isnull(r.Zip, '00000'))
from cte_eligibility el
	inner join planreport_QNXT_LA.dbo.member m (nolock) 
		on m.memid = el.memid
	left join planreport_QNXT_LA.dbo.entity en (nolock)
		on en.entid = m.entityid
	left join planreport_QNXT_LA.dbo.enrollkeys ek (nolock)
		on ek.enrollid = el.enrollid
	outer apply --inner join causes a few duplications
		(	select top 1 ratecode
			from planreport_QNXT_LA.dbo.enrollcoverage ec (nolock)
			where ec.enrollid = ek.enrollid
			order by ec.lastupdate desc
		) ec
	outer apply --unlikely that this duplicated but being sure
		(	select top 1 PCP_key = rtrim(mp.affiliationid) + rtrim(mp.paytoaffilid) +  left(mp.svczip, 5)
			from planreport_QNXT_LA.dbo.memberpcp mp (nolock)
			where mp.enrollid = ek.enrollid
				and mp.pcptype = 'pcp'
				and mp.affiliationid not in ('QMAA00000032091','QMAA00000240925') --No provider
				and el.EligStart between mp.effdate and mp.termdate
			order by mp.termdate desc, mp.lastupdate desc
		) p
	left join la_ops_temp.dbo.ZipRegions r (nolock)
		on r.zip = isnull(left(en.PhyZip, 5), '00000')


GO


