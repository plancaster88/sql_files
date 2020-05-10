use pe_temp 
go

create procedure [pe].[USP2001835_CodeSnapshot] as

/***************************************************************************
AUTHOR: Philip Lancaster

CREATED DATE: 2020-05-09

DESCRIPTION: Created this SP in order to have a run that picks up and stores code from all views, SPs, and functions on pe_temp.
			 This stores code for last 7 days, 1st of month for last year, and Monday of each week in last 30 days.

CHANGELOG:
       ADDED - for new features
       UPDATED - for changes in existing functionality
       REMOVED - for now removed features
       FIXED - for any bug fixes
       DEPRECATED - for soon-to-be removed features

-2020-05-09 | ADDED | Philbo Lancaster | Added backup table on NDQT_Temp that also gets populated (NDQT_Temp.dbo.CodeSnapshot)
******************************************************************************/ 


IF OBJECT_ID('tempdb..#temp') IS NOT NULL DROP TABLE #temp
create table #temp 
(Text varchar(max))


IF OBJECT_ID('tempdb..#Code') IS NOT NULL DROP TABLE #Code
create table #Code 
(	SchemaObject varchar(250)
	, ObjectType varchar(35)
	, CodeLine int 
	, Code varchar(max)
	, LoadDate Date
)


IF OBJECT_ID('tempdb..#Objects') IS NOT NULL DROP TABLE #Objects
SELECT 
	  ObjectType = 
		case	when o.type_desc like '%Stored%' then 'STORED PROCEDURE' 
				when o.type_desc like '%scalar%' then 'SCALAR FUNCTION' 
				when o.type_desc like '%Table%'  then 'TABLE FUNCTION'
				else o.type_desc end 
	, SchemaObject =s.name + '.' + o.name, ObjectNum =  ROW_NUMBER() OVER(ORDER BY (Select 0))
into #Objects
FROM sys.sql_modules m
	left join sys.objects as o
		on m.object_id = o.object_id 
	left join sys.schemas s
		on s.schema_id = o.schema_id 
where o.name is not null --excludes triggers 
	and s.name <> 'QNXT' --exclude specific schemas 


declare @counter int = 1
declare @maxobjects int = (select count(*) from #objects)


WHILE @counter <= @maxobjects  
BEGIN 
	--set object name 
	declare @object varchar(250) = (select  SchemaObject from #objects where ObjectNum = @counter)
 	declare @objecttype varchar(25) = (select  ObjectType from #objects where ObjectNum = @counter) 
	
	insert into #temp 
	exec sp_helptext @object

	insert into #code
	select @object, @objecttype, RowNum = ROW_NUMBER() OVER(ORDER BY (Select 0)), Text, cast(getdate() as date)
	from #temp

	truncate table #temp

	set @counter += 1 
END  


delete from pe_temp.pe.CodeSnapshot
where LoadDate not in 
	(	select d.date
		from pe_temp.pe.vDates d
		where d.date between dateadd(d,-6, cast(getdate() as date)) and dateadd(d,-1, cast(getdate() as date)) --within last 7 days counting today
			or (d.DayOfMonth = 1 and d.date between dateadd(yy,-1, cast(getdate() as date)) and dateadd(d,-1, cast(getdate() as date))) --1st of month w/in last year
			or (d.DayOfWeek = 2 and d.date between dateadd(d,-30, cast(getdate() as date)) and dateadd(d,-1, cast(getdate() as date))) --Monday of week w/in last 30 days 
	)

delete from ndqt_temp.dbo.CodeSnapshot
where LoadDate not in 
	(	select d.date
		from pe_temp.pe.vDates d
		where d.date between dateadd(d,-6, cast(getdate() as date)) and dateadd(d,-1, cast(getdate() as date)) --within last 7 days
			or (d.DayOfMonth = 1 and d.date between dateadd(yy,-1, cast(getdate() as date)) and dateadd(d,-1, cast(getdate() as date))) --1st of month w/in last year
			or (d.DayOfWeek = 2 and d.date between dateadd(d,-30, cast(getdate() as date)) and dateadd(d,-1, cast(getdate() as date))) --Monday of week w/in last 30 days 
	)


insert into pe_temp.pe.CodeSnapshot 
select * from #code

insert into ndqt_temp.dbo.CodeSnapshot
select * from #code
