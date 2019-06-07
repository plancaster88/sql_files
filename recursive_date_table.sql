--This code makes a date table from a recursive cte

declare @sd datetime = '2010-01-01' --Start date here
declare @ed datetime = '2025-12-31' --End date here 

;with cte_dates ([Date]) as (
    select [Date] = convert(datetime, @sd) 

    union all 

    select dateadd(day, 1, [Date])
    from cte_dates
    where [Date] < @ed
)

select 
	[Date]
	, [Year] = Year([date]) 
	, [Month] = Month([date])
	, [MonthName] = datename(mm, [date])
	, MonthNameShort = left(datename(mm, [date]),3)
	, [Quarter] = datename(qq, [date]) 
	, QuarterName = case	when datename(qq, [date]) = 1 then 'First' when datename(qq, [date]) = 2 then 'Second' 
							when datename(qq, [date]) = 3 then 'Third' when datename(qq, [date]) = 4 then 'Fourth' end
	, [Day] = datepart(dy, [date]) 
	, [DayOfWeek] = datepart(dw, [date])	
	, [DayOfMonth] = Day([date])
	, [DayName] = datename(w, [date])
	, DayNameShort = LEFT(datename(w, [date]),2)
	, [Week] = datepart(wk, [date])
	, YYYYMM = format([date], 'yyyyMM') --convert(varchar(6), date, 112)
	, MMMYY = format([date], 'MMM-yy') 
	, YYYYQ = concat(format([date], 'yyyy'), datename(q, [date]))
	, QQYY = concat('Q',datename(q, [date]),'-', format([date], 'yy'))
	, StartOfWeek =  dateadd(d, -( datepart(dw, [date]) - 1), [date])
	, EndOfWeek = dateadd(d, 7 -  datepart(dw, [date]), [date])
	, StartOfMonth = DATEADD(mm, DATEDIFF(mm,0,[date]), 0)
	, EndOfMonth = cast(eomonth([date]) as datetime)
	, IsCurrentYear = case when year([date]) = year(getdate()) then 1 else 0 end 
	, IsLastYear = case when year([date]) = year(getdate()) - 1 then 1 else 0 end 
	, IsCurrentMonth = case when year([date]) = year(getdate()) and month(date) = month(getdate()) then 1 else 0 end 
	, IsFutureMonth = case when CONVERT(varchar(6), GETDATE(), 112) < format([date], 'yyyyMM') then 1 else 0 end 
	, IsLastMonth = case when cast(eomonth([date]) as datetime) = eomonth(dateadd(m,-1, getdate())) then 1 else 0 end 
	, IsCurrentDate = case when [date] = getdate() then 1 else 0 end 
	, IsLagPeriod = case when DATEADD(mm, DATEDIFF(mm,0,[date]), 0) < dateadd(m, -3, getdate()) then 1 else 0 end 
	, LagPeriodYoY = 
		case	when month(getdate()) between 1 and 3 
					and Month([date]) <= month(dateadd(m, -3, getdate()))
					and Year([date])  <> year(getdate())	then 1 
				when month(getdate()) between 4 and 12 
					and Month([date]) <= month(getdate()) - 3 then 1
				else 0 end   			 
	, IsLeapYear = CASE WHEN (year([date]) % 4 = 0 AND year([date]) % 100 <> 0) OR year([date]) % 400 = 0 THEN 1 else 0 end 
from cte_dates

option (maxrecursion 32767) 


