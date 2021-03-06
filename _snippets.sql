/***********Find word in any column or table***********/
SELECT  
  'Planreport_qnxt_la.'+s.[name]+'.'+ t.[name]+'.'+c.[name] ,
        s.[name]            'Schema',
        t.[name]            'Table',
        c.[name]            'Column',
        d.[name]            'Data Type',
        d.[max_length]      'Max Length',
        d.[precision]       'Precision',
        c.[is_identity]     'Is Id',
        c.[is_nullable]     'Is Nullable',
        c.[is_computed]     'Is Computed',
        d.[is_user_defined] 'Is UserDefined',
        t.[modify_date]     'Date Modified',
        t.[create_date]     'Date created'
FROM        sys.schemas s
INNER JOIN  sys.tables  t
ON s.schema_id = t.schema_id
INNER JOIN  sys.columns c
ON t.object_id = c.object_id
INNER JOIN  sys.types   d
ON c.user_type_id = d.user_type_id
WHERE 
c.name like '%Fee%'     --Type the column you are searching for here. I use a wild card if I do not know the exact column name.
 and t.[name]   like '%fee%'  

/****************  Format Date as YYYYMM *******************/
	select convert(char(6), getdate(), 112) ;
  
  /****************  Dropping Temp Tables	*******************/
-- Before creating a temp table, add code to test if it exists, and remove it if possible. You do not need to include code to drop every temp table at the end of your procedures. They are automatically removed when your session ends, or your procedure finishes executing. Use this code to test if it exists, before creating them, rather than dropping them outright at the end.
	if object_id('tempdb..#mytemp','u') is not null begin drop table #mytemp end;
  
  /****************  Create Indexes!	*******************/
-- You should create non-clustered indexes to increase the query efficiency for your temp tables that have a great number of rows.
-- You should index those columns that appear in your WHERE clause. 
-- You should “include” columns that appear in your SELECT clause.
	create nonclustered index ix_mytable_mycolumn 
		on #MyTempTable (ColumnName asc, AnotherOptionalIndexedColumn desc) -- Add columns you want indexed.
		include (OptionallyIncludeThisColumn, ThisColum)  -- The include statement is optional.
	;
-- The include statement is optional. However, if all of the items in your select statement also appear in the include clause, then SQL Server will avoid the temp table and read entirely from the index, which is much more efficient.
-- Don’t bother creating clustered indexes, unless you’re an advanced user. Do not create any indexes on any of our standard, regularly used objects in the DS and DSR databases - the Data Architect will organize those efforts.

  /****************  Remove Non Alpha-Numeric Characters	*******************/
	select MyField = replace(c.Field, substring(c.Field, patindex('%[^a-zA-Z0-9 ]%', c.Field), 1), '') 
  
  /****************  Remove Whitepsace	*******************/
	select MyField = replace(replace(rtrim(ltrim(c.Field)),char(10),''),char(13),'')

/******  Remove Extra Spaces Inside a String *******************/
	-- Changes many spaces into a single space.
	-- Will change 'a  b     c' into 'a b c' 
	select replace( REPLACE( REPLACE ( Field Name, ' ', '<>'), '><', ''), '<>', ' ' )

/****************  Display Money 	*******************/
-- (with commas, decimal and dollar sign)
	select top 10 MyDollars = '$' + convert(varchar(25), cast(amt_billed_d as money), 1) 
	from usr.member_facts 
	where yyyymm = '201408';

/**************** Error Handling *******************/
-- Error handling is useful when you move a process to reporting, because
-- the errors can be caught and logged to our process log.

	use decisionsupport
	go

	create procedure [phn\tparker].usp_MySampleProcedure
	-- Normally the Script Header would go here.
	as
		begin try

			-- Force a div0 error.
			select this = 1 / 0;

		end try
		begin catch

			-- this will catch the error, and log it to our process log.
			exec decisionsupportreports.usr.usp_ErrorProc;

		end catch;

	-- Now you can exec the procedure, which will cause an error.
	exec [phn\tparker].usp_MySampleProcedure;

	-- Now you can view the logs table, and see your error was logged.
	select log_date, log_process, log_message, log_status, log_step  --top 100 * 
	from logs.usr.log_data 
	where log_process = 'usp_MySampleProcedure' 
	order by log_date desc;

  
 /*************** Combine Multiple Rows into Delimited String ROW (AKA Concatenation / GROUP_CONCAT)  ********************/
	-- From a table of multiple rows of strings, combine those 
	-- into one row of delimited values.
  SELECT DISTINCT
    a.market
    ,a.servname
    ,office_name=
	STUFF((SELECT DISTINCT  ', '+rTRIM(office_name) 
	FROM tbl WHERE servname=A.servname AND market= a.market	
	FOR XML PATH('')) , 1 , 1 , '' )			 					 
  FROM tbl a
  
--A better method				 
					 
select 
	  Memos = STUFF((
		SELECT ',' +  cast(m.message as varchar(max))
		FROM claimmemo cm
			left join memo m
				on m.memoid = cm.memoid
		WHERE cm.claimid = c.claimid
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
	, Edits = STUFF((
		SELECT ',' + cast(ce.RuleDesc as varchar(max))
		FROM LA_Ops_Temp.dbo.vClaimEdits ce	
		WHERE ce.Claimid = c.claimid
		FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '')
	, c.*
from la_ops_temp.dbo.vClaimsAll c
  
  
   /*************** Search for Tables********************/
  
  SELECT table_catalog, table_schema, table_type, table_name, table_schema_name = table_schema + '.' + table_name 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_NAME  LIKE '%%'
ORDER BY table_schema,table_type,table_name
  
    /*************** Temp Table Sizes ********************/
  USE tempdb
go

IF OBJECT_ID('tempdb.dbo.#tempsize') IS NOT NULL DROP TABLE #tempsize 
CREATE TABLE #tempsize
(
   name nvarchar(128),	
   rows char(20),	
   reserved varchar(18),	
   DATA varchar(18),	
   index_size varchar(18),	
   unused varchar(18)
)

INSERT INTO #tempsize
Exec sp_spaceused '#temptest' --Set temp table name here 

SELECT *
	, CAST(ROUND((CAST(LEFT(data, LEN(data) - 3) AS BIGINT)*1.0/1024),3,0) AS DECIMAL(10,3))  AS DataMB 
	, CAST(ROUND((CAST(LEFT(data, LEN(data) - 3) AS BIGINT)*1.0/1048576),3,0) AS DECIMAL(10,3)) AS DataGB
FROM #tempsize
  
  
/*************** DB Table Sizes ********************/
 select 
	schemaname = s.name
	, tablename = t.name
	, hasindexnamed = i.name
	, createddate = t.create_date
	, modifieddate = t.modify_date
	, rowcounts = sum(p.rows)
	, totalpages = sum(a.total_pages) 
	, usedpages = sum(a.used_pages)
	, datapages = sum(a.data_pages)
	, totalspacemb = (sum(a.total_pages) * 8) / 1024 
	, usedspacemb = (sum(a.used_pages) * 8) / 1024
	, dataspacemb = (sum(a.data_pages) * 8) / 1024
from sys.tables t 
	join sys.schemas s on t.schema_id = s.schema_id 
	join sys.indexes i on t.object_id = i.object_id
	join sys.partitions p on i.object_id = p.object_id and i.index_id = p.index_id
	join sys.allocation_units a on p.partition_id = a.container_id
where 
	t.name not like 'dt%'	-- dtproperties, design junk used by redgate, visualstudio, and others.
	and i.index_id <= 1	-- cix's only
group by s.name
	, t.name
	, i.object_id
	, i.index_id
	, i.name
	, t.create_date
	, t.modify_date 
order by ((sum(a.total_pages) * 8) / 1024) desc, t.name
  

						
						
/*************** Date Table ********************/						
declare @sd datetime = '2010-01-01' --Start date here
declare @ed datetime = '2015-12-31' --End date here 

;with cte_dates ([Date]) as (
    select [Date] = convert(datetime, @sd) 

    union all 

    select dateadd(day, 1, [Date])
    from cte_dates
    where [Date] < @ed
)

select 
	[Date]
	, Year = Year([date]) 
	, Month = Month([date])
	, MonthName = datename(mm, [date])
	, MonthNameShort = left(datename(mm, [date]),3)
	, Quarter = datename(qq, [date]) 
	, QuarterName = case	when datename(qq, [date]) = 1 then 'First' when datename(qq, [date]) = 2 then 'Second' 
							when datename(qq, [date]) = 3 then 'Third' when datename(qq, [date]) = 4 then 'Fourth' end
	, Day = datepart(dy, [date]) 
	, DayOfWeek = datepart(dw, [date])	
	, DayOfMonth = Day([date])
	, DayName = datename(w, [date])
	, DayNameShort = LEFT(datename(w, [date]),2)
	, Week = datepart(wk, [date])
	, StartOfMonth = DATEADD(mm, DATEDIFF(mm,0,[date]), 0)
	, EndOfMonth = cast(eomonth([date]) as datetime)
	, IsCurrentYear = case when year([date]) = year([date]) then 1 else 0 end 
	, IsCurrentMonth = case when year([date]) = year([date]) and month([date]) = month([date]) then 1 else 0 end 
	, IsCurrentDate = case when [date] = getdate() then 1 else 0 end 
	, IsLeapYear = CASE WHEN (year([date]) % 4 = 0 AND year([date]) % 100 <> 0) OR year([date]) % 400 = 0 THEN 1 else 0 end 
	, YYYYMM = format([date], 'yyyy-MM') --convert(varchar(6), date, 112)
from cte_dates

option (maxrecursion 32767) -- Don't forget to use the maxrecursion option!


/*************** Section Header ********************/	
select Header = '/*' + replicate('-',78) union all select '' union all select replicate('-',78) + '*/' 
						

/*************** UnPivot w/ Cross Apply ********************/	
create table #UnPivot (
	  Member varchar(20)	
	, Diagnosis1 varchar(20) NULL
	, Diagnosis2 varchar(20) NULL
	, Diagnosis3 varchar(20) NULL
	, Diagnosis4 varchar(20) NULL
	, Diagnosis5 varchar(20) NULL
)

insert into #UnPivot values 
('g100000001','E87.2','A41.9','R65.20','R79.89','C34.90'),	
('g100000002','H66.93','H10.9','R50.9','H92.03',NULL),
('g100000003','F32.9','Z13.89',NULL,NULL,NULL)

Select 
	  Member
	, Diagnosis
	, DiagnosisSequence
from #UnPivot
cross apply
(
  values
          (Diagnosis1, 1)
	, (Diagnosis2, 2)
	, (Diagnosis3, 3)
	, (Diagnosis4, 4)
	, (Diagnosis5, 5)

) c (Diagnosis, DiagnosisSequence)
where c.Diagnosis is not null

				 
				 

/*************** Split column to rows on delimiter ********************/					 
--https://sqlperformance.com/2012/07/t-sql-queries/split-strings
--Other uses of CROSS/OUTER APPLY https://stackoverflow.com/questions/9275132/real-life-example-when-to-use-outer-cross-apply-in-sql
		
CREATE FUNCTION dbo.fnSplitToRows
(
    @List       varchar(MAX),
    @Delimiter  varchar(255)
)
RETURNS TABLE
WITH SCHEMABINDING
AS
   RETURN 
   (  
      SELECT Item = y.i.value('(./text())[1]', 'nvarchar(4000)')
      FROM 
      ( 
        SELECT x = CONVERT(XML, '<i>' 
          + REPLACE(@List, @Delimiter, '</i><i>') 
          + '</i>').query('.')
      ) AS a CROSS APPLY x.nodes('i') AS y(i)
   );
GO
/*HOW TO USE dbo.fnSplitToRows			 
select 
	t.Column
	, ColumnSplittingToRows = f.Item
from tbl t 
	CROSS APPLY dbo.fnSplitToRows(t.columntosplit), ',') as f 				 				 
*/				 
