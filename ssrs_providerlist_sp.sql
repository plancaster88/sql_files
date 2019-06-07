/*

TECH REQUIREMENTS

Purpose:
	-When config finds correct BH provider lines then they will need to input the data into the report.
		-Providers will be identified on NPI.
	-This needs to be tracked and logged in a table in SQL Server.

Front End Requirements:
	-Built in SSRS.
	-Needs the following actions: Insert, Edit, and Delete.
	-Needs all Provider fields from the 328 report (BHRpt_328_Output).
		-Don't worry about the language fields yet.
	-Needs an action to view table data.

Back End Requirements:
	-Need a table in SQL Server to house the information.
		-Table will be called dbo.rsBHProviderNetwork.
	-We want to be able to show changes over time.
		-Add a seed column.
		-Add a createdate column.
		-Add a lastupdate column. 
	-Create some sort of check that sends a message if data formats are't correct.


Future Additions:
	-Create another backup table which tracks any action that occurs in the rsBHProviderNetwork table.
		-Insert record on any action to the backup table.
			-Table will be called dbo.rsBHProviderNetworkBackup.
			-Vitally important to  code this correctly. We don't want to lose any changes made.

SELECT ViewCatalog = TABLE_CATALOG
	, ViewSchema = TABLE_SCHEMA
	, ViewName = TABLE_NAME
	, ColName = COLUMN_NAME
	, DataType = DATA_TYPE
	, DataTypeExt = 
		DATA_TYPE + 
		case	when DATA_TYPE IN 	('binary', 'char', 'nchar', 'varchar', 'nvarchar', 'varbinary')
					then	
						case	when CHARACTER_MAXIMUM_LENGTH = -1 then '(Max)'
								else '(' + cast(CHARACTER_MAXIMUM_LENGTH as varchar) +')' end
				when DATA_TYPE IN ('decimal', 'numeric') 
					then cast(NUMERIC_PRECISION as varchar(4)) + ', ' + cast(NUMERIC_SCALE as varchar(4))
				
				else '' end 
	, Nullable = IS_NULLABLE
	, ColPosition = ORDINAL_POSITION
FROM information_schema.columns 
WHERE table_name = 'BHRpt_328_Output'
order by ColPosition
*/


/*

--drop  table #temp
create table #temp

(	Zip char(5)
	, St char(2)
	, CONSTRAINT [Incorrect Zip Code Format (11111). ] CHECK (zip like '[0-9][0-9][0-9][0-9][0-9]')
	, CONSTRAINT [Incorrect State Code Format (AA). ] CHECK (zip like '[A-Z][A-Z]')
)



declare @ErrorMessage varchar(max)
declare @dates smalldatetime

begin try
--insert into #temp values ('7001', 'AC')
	set @dates = cast('lpl' as smalldatetime)
end try

begin catch

	set @ErrorMessage = 
		case	when error_message() like '"' then 
					left(substring(ERROR_MESSAGE(), 1 + CHARINDEX('"', error_message()), 100)
						, charindex('"',substring(ERROR_MESSAGE(), 1 + CHARINDEX('"', error_message())
						, 100))-1)
				else error_message() end 
end catch

select @ErrorMessage

*/

/*

select * from la_ops_temp.dbo.rsBHProviderNetwork 

use LA_Ops_Temp 
go

--drop table dbo.rsBHProviderNetwork
--select * from dbo.rsBHProviderNetwork
--delete from dbo.rsBHProviderNetwork

create table dbo.rsBHProviderNetwork 
	(
		  ID							int identity(1,1) PRIMARY Key	
		, CreateUser					varchar(50) NOT NULL 
		, LastUpdateUser				varchar(50) NOT NULL 
		, CreateDate					smalldatetime NOT NULL 
		, LastUpdateDate				smalldatetime NOT NULL 
		, ProvID						varchar(50)	NOT NULL 
		, Prov_Npi						char(10) NOT NULL 		
		, RegistryID					varchar(50)	
		, MedicaidID					char(7)	
		, TIN							char(9)	
		, PROVLICENSE					varchar(50)	
		, Lic_EffDate					smalldatetime 
		, Lic_TermDate					smalldatetime 
		, AffiliateID					varchar(50)	NOT NULL 	
		, AcceptNewMedicaidPatients		varchar(1) NOT NULL 
		, Prov_Name						varchar(50) NOT NULL 
		, Phyaddr1						varchar(50) NOT NULL 
		, PhyCity						varchar(50)	NOT NULL 
		, PHYState						char(2)	NOT NULL 
		, Zip							char(5) NOT NULL	
		, Email							varchar(50)	
		, Phone							char(10)
		, FaxPhone						char(10) 		
		, Parish						varchar(50)	NOT NULL
		, RegionName					varchar(50) NOT NULL
		, Gender						varchar(1)	
		, Ethnicity						varchar(50)	
		, EthnicID						varchar(50)	--update w/ backend	
		, ProvType						varchar(50) NOT NULL --update w/ backend	
		, ProvType_Desc					varchar(50) NOT NULL
		, SpecCode						varchar(50) NOT NULL --update w/ backend
		, Spec_Desc						varchar(50) NOT NULL
		, Prescriber					varchar(1)
		, DEA_EffDate					smalldatetime --populate if prescriber is not null
		, DEA_TermDate					smalldatetime --populate if prescriber is not null
		, LevelofCare					varchar(50)
		, StartAge						varchar(3)  
		, EndAge						varchar(3)	
		, [Population(s)Served]			varchar(50) 	
		, LOCDate						smalldatetime
		--, CONSTRAINT [Zip format error. ] CHECK (zip like '[0-9][0-9][0-9][0-9][0-9]')
		--, CONSTRAINT [Prov NPI format error. ] CHECK (Prov_NPI like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
		--, CONSTRAINT [TIN format error. ] CHECK (TIN like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')

	)


use LA_Ops_Temp 
go

--drop table dbo.rsBHProviderNetworkBackup
--select * from dbo.rsBHProviderNetworkBackup
--delete from dbo.rsBHProviderNetworkBackup

create table dbo.rsBHProviderNetworkBackup
	(
		TriggerUser					varchar(50) NOT NULL
		, TriggerDate					smalldatetime NOT NULL 
		, Action						varchar(50) NOT NULL 
		, ID							int NOT NULL	
		, CreateUser					varchar(50) NOT NULL 
		, LastUpdateUser				varchar(50) NOT NULL 
		, CreateDate					smalldatetime NOT NULL 
		, LastUpdateDate				smalldatetime NOT NULL 
		, ProvID						varchar(50)	NOT NULL 
		, Prov_Npi						char(10) NOT NULL 		
		, RegistryID					varchar(50)	
		, MedicaidID					char(7)	
		, TIN							char(9)	
		, PROVLICENSE					varchar(50)	
		, Lic_EffDate					smalldatetime 
		, Lic_TermDate					smalldatetime 
		, AffiliateID					varchar(50)	NOT NULL 	
		, AcceptNewMedicaidPatients		varchar(1) NOT NULL 
		, Prov_Name						varchar(50) NOT NULL 
		, Phyaddr1						varchar(50) NOT NULL 
		, PhyCity						varchar(50)	NOT NULL 
		, PHYState						char(2)	NOT NULL 
		, Zip							char(5) NOT NULL	
		, Email							varchar(50)	
		, Phone							char(10)
		, FaxPhone						char(10) 		
		, Parish						varchar(50)	NOT NULL
		, RegionName					varchar(50) NOT NULL
		, Gender						varchar(1)	
		, Ethnicity						varchar(50)	
		, EthnicID						varchar(50)	--update w/ backend	
		, ProvType						varchar(50) NOT NULL --update w/ backend	
		, ProvType_Desc					varchar(50) NOT NULL
		, SpecCode						varchar(50) NOT NULL --update w/ backend
		, Spec_Desc						varchar(50) NOT NULL
		, Prescriber					varchar(1)
		, DEA_EffDate					smalldatetime --populate if prescriber is not null
		, DEA_TermDate					smalldatetime --populate if prescriber is not null
		, LevelofCare					varchar(50)
		, StartAge						varchar(3)  
		, EndAge						varchar(3)	
		, [Population(s)Served]			varchar(50) 	
		, LOCDate						smalldatetime

	)

--drop trigger dbo.trigAI_rsBHProviderNetwork
use la_ops_temp
go

CREATE TRIGGER dbo.trgAIAUAD_rsBHProviderNetwork 
ON dbo.rsBHProviderNetwork
AFTER INSERT, UPDATE, DELETE
AS


DECLARE @INS int, @DEL int
	
	IF (SELECT count(*) FROM inserted) = 1
		begin	set @ins = 1 
		end
	
	IF  (SELECT count(*) FROM deleted) = 1
		begin	set @del = 1 
		end
	

	if @INS = 1 and @del = 1 		
		begin	INSERT INTO dbo.rsBHProviderNetworkBackup 
				SELECT	
					current_user
					, getdate()
					, Action = 'Update'
					--, Action = case when CreateDate = LastUpdateDate then 'Insert' else 'Update' end
					, * 
				FROM inserted
		end

	else if @INS = 1 		
		begin	INSERT INTO dbo.rsBHProviderNetworkBackup 
				SELECT	
					current_user
					, getdate()
					, Action = 'Insert'
					, * 
				FROM inserted
		end

	else if @DEL = 1
		begin	INSERT INTO dbo.rsBHProviderNetworkBackup 
				SELECT 
					current_user
					, getdate()					
					, Action = 'Delete'
					, *
				 FROM deleted
		end



select * from dbo.rsBHProviderNetwork 
select * from dbo.rsBHProviderNetworkBackup 

*/

use la_ops_temp
go

--drop procedure dbo.sprsBHProviderNetwork

alter procedure dbo.sprsBHProviderNetwork
@action			varchar(100)
, @id			varchar(100)
, @provid		varchar(100)
, @provname		varchar(100)
, @provnpi		varchar(100)
, @provtype		varchar(100)
, @affiliateid	varchar(100)
, @speccode		varchar(100)
, @tin			varchar(100)
, @newpat		varchar(100)
, @registryid	varchar(100)
, @medicaidid	varchar(100)
, @phyaddr1		varchar(100)
, @provlic		varchar(100)
, @zip			varchar(100)
, @liceffdate	varchar(100)
, @phycity		varchar(100)
, @lictermdate	varchar(100)
, @parish		varchar(100)
, @prescriber	varchar(100)
, @region		varchar(100)
, @deaeffdate	varchar(100)
, @phystate		varchar(100)
, @deatermdate	varchar(100)
, @phone		varchar(100)
, @startage		varchar(100)
, @endage		varchar(100)
, @popserve		varchar(100)
, @email		varchar(100)
, @faxphone		varchar(100)
, @gender		varchar(100)
, @levelofcare	varchar(100)
, @ethnicity	varchar(100)
, @locdate		varchar(100)

as

begin try --need to handle any possible error in the code even the ones we don't know about 


	Declare @ErrorMessage varchar(max) = ''
	Declare @OutputMessage varchar(max) = ''

	--following vars are auto created based on ssrs params
	declare	@ethnicid varchar(50) =	isnull((select ethnicid from planreport_QNXT_LA.dbo.ethnicity where description = @ethnicity), '')
	declare	@provtypedesc varchar(50) =	isnull(
		(	select distinct top 1 ProvType_Desc 
			from LA_Temp.dbo.LevelofCare_Crosswalk_NoTax 
			where provtype = left(@provtype, 2)
		), '')
	declare	@specdesc varchar(50) = 	isnull(
		(	select distinct top 1 Provspec_Desc 
			from LA_Temp.dbo.LevelofCare_Crosswalk_NoTax 
			where provspec = left(@speccode, 2)
		), '')

	
	--handle ID input errors before proceeding to code
	if @id <> ''
		begin
			begin try
				set @id = cast(@id as int)
			end try --from error handling at beginning of code 
			begin catch
				if error_message() is not null 
					begin	set @ErrorMessage = 'Failed Process - Record ID must be in the correct format to proceed (numbers only).'	
							set @id = '' --reset id
							goto TableOutput --skip to table output
					end
			end catch
		end
	
/*---------------------------------------------------------------
ADDING A NEW RECORD
---------------------------------------------------------------*/

	--@TestColumn will be the NPI or Provider field?
	IF @action = 'New'
		begin 

			--ERROR HANDLING Step 1 - Add logic to handle data input errors such as incorrect digits in zip code
			if @provid not in (select distinct provid from planreport_QNXT_LA.dbo.provider where provid <> '')
				begin	set @ErrorMessage = @ErrorMessage + 'Provider ID not in QNXT. '
				end 
			if @provnpi not in (select distinct NPI from planreport_QNXT_LA.dbo.provider where npi is not null and npi <> '')
				begin	set @ErrorMessage = @ErrorMessage + 'NPI not in QNXT. ' 
				end 
			if len(@provnpi) <> 10
				begin	set @ErrorMessage = @ErrorMessage + 'NPI must be 10 characters. ' 
				end 
			if len(@medicaidid) not in (0, 7)
				begin	set @ErrorMessage = @ErrorMessage + 'If Medicaid ID is entered it must be 7 characters. ' 
				end 
			if len(@tin) not in (0, 9) or @tin not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @ErrorMessage = @ErrorMessage + 'If TIN is entered it must be 9 characters and be all numbers. ' 
				end 
			if @provlic <> '' and  (@liceffdate = '' or @lictermdate = '')
				begin	set @ErrorMessage = @ErrorMessage + 'If provider license has a value then license effective and term dates must be entered. ' 
				end 
			if @provlic = '' and  (@liceffdate <> '' or @lictermdate <> '')
				begin	set @ErrorMessage = @ErrorMessage + 'If provider license dates are entered then the provider license id must also be entered. ' 
				end 
			if @affiliateid not in (select distinct provid from planreport_QNXT_LA.dbo.provider where provid <> '')
				begin	set @ErrorMessage = @ErrorMessage + 'Group provider ID not in QNXT. '
				end
			if @newpat not in ('Y','N')
				begin	set @ErrorMessage = @ErrorMessage + 'Accepting new patients field must have a selection. '
				end
			if len(@provname) < 4
				begin	set @ErrorMessage = @ErrorMessage + 'Provider name must be filled out. '
				end
			if len(@phyaddr1) < 5
				begin	set @ErrorMessage = @ErrorMessage + 'Provider address must be filled out. '
				end
			if len(@phycity) < 2
				begin	set @ErrorMessage = @ErrorMessage + 'Provider city must be filled out. '
				end
			if len(@phystate) <> 2
				begin	set @ErrorMessage = @ErrorMessage + 'Provider state must be selected. '
				end
			if @zip not like '[0-9][0-9][0-9][0-9][0-9]'
				begin	set @ErrorMessage = @ErrorMessage + 'Provider zip must be selected and have correct format (5 digits). '
				end
			if @email <> '' and @email not like '%[@]%[.]%'
				begin	set @ErrorMessage = @ErrorMessage + 'If provider email is included, it must be in the correct format (name@domain.xxx). '
				end
			if @phone <> '' and @phone not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @ErrorMessage = @ErrorMessage + 'If provider phone is included, it must be in the correct format (5551112222 - no special characters or spaces). '
				end
			if @faxphone <> '' and @faxphone not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @ErrorMessage = @ErrorMessage + 'If provider fax is included, it must be in the correct format (5551112222 - no special characters or spaces). '
				end
			if @parish = ''
				begin	set @ErrorMessage = @ErrorMessage + 'Provider parish must be selected. '
				end
			if @region = ''
				begin	set @ErrorMessage = @ErrorMessage + 'Provider region must be selected. '
				end
			if @provtype = ''
				begin	set @ErrorMessage = @ErrorMessage + 'Provider type must be selected. '
				end
			if @speccode = ''
				begin	set @ErrorMessage = @ErrorMessage + 'Provider specialty must be selected. '
				end
			if @prescriber = 'Y' and  (@deaeffdate = '' or @deatermdate = '')
				begin	set @ErrorMessage = @ErrorMessage + 'If provider has a DEA license then license effective and term dates must be entered. ' 
				end 
			if @prescriber in ('', 'N') and  (@deaeffdate <> '' or @deatermdate <> '')
				begin	set @ErrorMessage = @ErrorMessage + 'If DEA license dates are entered then the provider must be licensed to prescribe (select Y in dropdown or clear dates). ' 
				end 
			if (@endage <> '' and @startage = '') or (@endage = '' and @startage <> '')
				begin	set @ErrorMessage = @ErrorMessage + 'If serving start or end age is selected than the other must also be selected. ' 
				end 
		

				begin try 
					set @startage = (select cast(@startage as int))
					set @endage = (select cast(@endage as int))
				end try
				begin catch
					if error_message() is not null 
						begin set @ErrorMessage = @ErrorMessage + 'Start and end age must be in the correct format (0-120). '
								goto SkipAgeTests	
						end
				end catch
	
			if @startage <> '' and cast(@startage as int) not between 0 and 65
				begin	set @ErrorMessage = @ErrorMessage + 'If serving start age is selected, it must be between 0 and 65. ' 
				end 
			if @endage <> '' and cast(@startage as int) not between 0 and 120
				begin	set @ErrorMessage = @ErrorMessage + 'If serving start age is selected, it must be between 0 and 120. ' 
				end 
			if cast(@endage as int) < cast(@startage as int)
				begin	set @ErrorMessage = @ErrorMessage + 'Serving start age cannot be less than serving end age. ' 
				end 

			SkipAgeTests: --skip the previous 3 age tests if age was not an integer b/c it will throw a data type error when casting to int

				begin try 
					set @deaeffdate = (select cast(@deaeffdate as smalldatetime))
					set @deatermdate = (select cast(@deatermdate as smalldatetime))
					set @locdate = (select cast(@locdate as smalldatetime))
					set @liceffdate = (select cast(@liceffdate as smalldatetime))
					set @lictermdate = (select cast(@lictermdate as smalldatetime))
				end try
				begin catch
					if error_message() is not null 
						begin set @ErrorMessage = @ErrorMessage + 'If dates are entered, they must be in the correct format (01/01/1900). '
					
						end
				end catch

			--Error Handling step 2 
			if @ErrorMessage <> ''
				begin	set @ErrorMessage = 'Failed to Create New Record - Required fields indicated by *. ' + @ErrorMessage
						goto TableOutput
				end 
	
			
		
			--INSERT BACKUP RECORD - Handled by a trigger dbo.trgAIAUAD_rsBHProviderNetwork

			--INSERT RECORD - Insert record to the main table. 
			insert into la_ops_temp.dbo.rsBHProviderNetwork  
				(	CreateUser,CreateDate,LastUpdateUser,LastUpdateDate,ProvID,Prov_Npi,RegistryId,MedicaidID,TIN,ProvLicense
					,Lic_EffDate,Lic_TermDate,AffiliateID,AcceptNewMedicaidPatients,Prov_Name,Phyaddr1,PhyCity,PhyState
					,Zip,Email,Phone,FaxPhone,Parish,RegionName,Gender,Ethnicity,EthnicID,ProvType,ProvType_Desc,SpecCode
					,Spec_Desc,Prescriber,DEA_EffDate,DEA_TermDate,LevelofCare,StartAge,EndAge,[Population(s)Served],LOCDate
				)
		
				values 
					(	--id auto populates
						 current_user, getdate(), current_user, getdate(), @provid, @provnpi, @registryid, @medicaidid
						, @tin, @provlic, @liceffdate, @lictermdate, @affiliateid, @newpat, @provname, @phyaddr1
						, @phycity, @phystate, @zip, @email, @phone, @faxphone, @parish, @region, @gender, @ethnicity 
						, @ethnicid, left(@provtype, 2), @provtypedesc, left(@speccode, 2), @specdesc, @prescriber, @deaeffdate
						, @deatermdate, @levelofcare, @startage, @endage, @popserve, @locdate
					)	
		
			set @OutputMessage = 'Successfully created a new record (' + @id  + ').'
		
		
		
		end 		



/*---------------------------------------------------------------
EDITING A RECORD
---------------------------------------------------------------*/


	IF @action = 'Edit'
		begin 

			--Error Handling Step 1 
			if @id not in (select distinct id from la_ops_temp.dbo.rsBHProviderNetwork)
				begin set @ErrorMessage = 'Failed to edit - Record ID selected does not exist. '
						goto TableOutput
				end

			--Determine which variables/parameters need to be updated (empty vars use existing record id value)


			if @provid <> '' and  @provid not in (select distinct provid from planreport_QNXT_LA.dbo.provider where provid <> '')
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider ID not in QNXT. '
				end
			else if @provid = (select top 1 provid from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg...	
				end
			else if @provid <> '' and @provid in (select distinct provid from planreport_QNXT_LA.dbo.provider where provid <> '')
				begin	set @OutputMessage = @OutputMessage + 'Provider ID has been updated. '
				end 


			if @provnpi <> '' and @provnpi not in (select distinct npi from planreport_QNXT_LA.dbo.provider where npi is not null and npi <> '')
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider NPI not in QNXT. '
				end
			else if @provnpi = (select top 1 prov_npi from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 
				end
			else if @provnpi <> '' and @provnpi in (select distinct npi from planreport_QNXT_LA.dbo.provider where npi is not null and npi <> '')
				begin	set @OutputMessage = @OutputMessage + 'Provider NPI has been updated. '
				end 


			if @registryid = (select top 1 registryid from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @registryid <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider medicaid ID has been updated. '
				end 


			if len(@medicaidid) not in (0, 7)
				begin	set @ErrorMessage = @ErrorMessage  + 'If medicaid ID is entered it must be 7 characters. '
				end
			else if @medicaidid = (select top 1 medicaidid from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 	
				end
			else if @medicaidid <> '' and len(@medicaidid) = 7
				begin	set @OutputMessage = @OutputMessage + 'Provider medicaid ID has been updated. '
				end 


			if len(@tin) > 0 and @tin not like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @ErrorMessage = @ErrorMessage + 'If TIN is entered it must be 9 characters and be all numbers. ' 
				end 
			else if @tin = (select top 1 tin from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if len(@tin) = 9 and @tin like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @OutputMessage = @OutputMessage + 'Provider TIN has been updated. '
				end 


			if @provlic = (select top 1 provlicense from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @provlic <> '' and 
				(	(@liceffdate = '' and 
						(select top 1 lic_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' ) or
					(@lictermdate = '' and 
						(select top 1 lic_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' )

				)
				begin	set @ErrorMessage = @ErrorMessage + 'If provider license has a value then license effective and term dates must be entered. '
				end
			else if @provlic <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider license has been updated. '
				end


			begin try 
				set @liceffdate = (select cast(@liceffdate as smalldatetime))
				set @lictermdate = (select cast(@lictermdate as smalldatetime))
			end try
			begin catch
				if error_message() is not null 
					begin	set @ErrorMessage = @ErrorMessage + 'If dates are entered, they must be in the correct format (01/01/1900). '
							goto SkipLicenseDates --skip b/c incorrect data format could break code
					end
			end catch	


			--When you try catch by casting a '' value to smalldatetime it becomes Jan  1 1900 12:00AM
			-- We don't want this to overwrite anything.
			if	@liceffdate = 'Jan  1 1900 12:00AM' 
				begin set	@liceffdate = (select top 1 lic_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end
			if	@lictermdate = 'Jan  1 1900 12:00AM' 
				begin set	@lictermdate = (select top 1 lic_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end


			if @liceffdate = (select top 1 lic_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @liceffdate <> '' and 
				(	(@provlic = '' and 
						(select top 1 provlicense from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' ) or
					(@lictermdate = '' and 
						(select top 1 lic_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' )

				)
				begin	set @ErrorMessage = @ErrorMessage + 'If provider license effective date has a value then the provider license and term date must be entered. '
				end
			else if @provlic <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider license effective date has been updated. '
				end


			if @lictermdate = (select top 1 lic_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @liceffdate <> '' and 
				(	(@provlic = '' and 
						(select top 1 provlicense from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' ) or
					(@liceffdate = '' and 
						(select top 1 lic_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' )

				)
				begin	set @ErrorMessage = @ErrorMessage + 'If provider license term date has a value then the provider license and effective date must be entered. '
				end
			else if @provlic <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider license term date has been updated. '
				end


			SkipLicenseDates: 


			if @affiliateid <> '' and  @affiliateid not in (select distinct provid from planreport_QNXT_LA.dbo.provider where provid <> '')
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider affiliate ID not in QNXT. '
				end
			else if @affiliateid = (select top 1 affiliateid from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg...	
				end
			else if @affiliateid <> '' and @affiliateid in (select distinct provid from planreport_QNXT_LA.dbo.provider where provid <> '')
				begin	set @OutputMessage = @OutputMessage + 'Provider affiliate ID has been updated. '
				end 


			if @newpat = (select top 1 AcceptNewMedicaidPatients from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @newpat	in ('Y', 'N')
				begin	set @OutputMessage = @OutputMessage + 'Provider medicaid ID has been updated. '
				end 


			if @provname = (select top 1 prov_name from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if len(@provname) >= 4
				begin	set @OutputMessage = @OutputMessage + 'Provider name has been updated. '
				end 
			else if @provname <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider name is too short. '
				end


			if @phyaddr1 = (select top 1 phyaddr1 from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if len(@phyaddr1) >= 5
				begin	set @OutputMessage = @OutputMessage + 'Provider address has been updated. '
				end 
			else if @phyaddr1 <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider address is too short. '
				end


			if @phycity = (select top 1 phycity from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if len(@phycity) >= 2
				begin	set @OutputMessage = @OutputMessage + 'Provider city has been updated. '
				end 
			else if @phycity <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider city is too short. '
				end


			if @phystate = (select top 1 phystate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if len(@phystate) = 2
				begin	set @OutputMessage = @OutputMessage + 'Provider state has been updated. '
				end 
			else if @phystate <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider state must be 2 characters. '
				end


			if @zip = (select top 1 zip from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @zip like '[0-9][0-9][0-9][0-9][0-9]'
				begin	set @OutputMessage = @OutputMessage + 'Provider zip has been updated. '
				end 
			else if @zip <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider zip must have correct format (5 digits). '
				end


			if @email = (select top 1 email from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @email like '%[@]%[.]%'
				begin	set @OutputMessage = @OutputMessage + 'Provider email has been updated. '
				end 
			else if @email <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider email must be in the correct format (name@domain.xxx). '
				end


			if @phone = (select top 1 phone from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @phone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @OutputMessage = @OutputMessage + 'Provider phone has been updated. '
				end 
			else if @phone <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider phone must be in the correct format (5551112222 - no special characters or spaces). '
				end


			if @faxphone = (select top 1 faxphone from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @faxphone like '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
				begin	set @OutputMessage = @OutputMessage + 'Provider fax has been updated. '
				end 
			else if @faxphone <> ''
				begin	set @ErrorMessage = @ErrorMessage  + 'Provider fax must be in the correct format (5551112222 - no special characters or spaces). '
				end


			if @parish = (select top 1 parish from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @parish	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider parish has been updated. '
				end 


			if @region = (select top 1 regionname from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @region	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider region has been updated. '
				end 


			if @gender = (select top 1 gender from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @gender	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider gender has been updated. '
				end 


			if @ethnicity = (select top 1 ethnicity from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @ethnicity	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider ethnicity has been updated. '
				end 


			if left(@provtype, 2) = (select top 1 provtype from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if left(@provtype, 2)	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider type has been updated. '
				end 
		

			if left(@speccode, 2) = (select top 1 speccode from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if left(@speccode, 2)	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider specialty has been updated. '
				end 
				

			if @gender = (select top 1 gender from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @gender	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider gender has been updated. '
				end 


			if @prescriber = (select top 1 prescriber from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @prescriber = 'Y' and 
				(	(@deaeffdate = '' and 
						(select top 1 dea_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' ) or
					(@deatermdate = '' and 
						(select top 1 dea_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' )

				)
				begin	set @ErrorMessage = @ErrorMessage + 'If provider prescriber has a value then DEA effective and term dates must be entered. '
				end
			else if @prescriber = 'N'
				begin	set @OutputMessage = @OutputMessage + 'Provider DEA license has been updated (DEA dates have been reset). '
						set @deaeffdate  = '1900-01-01'
						set @deatermdate = '1900-01-01'
						goto SkipDEADates --no need to go through that step if dates are reset
				end
			else if @prescriber = 'Y'
				begin	set @OutputMessage = @OutputMessage + 'Provider DEA license has been updated. '
				end


			begin try 
				set @deaeffdate = (select cast(@deaeffdate as smalldatetime))
				set @deatermdate = (select cast(@deatermdate as smalldatetime))
			end try
			begin catch
				if error_message() is not null 
					begin	set @ErrorMessage = @ErrorMessage + 'If dates are entered, they must be in the correct format (01/01/1900). '
							goto SkipDEADates --skip b/c incorrect data format could break code
					end
			end catch
		

			--When you try catch by casting a '' value to smalldatetime it becomes Jan  1 1900 12:00AM
			-- We don't want this to overwrite anything.
			if	@deaeffdate = 'Jan  1 1900 12:00AM'  
				begin set	@deaeffdate = (select top 1 dea_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end
			if	@deatermdate = 'Jan  1 1900 12:00AM' 
				begin set	@deatermdate = (select top 1 dea_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end

		
			if @deaeffdate = (select top 1 dea_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @deaeffdate <> '' and 
				(	(@prescriber in ('n','') and 
						(select top 1 prescriber from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) in ('N', '') ) or
					(@deatermdate = '' and 
						(select top 1 dea_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' )

				)
				begin	set @ErrorMessage = @ErrorMessage + 'If provider prescriber effective date has a value then prescriber must be Y and term date filled out. '
				end
			else if @deaeffdate <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider DEA effective date has been updated. '
				end


			if @deatermdate = (select top 1 dea_termdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @deatermdate <> '' and 
				(	(@prescriber in ('n','') and 
						(select top 1 prescriber from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) in ('N', '') ) or
					(@deaeffdate = '' and 
						(select top 1 dea_effdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) = '' )

				)
				begin	set @ErrorMessage = @ErrorMessage + 'If provider prescriber term date has a value then prescriber must be Y and effective date filled out. '
				end
			else if @deatermdate <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider DEA term date has been updated. '
				end


			SkipDEADates:


			if @levelofcare = (select top 1 levelofcare from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @levelofcare	<> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider level of care has been updated. '
				end 


			begin try 
				set @startage = (select cast(@startage as int))
				set @endage = (select cast(@endage as int))
			end try
			begin catch
				if error_message() is not null 
					begin set @ErrorMessage = @ErrorMessage + 'Start and end age must be in the correct format (0-120). '
							goto SkipAgeTests2	
					end
			end catch


			--When you try catch by casting a '' value to int becomes 0.
			-- We don't want this to overwrite anything.
			if	@startage = '0' 
				begin set	@startage = (select top 1 startAge from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end
			if	@endage = '0' 
				begin set	@endage = (select top 1 endage from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end


			if @startage = (select top 1 startage from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @ErrorMessage = @ErrorMessage --don't change the output msg... 	
				end 
			else if cast(@startage as int) > 65
				begin	set @ErrorMessage = @ErrorMessage + 'If serving start age is selected, it must be between 0 and 65. ' 
				end 
			else if @startage <> '' and @endage <> '' and cast(@startage as int) > cast(@endage as int) 
				begin	set @ErrorMessage = @ErrorMessage + 'Serving start age must be less than the end age. ' 
				end 
			else if @startage <> '' and @endage = '' and cast(@startage as int) 
						> cast((select top 1 endage from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) as int)
				begin	set @ErrorMessage = @ErrorMessage + 'Serving start age must be less than the end age. '  
				end 
			else if @startage <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider serving start age has been updated. '
				end 
			
			
			if @endage = (select top 1 endage from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @ErrorMessage = @ErrorMessage --don't change the output msg... 	
				end 
			else if cast(@endage as int) > 120
				begin	set @ErrorMessage = @ErrorMessage + 'If serving end age is selected, it must be between 0 and 120. ' 
				end 
			else if @endage <> '' and @startage <> '' and cast(@endage as int) < cast(@startage as int) 
				begin	set @ErrorMessage = @ErrorMessage + 'Serving end age must be greater than the start age. ' 
				end 
			else if @endage <> '' and @startage = '' and cast(@startage as int) 
						> cast((select top 1 endage from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) as int)
				begin	set @ErrorMessage = @ErrorMessage + 'Serving end age must be less than the end age. '  
				end 
			else if @endage <> ''
				begin	set @OutputMessage = @OutputMessage + 'Provider serving end age has been updated. '
				end 


			SkipAgeTests2: --skip the previous 2 age tests if age was not an integer b/c it will throw a data type error when casting to int


			if @popserve = (select top 1 [population(s)served] from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @popserve <> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider population(s) served has been updated. '
				end 


			begin try 
				set @locdate = (select cast(@locdate as smalldatetime))
			end try
			begin catch
				if error_message() is not null 
					begin	set @ErrorMessage = @ErrorMessage 
								+ 'If dates are entered, they must be in the correct format (01/01/1900). '		
							goto SkipLOCDates
					end
			end catch


			--When you try catch by casting a '' value to smalldatetime it becomes Jan  1 1900 12:00AM
			-- We don't want this to overwrite anything.
			if	@locdate = 'Jan  1 1900 12:00AM'  
				begin set	@locdate = (select top 1 locdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id) 
				end


			if @locdate = (select top 1 locdate from la_ops_temp.dbo.rsBHProviderNetwork where id = @id)
				begin	set @OutputMessage = @OutputMessage --don't change the output msg... 		
				end
			else if @locdate <> '' --dropdown in SSRS
				begin	set @OutputMessage = @OutputMessage + 'Provider LOC date has been updated. '
				end 
			

			SkipLOCDates:


			--Error Handling Step 2 
			if @ErrorMessage  <> ''
				begin	set @ErrorMessage = 'Failed to Edit - ' + @ErrorMessage
						goto TableOutput
				end 

			if @OutputMessage  = '' 
				begin	set @OutputMessage = 'Failed to make changes - User inputs were the same as the existing data for the record. '
						goto TableOutput
				end 

			if @OutputMessage <> '' 
				begin set @OutputMessage =  'Successful Update - Record ' + @id + ' has been updated. ' + @outputmessage 
				end 



		--EDIT RECORD - Edit record of the same ID in the main table.
		UPDATE la_ops_temp.dbo.rsBHProviderNetwork  
		SET LastUpdateUser = current_user
			, LastUpdateDate = getdate()
			, Provid = case when @provid = '' then ProvID else @provid end 
			, Prov_NPI = case when @provnpi = '' then Prov_NPI else @provnpi end
			, Registryid = case when @registryid = '' then registryid else @registryid end 
			, Medicaidid = case when @medicaidid = '' then Medicaidid else @medicaidid end 
			, TIN = case when @tin = '' then TIN else @tin end
			, ProvLicense = case when @provlic = '' then ProvLicense else @provlic end 
			, Lic_Effdate = case when @liceffdate = '' then Lic_Effdate else @liceffdate end 
			, Lic_Termdate = case when @lictermdate = '' then Lic_Effdate else @lictermdate end 
			, AffiliateID = case when @affiliateid = '' then affiliateid else @affiliateid end 
			, AcceptNewMedicaidPatients = case when @newpat = '' then AcceptNewMedicaidPatients else @newpat end 
			, Prov_Name = case when @provname = '' then Prov_Name else @provname end 
			, Phyaddr1 = case when @phyaddr1 = '' then Phyaddr1 else @phyaddr1 end 
			, PhyCity = case when @phycity = '' then PhyCity else @phycity end 
			, PhyState = case when @phystate = '' then PhyState else @phystate end 
			, Zip = case when @zip = '' then Zip else @zip end 
			, Email = case when @email = '' then Email else @email end 
			, Phone = case when @phone = '' then Phone else @phone end 
			, FaxPhone = case when @faxphone = '' then FaxPhone else @faxphone end 
			, Parish = case when @parish = '' then Parish else @parish end 
			, RegionName = case when @region = '' then RegionName else @region end 
			, Gender = case when @gender = '' then Gender else @gender end 
			, Ethnicity = case when @ethnicity = '' then Ethnicity else @ethnicity end 
			, ethnicid = case when @ethnicid = '' then Ethnicid else @ethnicid end 
			, ProvType = case when @provtype = '' then Provtype else @provtype end 
			, Provtype_desc = case when @provtypedesc = '' then provtype_desc else @provtypedesc end 
			, Speccode = case when @speccode = '' then speccode else @speccode end 
			, spec_desc = case when @specdesc = '' then spec_desc else @specdesc end 
			, prescriber = case when @prescriber = '' then prescriber else @prescriber end 
			, dea_effdate = case when @deaeffdate = '' then dea_effdate else @deaeffdate end 
			, dea_termdate = case when @deatermdate = '' then dea_termdate else @deatermdate end 
			, LevelofCare = case when @levelofcare = '' then levelofcare else @levelofcare end
			, StartAge = case when @startage = '' then StartAge else @startage end
			, EndAge = case when @endage = '' then EndAge else @endage end
			, [Population(s)Served] = case when @popserve = '' then [Population(s)Served] else @popserve end
			, LOCDate = case when @locdate = '' then LOCDate else @locdate end 
		WHERE ID = @id

	end 


/*---------------------------------------------------------------
DELETING A RECORD
---------------------------------------------------------------*/

	IF @action = 'Delete'
		begin	

			--ERROR HANDLING Step 1 - Add logic to handle data input errors such as incorrect digits in zip code
			if @id not in (select distinct id from la_ops_temp.dbo.rsBHProviderNetwork)
				begin
					set @ErrorMessage = 'Failed Delete - Record id does not exist. '
				end


			--ERROR HANDLNG Step 2 - If any there were any errors in the values being edited, skip section and go to the table output
			if @ErrorMessage <> ''
				begin 
					GOTO TableOutput 
				end 

			--INSERT BACKUP RECORD - Handled by a trigger dbo.trgAIAUAD_rsBHProviderNetwork


			delete from la_ops_temp.dbo.rsBHProviderNetwork  
			where ID = @id

			set @OutputMessage = 'Successful Delete - record ' + @id +' has been deleted.'

		end

/*---------------------------------------------------------------
FINAL OUPUT
---------------------------------------------------------------*/

TableOutput: --Point in code to go to if issue in prior steps


end try --from error handling at beginning of code 
begin catch
	if error_message() is not null 
		begin set @ErrorMessage =
			'Failed Process - Unknown error. If error persists please see Operations development team. Error Message: ' + ERROR_MESSAGE()			
		end
end catch


if @ErrorMessage <> ''
	begin set @OutputMessage = @ErrorMessage 
	end 

--Viewing of the table should happen after any action is taken so that updates can be seen in SSRS
if @action = 'View' and (@id  <> '' or @provid <> '' or @provname <> '')
	begin
		SELECT *, OutputMessage = @OutputMessage	
		FROM     la_ops_temp.dbo.rsBHProviderNetwork  
		where ID = @id or provid = @provid or CHARINDEX(@provname, prov_name) > 0
		order by ID desc 
	end 
else if @action in ('View', 'Delete', 'New', 'Edit')
	begin
		SELECT *, OutputMessage = @OutputMessage    
		FROM     la_ops_temp.dbo.rsBHProviderNetwork  
		order by ID desc 
	end 



