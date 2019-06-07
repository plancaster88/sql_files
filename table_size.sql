USE [LA_Ops_Temp]
GO

/****** Object:  View [dbo].[vTableSize]    Script Date: 06/07/2019 11:28:14 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[vTableSize] as 


SELECT top (select count(*) from   sys.tables)
      TableName = t.Name
    , IndexName = i.name
    , [RowCount] = sum(p.rows)/count(*)
	, [RowCountAllAllocations] = sum(p.rows)
    , TotalPages = sum(a.total_pages)
    , UsedPages = sum(a.used_pages)
    , DataPages = sum(a.data_pages)
    , TotalSpaceMB = (sum(a.total_pages) * 8) / 1024 
    , UsedSpaceMB = (sum(a.used_pages) * 8) / 1024
    , DataSpaceMB = (sum(a.data_pages) * 8) / 1024
	--, TotalDBSpace = (SELECT  size * 8/1024 FROM sys.database_files where name = (select db_name()))
FROM sys.tables t
	INNER JOIN      
		sys.indexes i ON t.OBJECT_ID = i.object_id
	INNER JOIN 
		sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id
	INNER JOIN 
		sys.allocation_units a ON p.partition_id = a.container_id
WHERE t.NAME NOT LIKE 'dt%' AND
    i.OBJECT_ID > 255 AND   
    i.index_id <= 1
GROUP BY t.NAME, i.object_id, i.index_id, i.name
order by DataSpaceMB desc 



GO


