/*
declare @datetype	as varchar(max) = 'Line Date of Service'
declare @servcode	as varchar(max) = ''
declare @revcode	as varchar(max) = ''
declare @ruleid		as varchar(max) = ''
declare @modcode	as varchar(max) = ''
declare @grouptin	as varchar(max) = '720276883'
declare @groupnpi	as varchar(max) = ''
declare @provnpi	as varchar(max) = ''
declare @startdate as varchar(max) = NULL
declare @enddate as varchar(max) = NULL
declare @detailfields as varchar(max) = NULL
declare @ClaimStatus as varchar(max) = 'DENIED'
declare @FinalClaim as varchar(max) = 'Yes'
declare @ruleid_keyword as varchar(max) = ''
declare @remit_keyword as varchar(max) = ''
*/

declare @scriptstarttime datetime = getdate()

declare @servcode_switch varchar(max) =  
	(	select max(codeid)--case when max(codeid) = '' then 0 else 1 end  
		from planreport_qnxt_la.[dbo].[svccode] 
		where cast(codeid as varchar) in (@servcode)
	)

declare @revcode_switch varchar(max) =  
	(	select max(codeid)--case when max(codeid) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].[revcode] 
		where cast(codeid as varchar)  in (@revcode)
	)
declare @ruleid_switch varchar(max) =  
	(	select max(ruleid)--case when max(ruleid) = '' then 0 else 1 end 
		from (select ruleid = cast(ruleid as varchar) from planreport_qnxt_la.[dbo].[qrule] union all select '') sq
		where cast(ruleid as varchar) in (@ruleid)
	)
declare @modcode_switch varchar(max) =  
	(	select max(modcode)--case when max(modcode) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].modifier 
		where cast(modcode as varchar) in (@modcode)
	)
declare @grouptin_switch varchar(max) =  
	(	select max(fedid)--case when max(fedid) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].provider  
		where cast(fedid as varchar) in (@grouptin)
	)
declare @groupnpi_switch varchar(max) =  
	(	select max(npi) --case when max(npi) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].provider  
		where cast(npi as varchar) in (@groupnpi)
	)
declare @provnpi_switch varchar(max) =  
	(	select	max(npi)--case when max(npi) = '' then 0 else 1 end 
		from planreport_qnxt_la.[dbo].provider  
		where cast(npi as varchar) in (@provnpi)
	)

declare @switch_has_null bit = 0

if 	@modcode_switch is null or @ruleid_switch is null or @revcode_switch is null or @servcode_switch is null 
begin
	set @switch_has_null = 1 --need this for table at the end 
	--goto skip_query --skip to blank table for fast execution 
end 

declare @include_ruleid bit = case when 'Rule IDs' in (@detailfields) then 1 else 0 end 
declare @include_revcode bit = case when 'Revenue Codes' in (@detailfields) then 1 else 0 end 
declare @include_modcode bit = case when 'Modifier Codes' in (@detailfields) then 1 else 0 end 
declare @include_servcode bit = case when 'Service Codes' in (@detailfields) then 1 else 0 end 
declare @include_dos bit = case when 'Dates of Service' in (@detailfields) then 1 else 0 end 
declare @include_claimline bit = case when 'Claim Line/Status' in (@detailfields) then 1 else 0 end 
declare @include_paidbilled bit = case when 'Line Paid/Billed/Units' in (@detailfields) then 1 else 0 end 


--Get affiliations for user input... speeds query up significantly to do this a step before 
if object_id('tempdb.dbo.#Affiliations') is not null drop table #Affiliations;
select a.Affiliationid
into #Affiliations
from la_temp.dbo.vOpsAffiliations a
where	(	a.GroupTIN in (@grouptin)
			or 0 = @grouptin_switch
		)
	and (	a.GroupNPI in (@groupnpi)
			or 0 = @groupnpi_switch
		)
	and (	a.ProvNPI in (@provnpi)
			or 0 = @provnpi_switch
		)


if object_id('tempdb.dbo.#Claims') is not null drop table #Claims;
select   
	  c.Claimid
	, ClaimPrefix = CASE 	WHEN c.claimid not like '%[ar]%' then c.claimid --added for performance improvement since most claims don't have a/r
							else SUBSTRING(c.claimid, 1, PATINDEX('%[ar]%', c.claimid) - 1) end 
	, Claimid_line = concat(c.claimid, case when @include_claimline = 0 then '' else  cd.claimline end)
	, HeaderStatusCategory = cas.Status
	, HeaderStatusActual = c.status 
	, AmtPaid_Header = c.Totalpaid
	, AmtBilled_Header = c.totalamt 
	, AmtInterest_Header = cp.actualpaydiscountamount * -1
	, c.CreateDate 
	, c.StartDate
	, c.EndDate
	, c.PaidDate
	, c.AdjudDate
	, aa.ProvName
	, aa.ProvNPI
	, aa.Provid
	, aa.GroupName
	, aa.Groupid
	, aa.GroupNPI
	, aa.GroupTIN
	, ClaimLine = case when @include_claimline = 0 then '' else  cd.claimline end
	, LineStatus = case when @include_claimline = 0 then '' else  cd.status end
	, AmtPaid_Line = case when @include_paidbilled = 0 then '' else cd.amountpaid end 
	, AmtBilled_Line = case when @include_paidbilled = 0 then '' else cd.claimamt end 
	, AmtInterest_Line = case when @include_paidbilled = 0 then '' else cd.paydiscount end
	, BilledUnits = case when @include_paidbilled = 0 then '' else cd.billedunits end 
	, DosFrom = case when @include_dos = 0 then '' else cd.dosfrom end
	, DosTo = case when @include_dos = 0 then '' else cd.dosto end
	, Servcode = case when @include_servcode = 0 then '' else cd.ServCode end 
	, ServcodeDesc = case when @include_servcode = 0 then '' else svc.description end 
	, Revcode = case when @include_revcode = 0 then '' else cd.RevCode end 
	, RuleID = case when @include_ruleid = 0 then '' else ce.RuleID end 
	, RuleDesc = case when @include_ruleid = 0 then '' else q.description end 
	, RemitDesc = case when @include_ruleid = 0 then '' else isnull(ce.remitoverridemessage, '') end 
	, ModCodes = case when @include_modcode = 0 then '' else 
		ltrim(rtrim(concat(cd.modcode , ' ', cd.modcode2 , ' ', cd.modcode3 , ' ', cd.modcode4 , ' ', cd.modcode5))) end
	, include_servcode = @include_servcode 
	, include_modcode = @include_modcode
	, include_revcode = @include_revcode
	, include_ruleid = @include_ruleid  
	, include_dos = @include_dos
	, include_claimline = @include_claimline  
	, include_paidbilled = @include_paidbilled  
into #claims
from planreport_qnxt_la.dbo.claim c
	inner join #Affiliations a
		on a.Affiliationid = c.affiliationid
	cross apply 
		(	select case	when c.status in ('paid', 'denied', 'reversed', 'void','pend','pay','deny', 'open', 'rev') then c.status
						when c.status like '%REV%' then 'REV'
						when c.status = 'adjucated' then 'OPEN'
						else 'OTHER' end
		) cas (status)
	left join la_temp.dbo.vOpsAffiliations aa
		on aa.Affiliationid = a.Affiliationid 
	inner join planreport_QNXT_LA.dbo.claimdetail cd (NOLOCK)
		on cd.claimid = c.claimid
		and (	cd.servcode in (@servcode)
				or '' = @servcode_switch
			)
		and (	cd.revcode in (@revcode)
				or '' = @revcode_switch
			)
	left join PlanReport_QNXT_LA.dbo.claimedit ce  (NOLOCK)
		on ce.claimid = c.claimid 
		and (	ce.claimline = cd.claimline
				or ce.Claimline = ''
			)
		and (	c.status in ('denied', 'pend')
				or cd.status in ('deny','pend')
			)
	left join planreport_QNXT_LA.dbo.qrule q
		on q.ruleid = ce.ruleid 
	--left join planreport_qnxt_la.dbo.claimmemo cm  (NOLOCK)
	--	on cm.claimid = c.claimid 
	--left join planreport_QNXT_LA.dbo.memo m  (NOLOCK)
	--	on m.memoid = cm.memoid
	left join PlanReport_QNXT_LA.dbo.svccode svc (NOLOCK)
			on svc.codeid = cd.servcode  
	cross apply --use this to allow users to input multiple modcodes in SSRS
		(	values
			  (cd.ModCode , 1)
			, (cd.ModCode2, 2)
			, (cd.ModCode3, 3)
			, (cd.ModCode4, 4)
			, (cd.ModCode5, 5)	
		) ca (ModCode, ModCodeNum)	
	left join planreport_qnxt_la.dbo.claimpay cp
		on cp.claimid = c.claimid 
Where
	cas.Status in (@ClaimStatus)
	--date type switch
	and		case	when @datetype = 'Line Date of Service' then cd.dosfrom 
					when @datetype = 'Header Date of Service' then c.startdate
					when @datetype = 'Paid Date' then c.paiddate
					when @datetype = 'Clean Date' then c.cleandate
					when @datetype = 'Adjudicated Date' then c.adjuddate
			end	between isnull(@startdate, '2014-01-01') and isnull(@enddate, DATEADD(y,1,getdate()))
	--and c.FinalClaim in (@FinalClaim)
	and (	ce.RuleID in (@ruleid)
			or '' = @ruleid_switch
		)
	and (	ca.ModCode in (@modcode)
			or '' = @modcode_switch
		)
	and isnull(q.description, '') like case when @ruleid_keyword = '' then '%%' else '%' + @ruleid_keyword + '%' end 
	and isnull(ce.remitoverridemessage, '') like case when @remit_keyword = '' then '%%' else '%' + @remit_keyword + '%' end 
	

--make distinct (this extra step is for query optimization... if done in prior step it would slow down query more than necessary) 
if object_id('tempdb.dbo.#Claims2') is not null drop table #Claims2;
select distinct * 
into #claims2 
from #claims 

--Final Claim check
if object_id('tempdb.dbo.#FinalClaims') is not null drop table #FinalClaims;
select c2.ClaimPrefix, maxcd = max(c.createdate), FinalClaim = 'Yes' 
into #FinalClaims 
from #claims2 c2 
	inner join planreport_QNXT_LA.dbo.claim c
		on c2.HeaderStatusCategory in ('PAID','DENIED','REVERSED')
		and c2.ClaimPrefix = CASE WHEN c.claimid not like '%[ar]%' then c.claimid
				else SUBSTRING(c.claimid, 1, PATINDEX('%[ar]%', c.claimid) - 1) end
group by c2.ClaimPrefix

--Output 
select 
	c2.*
	, FinalClaim = ISNULL(fc.FinalClaim, 'No') 
	, TotalRuntime = 
		cast(floor(cast(GETDATE() - @scriptstarttime as decimal(10,8))  * 24 * 60) as varchar) + 'm ' + 
		CAST(
			floor(	
				((cast(GETDATE() - @scriptstarttime as decimal(10,8))  * 24 * 60) 
					-  floor(cast(GETDATE() - @scriptstarttime as decimal(10,8))  * 24 * 60)
					) * 60
				) as varchar
			) + 's'
from #claims2 c2
	left join #FinalClaims fc
		on fc.ClaimPrefix = c2.ClaimPrefix 
		and fc.maxcd = c2.createdate 
where ISNULL(fc.FinalClaim, 'No')  in (@FinalClaim)


--go here if there is a null value for any of the switch values tested in the if statement 
skip_query:
if @switch_has_null = 1 --only want this to run if we have a null in 1 of our switches
begin
	select  distinct
		  Claimid			= NULL
		, ClaimPrefix		= NULL 
		, Claimid_line		= NULL
		, HeaderStatusCategory = NULL
		, HeaderStatusActual = NULL
		, AmtPaid_Header	= NULL
		, AmtBilled_Header	= NULL
		, AmtInterest_Header= NULL
		, CreateDate		= NULL
		, StartDate			= NULL
		, EndDate			= NULL
		, PaidDate			= NULL
		, AdjudDate			= NULL
		, ProvName			= NULL
		, ProvNPI			= NULL
		, Provid			= NULL
		, GroupName			= NULL
		, Groupid			= NULL
		, GroupNPI			= NULL
		, GroupTIN			= NULL
		, ClaimLine			= NULL
		, LineStatus		= NULL
		, AmtPaid_Line		= NULL
		, AmtBilled_Line	= NULL
		, AmtInterest_Line	= NULL
		, Billed_Units		= NULL
		, DosFrom			= NULL
		, DosTo				= NULL
		, Servcode			= NULL
		, ServcodeDesc		= NULL
		, Revcode			= NULL
		, RuleID			= NULL
		, RuleDesc			= NULL
		, RemitDesc			= NULL
		, ModCodes			= NULL
		, include_servcode	= NULL 
		, include_modcode	= NULL
		, include_revcode	= NULL
		, include_ruleid	= NULL  
		, include_dos		= NULL
		, include_claimline = NULL  
		, include_paidbilled= NULL  
		, FinalClaim		= NULL
		, TotalRuntime = 
			cast(floor(cast(GETDATE() - @scriptstarttime as decimal(10,8))  * 24 * 60) as varchar) + 'm ' + 
			CAST(
				floor(	
					((cast(GETDATE() - @scriptstarttime as decimal(10,8))  * 24 * 60) 
						-  floor(cast(GETDATE() - @scriptstarttime as decimal(10,8))  * 24 * 60)
						) * 60
					) as varchar
				) + 's'
	where @switch_has_null <> 1
end 
