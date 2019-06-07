USE [LA_Temp]
GO

/****** Object:  View [dbo].[vOpsAgeBands]    Script Date: 06/07/2019 11:22:28 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Created by: Philip Lancaster
Date Created: 9/26/2018

Notes: This was created to have a lookup table for Age Bands.
	
Keys: Age

Update Log:

*/

create view [dbo].[vOpsAgeBands] as

select top 126
Age = ROW_NUMBER() OVER(ORDER BY date) - 1
, AgeBand = 
	case 
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 0 and 1 then '0-1'
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 2 and 9 then '2-9'
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 10 and 14 then '10-14'
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 15 and 18 then '15-18'
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 19 and 34 then '19-34'
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 35 and 64 then '35-64'
		when ROW_NUMBER() OVER(ORDER BY date) - 1 >= 65 then '65+' end 
, AgeBandNum = 
	case 
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between -1 and 1 then 1
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 2 and 9 then 2
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 10 and 14 then 3
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 15 and 18 then 4
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 19 and 34 then 5
		when ROW_NUMBER() OVER(ORDER BY date) - 1 between 35 and 64 then 6
		when ROW_NUMBER() OVER(ORDER BY date) - 1 >= 65 then 7 end 
from la_temp.dbo.dates  

GO
