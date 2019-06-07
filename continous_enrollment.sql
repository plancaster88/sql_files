
If Object_ID('TempDB.dbo.#Months') is not null begin drop table #Months end;	
select distinct StartOfMonth
into #months
from la_temp.dbo.vopsdates 
where StartOfMonth between '2014-01-01' and getdate()


If Object_ID('TempDB.dbo.#Eligibility') is not null begin drop table #Eligibility end;
SELECT distinct 
	StartOfMonth = cast(m.StartOfMonth as date)
	, ek.Memid
into #Eligibility
FROM planreport_QNXT_LA.dbo.enrollkeys ek
	inner join #Months m 
		on m.StartOfMonth between ek.effdate and eomonth(ek.termdate)
where ek.enrollid <> '' 
	and ek.segtype = 'int'


If Object_ID('TempDB.dbo.#LastMonth') is not null begin drop table #LastMonth end;
select e.memid, e.StartOfMonth, lm = lm.StartOfMonth
into #LastMonth
from #Eligibility e
	left join #Eligibility lm
		on dateadd(m, -1, e.StartOfMonth) = lm.StartOfMonth
		and e.memid = lm.memid

select 
	t.memid
	, EnrollMonth = t.startofmonth
	, EnrollStartMonth = ce.startofmonth
	, MonthsCE = DATEDIFF(m, ce.startofmonth, t.startofmonth) + 1
from #LastMonth t
	outer apply
		(	select top 1 * 
			from #LastMonth oa
			where t.memid = oa.memid
				and oa.startofmonth <= t.startofmonth
				and oa.lm is null
			order by oa.startofmonth desc 
		) ce
