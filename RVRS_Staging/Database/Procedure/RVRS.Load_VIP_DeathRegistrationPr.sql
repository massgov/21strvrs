

IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathRegistrationPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathRegistrationPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathRegistrationPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathRegistrationPr]
AUTHOR	:Sailendra Singh
CREATED	:Jan 26 2023  
PURPOSE	:TO LOAD DATA INTO FACT DeathRegistration TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Jan 26 2023 		Sailendra Singh						RVRS 174 : LOAD DECEDENT DeathRegistration DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal] WHERE Entity = 'DeathRegistration'
TRUNCATE TABLE [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathRegistration]
DROP TABLE  [RVRS].[DeathRegistration_Log]
DELETE FROM  [RVRS].[Execution] WHERE Entity = 'DeathRegistration'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathRegistrationPr]
*/

 
BEGIN 
 DECLARE @ExecutionId BIGINT
		,@TotalPendingReviewRecord INT
		,@TotalWarningRecord INT
		,@Err_Message VARCHAR(1000)
		,@LastLoadedDate DATE
		,@CurentTime AS DATETIME=GETDATE()
		,@LastLoadDate DATE
		,@TotalProcessedRecords INT
		,@MAXDateinData DATE
		,@TotalLoadedRecord INT
		,@TotalErrorRecord INT=0
		,@ExecutionStatus VARCHAR(100)='Completed'
		,@Note VARCHAR(500)
		,@RecordCountDebug INT  
		,@TotalParentMissingRecords INT = 0
		
	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
1 - Create temp table 
----------------------------------------------------------------------------------------------------------------------------------------------
*/


IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Create log table 
----------------------------------------------------------------------------------------------------------------------------------------------
*/


IF OBJECT_ID(' [RVRS].[DeathRegistration_Log]') IS NULL 
	CREATE TABLE  [RVRS].[DeathRegistration_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), RegistrationNumber_DC VARCHAR(128),DepositionNumber_DC VARCHAR(128),RegVolume_DC VARCHAR(128),RegPage_DC VARCHAR(128), [DimRegistrarTypeInternalId] INT,[PersonId] BIGINT,[RegistrationDate] VARCHAR(10),[DimRegistrarId] INT,[RegistrationNumber] VARCHAR(32),[AmendmentDate] VARCHAR(16),[DimRecordAccessId] INT,[RegVolume] VARCHAR(24),[RegPage] VARCHAR(10),[DepositionNumber] VARCHAR(24),[ArchivalPrintedDate] VARCHAR(10),[FlArchived] VARCHAR(8),[FlAcknowledge] VARCHAR(8),[PreviousVolumePage] VARCHAR(15),[DimPageEntryTypeId] INT,[FlRegistered] VARCHAR(8),[SrcRegistererUserId] INT,[FlSearchable] VARCHAR(8), RegistrarId VARCHAR(128),RegistrarName VARCHAR(128),PageEntryType VARCHAR(128),RecordAccess VARCHAR(128),OCCUR_REGIS_DATE VARCHAR(128),RESIDE_REGIS_DATE VARCHAR(128),ST_REGIS_DATE VARCHAR(128),DOD VARCHAR(128),VRV_REC_REPLACE_NBR VARCHAR(128),FL_OCCUR_IS_RESIDE VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathRegistration_Log_Flag BIT ,LoadNote VARCHAR(MAX))

BEGIN TRY

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Set Execution intial status
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '1'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			
INSERT INTO  [RVRS].[Execution] 
		(
			 Entity
			,ExecutionStatus
			,LastLoadDate
			,StartTime
			,EndTime
			,TotalProcessedRecords
			,TotalLoadedRecord
			,TotalErrorRecord
			,TotalPendingReviewRecord
			,TotalWarningRecord
		)
		SELECT 'DeathRegistration' AS Entity
			,'In Progress' AS ExecutionStatus
			,NULL AS LastLoadDate			
			,@CurentTime AS StartTime
			,NULL AS EndTime
			,0 AS TotalProcessedRecords
			,0 AS TotalLoadedRecord
			,0 AS TotalErrorRecord
			,0 AS TotalPendingReviewRecord
			,0 AS TotalWarningRecord

		SET @ExecutionId = (SELECT IDENT_CURRENT('RVRS.Execution'))
	
		
/*
----------------------------------------------------------------------------------------------------------------------------------------------
3 - Collect data from Staging
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM  [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathRegistration' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,COALESCE(1000000 + OCCUR_REGIS_NAME,'0') RegistrarId,COALESCE(OCCUR_REGIS_NAMEL,'NULL') RegistrarName,OCCUR_REGIS_NUM RegistrationNumber,OCCUR_REGIS_DATE RegistrationDate,OCCUR_REGIS_VOLUME RegVolume,OCCUR_REGIS_PAGE RegPage,OCCUR_DEPOSITION_NUM DepositionNumber,OCCUR_AMENDMENT_DATE AmendmentDate,ARCHIVAL_COPY_PRINTED_DATE ArchivalPrintedDate,FL_OCCUR_ARCHIVED FlArchived,OCCUR_REGISTERED_FL FlRegistered,FL_SEARCHABLE FlSearchable,REGISTERER_ID SrcRegistererUserId,NULL FlAcknowledge,NULL PreviousVolumePage,COALESCE(NULL,'NULL') PageEntryType,COALESCE(NULL,'NULL') RecordAccess,OCCUR_REGIS_DATE OCCUR_REGIS_DATE,RESIDE_REGIS_DATE RESIDE_REGIS_DATE,ST_REGIS_DATE ST_REGIS_DATE,DOD DOD,VRV_REC_REPLACE_NBR VRV_REC_REPLACE_NBR,FL_OCCUR_IS_RESIDE FL_OCCUR_IS_RESIDE,1 DimRegistrarTypeInternalId
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                      
    
		          UNION ALL    
				 

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,COALESCE(1000000 + RESIDE_REGIS_NAME,'0') ,COALESCE(RESIDE_REGIS_NAMEL,'NULL') ,RESIDE_REGIS_NUM ,RESIDE_REGIS_DATE ,RESIDE_REGIS_VOLUME ,RESIDE_REGIS_PAGE ,RESIDE_DEPOSITION_NUM ,NULL ,ARCHIVL_COPY_PRINT_RESIDE_DATE ,FL_RES_ARCHIVED ,RESIDE_REGISTERED_FL ,FL_SEARCHABLE_RESIDE ,REGISTERER_ID_RE ,RESIDE_AMEND_ACKNOWLEDGE_FL ,NULL ,COALESCE(NULL,'NULL') ,COALESCE(NULL,'NULL') ,OCCUR_REGIS_DATE ,RESIDE_REGIS_DATE ,ST_REGIS_DATE ,DOD ,VRV_REC_REPLACE_NBR ,NULL ,2 DimRegistrarTypeInternalId
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                      
    
		          UNION ALL    
				 

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,COALESCE(2000000 + ST_REGIS_NAME,'0') ,NULL ,ST_REGIS_NUM ,ST_REGIS_DATE ,ST_VOLUME ,ST_PAGE ,ST_DEPOSITION_NUM ,ST_AMENDMENT_DATE ,ST_ARCHVL_COPY_PRINTED_DATE ,FL_RVRS_ARCHIVED ,STATE_REGISTERED_FL ,FL_SEARCHABLE_RVRS ,REGISTERER_ID_ST ,NULL ,ST_PREVIOUS_VOL_PAGE ,COALESCE(ST_VOL_PAGE_ENTRY_TYPE,'NULL') ,COALESCE(ST_VOLUME_TYPE,'NULL') ,OCCUR_REGIS_DATE ,RESIDE_REGIS_DATE ,ST_REGIS_DATE ,DOD ,VRV_REC_REPLACE_NBR ,NULL ,3 DimRegistrarTypeInternalId
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                      
 
	
	       SET @TotalProcessedRecords = @@ROWCOUNT

		   PRINT  @TotalProcessedRecords
			
PRINT '4'  + CONVERT (VARCHAR(50),GETDATE(),109)
			

	 IF @TotalProcessedRecords=0
			BEGIN 
                PRINT '5'  + CONVERT (VARCHAR(50),GETDATE(),109)	
						
				UPDATE  [RVRS].[Execution]
						SET ExecutionStatus='Completed'
						,LastLoadDate=@LastLoadedDate						
						,EndTime=@CurentTime
						,TotalProcessedRecords=0
						,TotalLoadedRecord=0
						,TotalErrorRecord=0
						,TotalPendingReviewRecord=0
						,TotalWarningRecord=0
					WHERE ExecutionId=@ExecutionId
			
					RETURN 
			END
			
				
/*
----------------------------------------------------------------------------------------------------------------------------------------------
4 - Check if there is parent  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
IF (SElECT count(1) from #Tmp_HoldData where PersonId is not null ) = 0
			BEGIN
					UPDATE  [RVRS].[Execution]
					SET ExecutionStatus=@ExecutionStatus
						,LastLoadDate=@LastLoadedDate					
						,EndTime=@CurentTime
						,TotalProcessedRecords=@TotalProcessedRecords
						,TotalLoadedRecord=@TotalLoadedRecord
						,TotalErrorRecord=@TotalErrorRecord
						,TotalPendingReviewRecord=@TotalPendingReviewRecord
						,TotalWarningRecord=@TotalWarningRecord
					WHERE ExecutionId=@ExecutionId
					SET @Err_Message ='We do not have data for '+ CONVERT(VARCHAR(50),@MAXDateinData,106) +'in Person Table'
					RAISERROR (@Err_Message,10,1)			
			END
		
			
SET @MAXDateinData = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)
PRINT  @MAXDateinData
SET @LastLoadedDate = @MAXDateinData

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
5 - Validation checking  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '6'  + CONVERT (VARCHAR(50),GETDATE(),109)	
					
   
		SELECT *
			
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(RegistrationDate,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'RegistrationDate|Error:Not a valid Date of Registration' ELSE '' END AS LoadNote_1
	        ,CASE WHEN Try_Cast(RegistrationDate AS DateTime)<Try_Cast(DOD AS DateTime) THEN 'RegistrationDate|Error:Date of Registration is before Date of Death' ELSE '' END AS LoadNote_2
	        ,CASE WHEN OCCUR_REGIS_DATE IS NULL THEN 'RegistrationDate,OCCUR_REGIS_DATE,|Error:Date of Occurance cannot be blank for registered records' ELSE '' END AS LoadNote_3
	        ,CASE WHEN (Try_Cast(OCCUR_REGIS_DATE AS DateTime)>Try_Cast(RESIDE_REGIS_DATE AS DateTime) 
						OR Try_Cast(OCCUR_REGIS_DATE AS DateTime)>Try_Cast(ST_REGIS_DATE AS DateTime)) AND (VRV_REC_REPLACE_NBR = 0) THEN 'OCCUR_REGIS_DATE,RESIDE_REGIS_DATE,ST_REGIS_DATE,VRV_REC_REPLACE_NBR|Error:Date of Occurance must be first for Version 0' ELSE '' END AS LoadNote_4
	        ,CASE WHEN FL_OCCUR_IS_RESIDE = 'Y' AND RESIDE_REGIS_DATE IS NOT NULL THEN 'FL_OCCUR_IS_RESIDE,RESIDE_REGIS_DATE|Error:When Death occurred in residence the Residence Registration information should be blank' ELSE '' END AS LoadNote_5
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(AmendmentDate,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'AmendmentDate|Error:Not a valid Date of Amendment' ELSE '' END AS LoadNote_6
	        ,CASE WHEN Try_Cast(AmendmentDate AS DateTime)<Try_Cast(RegistrationDate AS DateTime) THEN 'AmendmentDate,RegistrationDate|Error:Date of Amendment is before Date of Registration' ELSE '' END AS LoadNote_7
	        ,CASE WHEN AmendmentDate IS NOT NULL AND VRV_REC_REPLACE_NBR = 0 THEN 'AmendmentDate,VRV_REC_REPLACE_NBR|Error:The version of Record should not be 0 if Date of Amendment is not blank' ELSE '' END AS LoadNote_8
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(ArchivalPrintedDate,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'ArchivalPrintedDate|Error:Not a valid Archival Printed Date' ELSE '' END AS LoadNote_9
	        ,CASE WHEN Try_Cast(ArchivalPrintedDate AS DateTime)<Try_Cast(RegistrationDate AS DateTime) THEN 'ArchivalPrintedDate,RegistrationDate|Error:Archival Printed Date is before Date of Registration ' ELSE '' END AS LoadNote_10
	        ,CASE WHEN ISNULL(FlAcknowledge,'Y') NOT IN ('N','Y') THEN 'FlAcknowledge|Error:Not a valid value for FlAcknowledge' ELSE '' END AS LoadNote_11
	        ,CASE WHEN ISNULL(FlArchived,'Y') NOT IN ('N','Y') THEN 'FlArchived|Error:Not a valid value for FlArchived' ELSE '' END AS LoadNote_12
	        ,CASE WHEN ArchivalPrintedDate IS NOT NULL AND FlArchived<>'Y'  THEN 'FlArchived,ArchivalPrintedDate|Error:If Archival Printed Date is not blank then the value for FlArchived must be Y' ELSE '' END AS LoadNote_13
	        ,CASE WHEN FlRegistered = 'Y' AND OCCUR_REGIS_DATE IS NULL THEN 'FlRegistered,OCCUR_REGIS_DATE|Error:If FlRegistered value is Yes then there must be Occurance Registered Date' ELSE '' END AS LoadNote_14
	        ,CASE WHEN ISNULL(FlRegistered,'Y') NOT IN ('N','Y') THEN 'FlRegistered|Error:Not a valid value for FlRegistered' ELSE '' END AS LoadNote_15
	        ,CASE WHEN ISNULL(FlSearchable,'Y') NOT IN ('N','Y') THEN 'FlSearchable|Error:Not a valid value for FlSearchable' ELSE '' END AS LoadNote_16
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  RegistrationNumber_DC VARCHAR(128),DepositionNumber_DC VARCHAR(128),RegVolume_DC VARCHAR(128),RegPage_DC VARCHAR(128), RegistrationNumber_Flag BIT NOT NULL DEFAULT 0 ,DepositionNumber_Flag BIT NOT NULL DEFAULT 0 ,RegVolume_Flag BIT NOT NULL DEFAULT 0 ,RegPage_Flag BIT NOT NULL DEFAULT 0 ,DeathRegistration_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '') +  IIF( LoadNote_7 <> '',  '||' + LoadNote_7, '') +  IIF( LoadNote_8 <> '',  '||' + LoadNote_8, '') +  IIF( LoadNote_9 <> '',  '||' + LoadNote_9, '') +  IIF( LoadNote_10 <> '',  '||' + LoadNote_10, '') +  IIF( LoadNote_11 <> '',  '||' + LoadNote_11, '') +  IIF( LoadNote_12 <> '',  '||' + LoadNote_12, '') +  IIF( LoadNote_13 <> '',  '||' + LoadNote_13, '') +  IIF( LoadNote_14 <> '',  '||' + LoadNote_14, '') +  IIF( LoadNote_15 <> '',  '||' + LoadNote_15, '') +  IIF( LoadNote_16 <> '',  '||' + LoadNote_16, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathRegistration_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathRegistration_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM DimRegistrar TABLE AND UPDATE THE DimRegistrarId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimRegistrarId INT
		
			UPDATE MT
			SET MT.DimRegistrarId =DS.DimRegistrarId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimRegistrar] DS WITH(NOLOCK) ON DS.BkRegistrarId=MT.RegistrarId

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathRegistration_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN  TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathRegistration_Log_Flag=1
					   , LoadNote = 'RegistrarId|Pending Review:Not a valid RegistrarId' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimRegistrarId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE RegistrationNumber WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathRegistration_RegistrationNumber TABLE*/		
			
  			
			UPDATE MT
				SET 
				RegistrationNumber_DC= DC.Mapping_Current
				,MT.RegistrationNumber_Flag=1
				,MT.LoadNote='RegistrationNumber|Warning:RegistrationNumber got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.RegistrationNumber
			WHERE  DC.TableName='DeathRegistration_RegistrationNumber'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DepositionNumber WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathRegistration_DepositionNumber TABLE*/		
			
  			
			UPDATE MT
				SET 
				DepositionNumber_DC= DC.Mapping_Current
				,MT.DepositionNumber_Flag=1
				,MT.LoadNote='DepositionNumber|Warning:DepositionNumber got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.DepositionNumber
			WHERE  DC.TableName='DeathRegistration_DepositionNumber'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '9' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE Volume WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathRegistration_Volume TABLE*/		
			
  			
			UPDATE MT
				SET 
				RegVolume_DC= DC.Mapping_Current
				,MT.RegVolume_Flag=1
				,MT.LoadNote='RegVolume|Warning:Volume got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.RegVolume
			WHERE  DC.TableName='DeathRegistration_Volume'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '10' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE Page WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathRegistration_Volume TABLE*/		
			
  			
			UPDATE MT
				SET 
				RegPage_DC= DC.Mapping_Current
				,MT.RegPage_Flag=1
				,MT.LoadNote='RegPage|Warning:Page got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.RegPage
			WHERE  DC.TableName='DeathRegistration_Volume'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '11' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM DimPageEntryType TABLE AND UPDATE THE DimPageEntryTypeId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimPageEntryTypeId INT
		
			UPDATE MT
			SET MT.DimPageEntryTypeId =DS.DimPageEntryTypeId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimPageEntryType] DS WITH(NOLOCK) ON DS.Abbr=MT.PageEntryType

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathRegistration_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN  TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathRegistration_Log_Flag=1
					   , LoadNote = 'PageEntryType|Pending Review:Not a valid PageEntryType' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimPageEntryTypeId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimRecordAccess TABLE AND UPDATE THE DimRecordAccessId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimRecordAccessId INT
		
			UPDATE MT
			SET MT.DimRecordAccessId =DS.DimRecordAccessId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimRecordAccess] DS WITH(NOLOCK) ON DS.Abbr=MT.RecordAccess

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathRegistration_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN  TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathRegistration_Log_Flag=1
					   , LoadNote = 'RecordAccess|Pending Review:Not a valid RecordAccess' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimRecordAccessId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathRegistration_Log_Flag=1
					,LoadNote= 'Person|ParentMissing:Validation Errors' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					WHERE PersonId IS NULL
					AND SrId IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))

				SET @RecordCountDebug=@@ROWCOUNT 
				
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 5
				UPDATE #Tmp_HoldData_Final
					SET LoadNote='Person|ParentMissing:Not Processed' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					 WHERE PersonId IS NULL
					  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))
					  AND DeathRegistration_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathRegistration_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
                                 AND DeathRegistration_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathRegistration]
			(
				 [DimRegistrarTypeInternalId],[PersonId],[RegistrationDate],[DimRegistrarId],[RegistrationNumber],[AmendmentDate],[DimRecordAccessId],[RegVolume],[RegPage],[DepositionNumber],[ArchivalPrintedDate],[FlArchived],[FlAcknowledge],[PreviousVolumePage],[DimPageEntryTypeId],[FlRegistered],[SrcRegistererUserId],[FlSearchable]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [DimRegistrarTypeInternalId],[PersonId],[RegistrationDate],[DimRegistrarId], ISNULL([RegistrationNumber_DC],[RegistrationNumber]),[AmendmentDate],[DimRecordAccessId], ISNULL([RegVolume_DC],[RegVolume]), ISNULL([RegPage_DC],[RegPage]), ISNULL([DepositionNumber_DC],[DepositionNumber]),[ArchivalPrintedDate],[FlArchived],[FlAcknowledge],[PreviousVolumePage],[DimPageEntryTypeId],[FlRegistered],[SrcRegistererUserId],[FlSearchable]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathRegistration_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO  [RVRS].[DeathRegistration_Log]
			(
				 SrId, RegistrationNumber_DC ,DepositionNumber_DC ,RegVolume_DC ,RegPage_DC 
				 , [DimRegistrarTypeInternalId],[PersonId],[RegistrationDate],[DimRegistrarId],[RegistrationNumber],[AmendmentDate],[DimRecordAccessId],[RegVolume],[RegPage],[DepositionNumber],[ArchivalPrintedDate],[FlArchived],[FlAcknowledge],[PreviousVolumePage],[DimPageEntryTypeId],[FlRegistered],[SrcRegistererUserId],[FlSearchable]	
				 , RegistrarId,RegistrarName,PageEntryType,RecordAccess,OCCUR_REGIS_DATE,RESIDE_REGIS_DATE,ST_REGIS_DATE,DOD,VRV_REC_REPLACE_NBR,FL_OCCUR_IS_RESIDE
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathRegistration_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , RegistrationNumber_DC ,DepositionNumber_DC ,RegVolume_DC ,RegPage_DC 
				, [DimRegistrarTypeInternalId],[PersonId],[RegistrationDate],[DimRegistrarId],[RegistrationNumber],[AmendmentDate],[DimRecordAccessId],[RegVolume],[RegPage],[DepositionNumber],[ArchivalPrintedDate],[FlArchived],[FlAcknowledge],[PreviousVolumePage],[DimPageEntryTypeId],[FlRegistered],[SrcRegistererUserId],[FlSearchable]
				, RegistrarId,RegistrarName,PageEntryType,RecordAccess,OCCUR_REGIS_DATE,RESIDE_REGIS_DATE,ST_REGIS_DATE,DOD,VRV_REC_REPLACE_NBR,FL_OCCUR_IS_RESIDE
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathRegistration_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathRegistration_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR RegistrationNumber*/

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
			(
				 SrId
				,Entity
				,EntityColumnName
				,EntityId
				,ConvertedColumn
				,OriginalValue
				,ConvertedValue
			)
			SELECT MT.SrId AS SrId
				,'DeathRegistration' AS Entity
				,'DeathRegistrationId' AS EntityColumnName
				,PA.DeathRegistrationId AS EntityId
				,'RegistrationNumber' AS ConvertedColumn
				,MT.RegistrationNumber AS OriginalValue
				,MT.RegistrationNumber_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathRegistration]  PA ON PA.PersonId=MT.PersonId  AND PA.DimRegistrarTypeInternalId=MT.DimRegistrarTypeInternalId	
			WHERE MT.RegistrationNumber_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DepositionNumber*/

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
			(
				 SrId
				,Entity
				,EntityColumnName
				,EntityId
				,ConvertedColumn
				,OriginalValue
				,ConvertedValue
			)
			SELECT MT.SrId AS SrId
				,'DeathRegistration' AS Entity
				,'DeathRegistrationId' AS EntityColumnName
				,PA.DeathRegistrationId AS EntityId
				,'DepositionNumber' AS ConvertedColumn
				,MT.DepositionNumber AS OriginalValue
				,MT.DepositionNumber_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathRegistration]  PA ON PA.PersonId=MT.PersonId  AND PA.DimRegistrarTypeInternalId=MT.DimRegistrarTypeInternalId	
			WHERE MT.DepositionNumber_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR Volume*/

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
			(
				 SrId
				,Entity
				,EntityColumnName
				,EntityId
				,ConvertedColumn
				,OriginalValue
				,ConvertedValue
			)
			SELECT MT.SrId AS SrId
				,'DeathRegistration' AS Entity
				,'DeathRegistrationId' AS EntityColumnName
				,PA.DeathRegistrationId AS EntityId
				,'Volume' AS ConvertedColumn
				,MT.RegVolume AS OriginalValue
				,MT.RegVolume_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathRegistration]  PA ON PA.PersonId=MT.PersonId  AND PA.DimRegistrarTypeInternalId=MT.DimRegistrarTypeInternalId	
			WHERE MT.RegVolume_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR Page*/

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
			(
				 SrId
				,Entity
				,EntityColumnName
				,EntityId
				,ConvertedColumn
				,OriginalValue
				,ConvertedValue
			)
			SELECT MT.SrId AS SrId
				,'DeathRegistration' AS Entity
				,'DeathRegistrationId' AS EntityColumnName
				,PA.DeathRegistrationId AS EntityId
				,'Page' AS ConvertedColumn
				,MT.RegPage AS OriginalValue
				,MT.RegPage_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathRegistration]  PA ON PA.PersonId=MT.PersonId  AND PA.DimRegistrarTypeInternalId=MT.DimRegistrarTypeInternalId	
			WHERE MT.RegPage_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathRegistration_Log_Flag=1
									AND LoadNote LIKE '%|Pending Review%')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'
								AND LoadNote LIKE '%|WARNING%')
	UPDATE  [RVRS].[Execution]
			SET ExecutionStatus=@ExecutionStatus
				,LastLoadDate=@LastLoadDate			
				,EndTime=@CurentTime
				,TotalProcessedRecords=@TotalProcessedRecords
				,TotalLoadedRecord=@TotalLoadedRecord
				,TotalErrorRecord=@TotalErrorRecord
				,TotalPendingReviewRecord=@TotalPendingReviewRecord
				,TotalWarningRecord=@TotalWarningRecord
				,NOTE= @Note 
			WHERE ExecutionId=@ExecutionId

			SET @RecordCountDebug=@@ROWCOUNT

		
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
END TRY
 BEGIN CATCH
		PRINT 'CATCH'
		UPDATE  [RVRS].[Execution]
		SET ExecutionStatus='Failed'
			,LastLoadDate=@LastLoadDate			
			,EndTime=@CurentTime
			,TotalProcessedRecords=@TotalProcessedRecords
			,TotalLoadedRecord=@TotalLoadedRecord
			,TotalErrorRecord=@TotalErrorRecord
			,TotalPendingReviewRecord=@TotalPendingReviewRecord
			,TotalWarningRecord=@TotalWarningRecord
		WHERE ExecutionId=@ExecutionId
		SET @Err_Message=ERROR_MESSAGE()
		RAISERROR (@Err_Message,11,1)
	END CATCH
END

/*
----------------------------------------------------------------------------------------------------------------------------------------------
														END END END
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	


