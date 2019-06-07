USE [LA_Ops_Temp]
GO

/****** Object:  View [dbo].[vFinalClaims]    Script Date: 06/07/2019 11:26:39 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE view [dbo].[vFinalClaims] as

SELECT
	  ClaimPrefix = 
			CASE 	WHEN c.claimid not like '%a%' and c.claimid not like '%r%' then c.claimid --added for performance improvement since most claims don't have a/r
					WHEN PATINDEX('%A%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%A%', c.claimid) - 1)
					WHEN PATINDEX('%R%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%R%', c.claimid) - 1)
					ELSE c.claimid END	
	, c.Claimid
	, FinalClaim = 1 --case when maxcd.ClaimPrefix is not null then 1 end 

FROM planreport_qnxt_la.dbo.claim c (NOLOCK)
	inner join 
		(	SELECT  
				  ClaimPrefix = 
						CASE 	WHEN c.claimid not like '%a%' and c.claimid not like '%r%' then c.claimid 
								WHEN PATINDEX('%A%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%A%', c.claimid) - 1)
								WHEN PATINDEX('%R%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%R%', c.claimid) - 1)
								ELSE c.claimid END	
				, MaxCreateDate = max(c.createdate)
			FROM planreport_qnxt_la.dbo.claim c (NOLOCK)
			where c.status <> 'void' --exclude voids
			group by 
				CASE 	WHEN c.claimid not like '%a%' and c.claimid not like '%r%' then c.claimid 
						WHEN PATINDEX('%A%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%A%', c.claimid) - 1)
						WHEN PATINDEX('%R%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%R%', c.claimid) - 1)
						ELSE c.claimid END	
		) maxcd --max create date
		on	c.createdate = maxcd.MaxCreateDate
		and maxcd.ClaimPrefix = 	
			CASE 	WHEN c.claimid not like '%a%' and c.claimid not like '%r%' then c.claimid
					WHEN PATINDEX('%A%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%A%', c.claimid) - 1)
					WHEN PATINDEX('%R%', c.claimid) <> 0 THEN SUBSTRING(c.claimid, 1, PATINDEX('%R%', c.claimid) - 1)
					ELSE c.claimid END	
where c.status in ('Paid', 'Denied','Reversed') --Final statuses only 
GO


