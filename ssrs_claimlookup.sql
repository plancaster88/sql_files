
declare @servcode_switch bit =  
	(	select case when max(codeid) = '' then 0 else 1 end  
		from planreport_qnxt_la.[dbo].[svccode] 
		where codeid in (@servcode)
	)
declare @revcode_switch bit =  
	(	select case when max(codeid) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].[revcode] 
		where codeid in (@revcode)
	)
declare @ruleid_switch bit =  
	(	select case when max(ruleid) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].[qrule] 
		where ruleid in (@ruleid)
	)
declare @modcode_switch bit =  
	(	select case when max(modcode) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].modifier 
		where modcode in (@modcode)
	)
declare @grouptin_switch bit =  
	(	select case when max(fedid) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].provider  
		where fedid in (@grouptin)
	)
declare @groupnpi_switch bit =  
	(	select case when max(npi) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].provider  
		where npi in (@groupnpi)
	)
declare @provnpi_switch bit =  
	(	select case when max(npi) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].provider  
		where npi in (@provnpi)
	)

declare @include_ruleid bit = case when 'Rule IDs' in (@detailfields) then 1 else 0 end 
declare @include_revcode bit = case when 'Service Codes' in (@detailfields) then 1 else 0 end 
declare @include_modcode bit = case when 'Revenue Codes' in (@detailfields) then 1 else 0 end 
declare @include_servcode bit = case when 'Modifier Codes' in (@detailfields) then 1 else 0 end 
declare @include_dos bit = case when 'Dates of Service' in (@detailfields) then 1 else 0 end 
declare @include_claimline bit = case when 'Claim Line/Status' in (@detailfields) then 1 else 0 end 
declare @include_paidbilled bit = case when 'Amt Paid/Billed' in (@detailfields) then 1 else 0 end 


select  distinct
	  c.Claimid
	, FinalClaim = case when fc.claimid is not null then 'Yes' else 'No' end 
	, c.Status
	, AmtPaid_Header = c.Totalpaid
	, AmtBilled_Header = c.totalamt 
	, c.StartDate
	, c.EndDate
	, a.ProvName
	, a.ProvNPI
	, a.Provid
	, a.GroupName
	, a.Groupid
	, a.GroupNPI
	, a.GroupTIN
	, ClaimLine = case when @include_claimline = 0 then '' else  cd.claimline end
	, LineStatus = case when @include_claimline = 0 then '' else  cd.status end
	, AmtPaid_Line = case when @include_paidbilled = 0 then '' else cd.amountpaid end 
	, AmtBilled_Line = case when @include_paidbilled = 0 then '' else cd.claimamt end 
	, DosFrom = case when @include_dos = 0 then '' else cd.dosfrom end
	, DosTo = case when @include_dos = 0 then '' else cd.dosto end
	, Servcode = case when @include_servcode = 0 then '' else cd.ServCode end 
	, Revcode = case when @include_revcode = 0 then '' else cd.RevCode end 
	, RuleID = case when @include_ruleid = 0 then '' else ce.RuleID end 
	, ModCodes = case when @include_modcode = 0 then '' else 
		ltrim(rtrim(concat(cd.modcode , ' ', cd.modcode2 , ' ', cd.modcode3 , ' ', cd.modcode4 , ' ', cd.modcode5))) end
	---------------------------
	--, Memos = m.Description
	, include_servcode = @include_servcode 
	, include_modcode = @include_modcode
	, include_revcode = @include_revcode
	, include_ruleid = @include_ruleid  
	, include_dos = @include_dos
	, include_claimline = @include_claimline  
	, include_paidbilled = @include_paidbilled  
from planreport_QNXT_LA.dbo.claim c
	inner join planreport_QNXT_LA.dbo.claimdetail cd
		on cd.claimid = c.claimid
		and (	cd.servcode in (@servcode)
				or 0 = @servcode_switch
			)
		and (	cd.revcode in (@revcode)
				or 0 = @revcode_switch
			)
	left join la_temp.dbo.vOpsAffiliations a 
		on a.affiliationid = c.affiliationid
	left join la_ops_temp.dbo.vFinalClaims fc 
		on fc.claimid = c.claimid
	left join la_ops_temp.dbo.vClaimEdits ce
		on ce.claimid = c.claimid 
		and (	ce.claimline = cd.claimline
				or ce.Claimline = 0
			)
		and (	c.status in ('denied', 'pend')
				or cd.status in ('deny','pend')
			)
	left join planreport_qnxt_la.dbo.claimmemo cm
		on cm.claimid = c.claimid 
	left join planreport_QNXT_LA.dbo.memo m
		on m.memoid = cm.memoid
	cross apply --use this to allow users to input multiple modcodes in SSRS
		(	values
			  (cd.ModCode , 1)
			, (cd.ModCode2, 2)
			, (cd.ModCode3, 3)
			, (cd.ModCode4, 4)
			, (cd.ModCode5, 5)	
		) ca (ModCode, ModCodeNum)	
Where c.status in ('PAID','DENIED')
	and c.status in (@ClaimStatus)
	and c.startdate between isnull(@startdate, '2014-01-01') and isnull(@enddate, DATEADD(y,1,getdate()))
	and case when fc.claimid is not null then 'Yes' else 'No' end in (@FinalClaim)
	and (	ce.RuleID in (@ruleid)
			or 0 = @ruleid_switch
		)
	and (	ca.ModCode in (@modcode)
			or 0 = @modcode_switch
		)
	and (	a.GroupTIN in (@grouptin)
			or 0 = @grouptin_switch
		)
	and (	a.GroupNPI in (@groupnpi)
			or 0 = @groupnpi_switch
		)
	and (	a.ProvNPI in (@provnpi)
			or 0 = @provnpi_switch
		)
order by claimid,claimline
