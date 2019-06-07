
use la_temp
go

if object_id('tempdb..#Calendar','u') is not null begin drop table #Calendar end;
CREATE TABLE #Calendar
(
    [Date] DATETIME
)

DECLARE @StartDate DATETIME = '1990-01-01'
DECLARE @EndDate DATETIME = '2025-12-31'


WHILE @StartDate <= @EndDate
      BEGIN
             INSERT INTO #Calendar
             (
                   Date
             )
             SELECT
                   @StartDate

             SET @StartDate = DATEADD(dd, 1, @StartDate)
      END

if object_id('tempdb..#Calendar2','u') is not null begin drop table #Calendar2 end;
create table #Calendar2 
(
	Date datetime
	, Year int
	, Month int
	, MonthName varchar(25)
	, MonthNameShort varchar(3)
	, Quarter int
	, QuarterName varchar(25)
	, Day int
	, DayName varchar(25)
	, DayOfWeek int
	, DayOfMonth int
	, Week int
	, StartOfMonth datetime
	, EndOfMonth datetime
	--, IsCurrentYear bit 
	--, IsCurrentMonth bit 
	--, IsCurrentDate bit 
	, IsLeapYear bit 
	, YYYYMM varchar(6)
)


insert into #Calendar2
select 
	Date
	, Year = Year(date) 
	, Month = Month(date)
	, MonthName = datename(mm, date)
	, MonthNameShort = left(datename(mm, date),3)
	, Quarter = datename(qq, date) 
	, QuarterName = case	when datename(qq, date) = 1 then 'First' when datename(qq, date) = 2 then 'Second' 
							when datename(qq, date) = 3 then 'Third' when datename(qq, date) = 4 then 'Fourth' end
	, Day = datepart(dy, date) 
	, DayName = datename(w, date)
	, DayOfWeek = datepart(dw, date)	
	, DayOfMonth = Day(date)
	, Week = datepart(wk, date)
	, StartOfMonth = DATEADD(mm, DATEDIFF(mm,0,date), 0)
	, EndOfMonth = cast(eomonth(date) as datetime)
	--, IsCurrentYear = case when year(date) = year(getdate()) then 1 else 0 end 
	--, IsCurrentMonth = case when year(date) = year(getdate()) and month(date) = month(getdate()) then 1 else 0 end 
	--, IsCurrentDate = case when date = getdate() then 1 else 0 end 
	, IsLeapYear = CASE WHEN (year(date) % 4 = 0 AND year(date) % 100 <> 0) OR year(date) % 400 = 0 THEN 1 else 0 end 
	, YYYYMM = format(date, 'yyyyMM') --convert(varchar(6), date, 112)
from #calendar
