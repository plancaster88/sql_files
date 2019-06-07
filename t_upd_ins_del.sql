USE [LA_Temp]
GO
/****** Object:  Trigger [dbo].[trgAIAUAD_BH_Provider_STG_IndvSurveyAudit_Backup]    Script Date: 06/07/2019 11:33:15 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER TRIGGER [dbo].[trgAIAUAD_BH_Provider_STG_IndvSurveyAudit_Backup]
ON [dbo].[BH_Provider_STG_IndvSurveyAudit]
AFTER INSERT, UPDATE, DELETE
AS


DECLARE @INS int, @DEL int
	
	set @ins =  (SELECT count(*) FROM inserted)	
	set @del =  (SELECT count(*) FROM deleted)
	
	if @INS = @del	
		begin	INSERT INTO [dbo].[BH_Provider_STG_IndvSurveyAudit_Backup]
				SELECT	
					EventType = 'Update'
					, getdate()
					--, Action = case when CreateDate = LastUpdateDate then 'Insert' else 'Update' end
					, * 
				FROM inserted
		end
	else if @INS >= 1 	
		begin	INSERT INTO [dbo].[BH_Provider_STG_IndvSurveyAudit_Backup]
				SELECT	
					EventType = 'Insert'
					, getdate()
					, * 
				FROM inserted
		end
	else if @DEL >= 1
		begin	INSERT INTO [dbo].[BH_Provider_STG_IndvSurveyAudit_Backup]
				SELECT 
					EventType = 'Delete'
					, getdate()
					, *
				 FROM deleted
		end
