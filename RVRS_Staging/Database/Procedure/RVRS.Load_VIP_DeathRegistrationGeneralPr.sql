 USE [RVRS_testdb]


IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathRegistrationGeneralPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathRegistrationGeneralPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathRegistrationGeneralPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathRegistrationGeneralPr]
AUTHOR	:Sailendra Singh
CREATED	:Jan 24 2023  
PURPOSE	:TO LOAD DATA INTO FACT DeathRegistrationGeneral TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Jan 24 2023 		Sailendra Singh						RVRS 174 : LOAD DECEDENT DeathRegistrationGeneral DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'DeathRegistrationGeneral'
TRUNCATE TABLE [RVRS_testdb].[RVRS].[DeathRegistrationGeneral]
DROP TABLE [RVRS_testdb].[RVRS].[DeathRegistrationGeneral_Log]
DELETE FROM [RVRS_testdb].[RVRS].[Execution] WHERE Entity = 'DeathRegistrationGeneral'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathRegistrationGeneralPr]
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


IF OBJECT_ID('[RVRS_testdb].[RVRS].[DeathRegistrationGeneral_Log]') IS NULL 
	CREATE TABLE [RVRS_testdb].[RVRS].[DeathRegistrationGeneral_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), RegistrationNumber_DC VARCHAR(128), [PersonId] BIGINT,[RegistrarName] VARCHAR(64),[RegistrationNumber] VARCHAR(32),[RegistrationDate] VARCHAR(16),[AmendmentDate] VARCHAR(16),[DimRecordAccessId] INT,[RecordOwner] CHAR(2),[ScrRegistererUserId] INT,[FlRegistered] VARCHAR(16),[FlUpdatePending] VARCHAR(4),[FlAmendmentInProcess] VARCHAR(4),[FlDelayed] VARCHAR(4),[FlAmended] VARCHAR(16),[DimRegistrationStatusId] INT, RecordAccessId VARCHAR(128),RegistrationStatusId VARCHAR(128),VRV_REC_REPLACE_NBR VARCHAR(128),OCCUR_REGIS_DATE VARCHAR(128),OCCUR_REGIS_NAMEL VARCHAR(128),OCCUR_REGIS_NUM VARCHAR(128),DOD VARCHAR(128),ST_REGIS_DATE VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathRegistrationGeneral_Log_Flag BIT ,LoadNote VARCHAR(MAX))

BEGIN TRY

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Set Execution intial status
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '1'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			
INSERT INTO [RVRS_testdb].[RVRS].[Execution] 
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
		SELECT 'DeathRegistrationGeneral' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS_testdb].[RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathRegistrationGeneral' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,RECORD_REGIS_DATE RegistrationDate,COALESCE(RECORD_REGISTRAR,'NULL') RegistrarName,RECORD_REGIS_NUM RegistrationNumber,DATE_OF_AMENDMENT AmendmentDate,COALESCE(IND_ACCESS_STATUS,'NULL') RecordAccessId,FL_UPDATE_PENDING FlUpdatePending,AMEND_IN_PROCESS FlAmendmentInProcess,VRV_REGISTERED_FLAG FlRegistered,IND_RECORD_OWNER RecordOwner,RECORD_REGISTRAR_ID ScrRegistererUserId,FL_DELAYED FlDelayed,FL_AMENDED FlAmended,COALESCE(IND_REGIS_STATUS,'NULL') RegistrationStatusId,VRV_REC_REPLACE_NBR VRV_REC_REPLACE_NBR,OCCUR_REGIS_DATE OCCUR_REGIS_DATE,OCCUR_REGIS_NAMEL OCCUR_REGIS_NAMEL,OCCUR_REGIS_NUM OCCUR_REGIS_NUM,DOD DOD,ST_REGIS_DATE ST_REGIS_DATE
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM [RVRS_Staging].RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
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
			
 select * from #Tmp_HoldData 
PRINT '4'  + CONVERT (VARCHAR(50),GETDATE(),109)
			

	 IF @TotalProcessedRecords=0
			BEGIN 
                PRINT '5'  + CONVERT (VARCHAR(50),GETDATE(),109)	
						
				UPDATE [RVRS_testdb].[RVRS].[Execution]
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
					UPDATE [RVRS_testdb].[RVRS].[Execution]
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
	        ,CASE WHEN VRV_REC_REPLACE_NBR = 0 AND OCCUR_REGIS_DATE<>RegistrationDate THEN 'RegistrationDate,VRV_REC_REPLACE_NBR,OCCUR_REGIS_DATE|Error:The Occurance Date and Registration date must be same for Version 0 ' ELSE '' END AS LoadNote_3
	        ,CASE WHEN VRV_REC_REPLACE_NBR = 0 AND RegistrarName<>OCCUR_REGIS_NAMEL THEN 'RegistrarName,OCCUR_REGIS_NAMEL|Error:The Occurance Registrar Name and Registration date must be same for Version 0' ELSE '' END AS LoadNote_4
	        ,CASE WHEN VRV_REC_REPLACE_NBR = 0 AND RegistrationNumber<>OCCUR_REGIS_NUM THEN 'RegistrationNumber,OCCUR_REGIS_NUM|Error:The Registration Number and Occurance Registrar Number must be same for Version 0 Record' ELSE '' END AS LoadNote_5
	        ,CASE WHEN RegistrationNumber IS NULL THEN 'RegistrationNumber|Error:There must be Registration Number for Registered records' ELSE '' END AS LoadNote_6
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(AmendmentDate,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'AmendmentDate|Error:Not a valid Date of Amendment' ELSE '' END AS LoadNote_7
	        ,CASE WHEN Try_Cast(AmendmentDate AS DateTime)<Try_Cast(RegistrationDate AS DateTime) THEN 'AmendmentDate,RegistrationDate|Error:Date of Amendment is before Date of Registration' ELSE '' END AS LoadNote_8
	        ,CASE WHEN AmendmentDate IS NOT NULL AND VRV_REC_REPLACE_NBR = 0 THEN 'AmendmentDate,VRV_REC_REPLACE_NBR|Error:The version of Record should not be 0 if Date of Amendment is not blank' ELSE '' END AS LoadNote_9
	        ,CASE WHEN FlUpdatePending NOT IN ('N','Y') THEN 'FlUpdatePending|Error:Not a valid value for FlUpdatePending' ELSE '' END AS LoadNote_10
	        ,CASE WHEN FlAmendmentInProcess NOT IN ('N','Y') THEN 'FlAmendmentInProcess|Error:Not a valid value for FlAmendmentInProcess' ELSE '' END AS LoadNote_11
	        ,CASE WHEN FlAmendmentInProcess = 'Y' AND VRV_REC_REPLACE_NBR = 0 THEN 'FlAmendmentInProcess VRV_REC_REPLACE_NBR|Error:Not a valid value for FlAmendmentInProcess with respect to Amendment Version' ELSE '' END AS LoadNote_12
	        ,CASE WHEN FlRegistered <> 1 THEN 'FlRegistered|Error:Not a valid value for FlRegistered' ELSE '' END AS LoadNote_13
	        ,CASE WHEN OCCUR_REGIS_DATE IS NULL AND FlRegistered = 1  THEN 'FlRegistered,OCCUR_REGIS_DATE|Error:When a record is registered then the Occurance information must be entered as well ' ELSE '' END AS LoadNote_14
	        ,CASE WHEN RecordOwner IS NULL THEN 'RecordOwner|Error:Record Owner should not be blank for registered records' ELSE '' END AS LoadNote_15
	        ,CASE WHEN ISNULL(RecordOwner,'RV') NOT IN ('RV','OC') THEN 'RecordOwner|Error:Not a valid value for Record Owner' ELSE '' END AS LoadNote_16
	        ,CASE WHEN RecordOwner = 'OC' AND OCCUR_REGIS_DATE<>RegistrationDate THEN 'RecordOwner,OCCUR_REGIS_DATE,RegistrationDate|Error:If the Record Owner is Occurance then Registration Date should match with Occurance Date' ELSE '' END AS LoadNote_17
	        ,CASE WHEN RecordOwner = 'RV' AND ST_REGIS_DATE<>RegistrationDate THEN 'RecordOwner,ST_REGIS_DATE,RegistrationDate|Error:If the Record Owner is the State then Registration Date should match with State Registration Date' ELSE '' END AS LoadNote_18
	        ,CASE WHEN ScrRegistererUserId IS NULL THEN 'ScrRegistererUserId|Error:ScrRegistererUserId should not be blank for registered records' ELSE '' END AS LoadNote_19
	        ,CASE WHEN ISNULL(FlDelayed,'Y') NOT IN ('N','Y') THEN 'FlDelayed|Error:Not a valid value for FlUpdatePending' ELSE '' END AS LoadNote_20
	        ,CASE WHEN ISNULL(FlAmended,1) NOT IN (0,1) THEN 'FlAmended|Error:Not a valid value for FlAmended' ELSE '' END AS LoadNote_21
	        ,CASE WHEN (FlAmended= 1 AND VRV_REC_REPLACE_NBR = 0) OR (FlAmended = 0  AND VRV_REC_REPLACE_NBR <> 0) THEN 'FlAmended,VRV_REC_REPLACE_NBR|Error:Not a valid value for FlAmended for its version' ELSE '' END AS LoadNote_22
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  RegistrationNumber_DC VARCHAR(128), RegistrationNumber_Flag BIT NOT NULL DEFAULT 0 ,DeathRegistrationGeneral_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '') +  IIF( LoadNote_7 <> '',  '||' + LoadNote_7, '') +  IIF( LoadNote_8 <> '',  '||' + LoadNote_8, '') +  IIF( LoadNote_9 <> '',  '||' + LoadNote_9, '') +  IIF( LoadNote_10 <> '',  '||' + LoadNote_10, '') +  IIF( LoadNote_11 <> '',  '||' + LoadNote_11, '') +  IIF( LoadNote_12 <> '',  '||' + LoadNote_12, '') +  IIF( LoadNote_13 <> '',  '||' + LoadNote_13, '') +  IIF( LoadNote_14 <> '',  '||' + LoadNote_14, '') +  IIF( LoadNote_15 <> '',  '||' + LoadNote_15, '') +  IIF( LoadNote_16 <> '',  '||' + LoadNote_16, '') +  IIF( LoadNote_17 <> '',  '||' + LoadNote_17, '') +  IIF( LoadNote_18 <> '',  '||' + LoadNote_18, '') +  IIF( LoadNote_19 <> '',  '||' + LoadNote_19, '') +  IIF( LoadNote_20 <> '',  '||' + LoadNote_20, '') +  IIF( LoadNote_21 <> '',  '||' + LoadNote_21, '') +  IIF( LoadNote_22 <> '',  '||' + LoadNote_22, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathRegistrationGeneral_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathRegistrationGeneral_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE RegistrationNumber WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathRegistrationGeneral_RegistrationNumber TABLE*/		
			
  			
			UPDATE MT
				SET 
				RegistrationNumber_DC= DC.Mapping_Current
				,MT.RegistrationNumber_Flag=1
				,MT.LoadNote='RegistrationNumber|Warning:RegistrationNumber got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.RegistrationNumber
			WHERE  DC.TableName='DeathRegistrationGeneral_RegistrationNumber'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM DimRegistrationStatus TABLE AND UPDATE THE DimRegistrationStatusId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimRegistrationStatusId INT
		
			UPDATE MT
			SET MT.DimRegistrationStatusId =DS.DimRegistrationStatusId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimRegistrationStatus] DS WITH(NOLOCK) ON DS.RegistrationStatusDesc=MT.RegistrationStatusId

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathRegistrationGeneral_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN  TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathRegistrationGeneral_Log_Flag=1
					   , LoadNote = 'RegistrationStatusId|Pending Review:Not a valid RegistrationStatusId' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimRegistrationStatusId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimRecordAccess TABLE AND UPDATE THE DimRecordAccessId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimRecordAccessId INT
		
			UPDATE MT
			SET MT.DimRecordAccessId =DS.DimRecordAccessId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimRecordAccess] DS WITH(NOLOCK) ON DS.Abbr=MT.RecordAccessId

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathRegistrationGeneral_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN  TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathRegistrationGeneral_Log_Flag=1
					   , LoadNote = 'RecordAccessId|Pending Review:Not a valid RecordAccessId' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
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
				SET DeathRegistrationGeneral_Log_Flag=1
					,LoadNote= 'Person|ParentMissing:Validation Errors' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					WHERE PersonId IS NULL
					AND SrId IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log WITH(NOLOCK))

				SET @RecordCountDebug=@@ROWCOUNT 
				
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 5
				UPDATE #Tmp_HoldData_Final
					SET LoadNote='Person|ParentMissing:Not Processed' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					 WHERE PersonId IS NULL
					  AND SrId NOT IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log WITH(NOLOCK))
					  AND DeathRegistrationGeneral_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathRegistrationGeneral_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log)
                                 AND DeathRegistrationGeneral_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
 select * from #Tmp_HoldData_Final 
 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimRegistrationStatus] DS WITH(NOLOCK) 
			 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimRecordAccess] DS WITH(NOLOCK) 
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_testdb].[RVRS].[DeathRegistrationGeneral]
			(
				 [PersonId],[RegistrarName],[RegistrationNumber],[RegistrationDate],[AmendmentDate],[DimRecordAccessId],[RecordOwner],[ScrRegistererUserId],[FlRegistered],[FlUpdatePending],[FlAmendmentInProcess],[FlDelayed],[FlAmended],[DimRegistrationStatusId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[RegistrarName], ISNULL([RegistrationNumber_DC],[RegistrationNumber]),[RegistrationDate],[AmendmentDate],[DimRecordAccessId],[RecordOwner],[ScrRegistererUserId],[FlRegistered],[FlUpdatePending],[FlAmendmentInProcess],[FlDelayed],[FlAmended],[DimRegistrationStatusId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathRegistrationGeneral_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathRegistrationGeneral]
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS_testdb].[RVRS].[DeathRegistrationGeneral_Log]
			(
				 SrId, RegistrationNumber_DC 
				 , [PersonId],[RegistrarName],[RegistrationNumber],[RegistrationDate],[AmendmentDate],[DimRecordAccessId],[RecordOwner],[ScrRegistererUserId],[FlRegistered],[FlUpdatePending],[FlAmendmentInProcess],[FlDelayed],[FlAmended],[DimRegistrationStatusId]	
				 , RecordAccessId,RegistrationStatusId,VRV_REC_REPLACE_NBR,OCCUR_REGIS_DATE,OCCUR_REGIS_NAMEL,OCCUR_REGIS_NUM,DOD,ST_REGIS_DATE
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathRegistrationGeneral_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , RegistrationNumber_DC 
				, [PersonId],[RegistrarName],[RegistrationNumber],[RegistrationDate],[AmendmentDate],[DimRecordAccessId],[RecordOwner],[ScrRegistererUserId],[FlRegistered],[FlUpdatePending],[FlAmendmentInProcess],[FlDelayed],[FlAmended],[DimRegistrationStatusId]
				, RecordAccessId,RegistrationStatusId,VRV_REC_REPLACE_NBR,OCCUR_REGIS_DATE,OCCUR_REGIS_NAMEL,OCCUR_REGIS_NUM,DOD,ST_REGIS_DATE
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathRegistrationGeneral_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathRegistrationGeneral_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathRegistrationGeneral_Log] 
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR RegistrationNumber*/

			INSERT INTO [RVRS_testdb].[RVRS].[DeathOriginal]
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
				,'DeathRegistrationGeneral' AS Entity
				,'DeathRegistrationGeneralId' AS EntityColumnName
				,PA.DeathRegistrationGeneralId AS EntityId
				,'RegistrationNumber' AS ConvertedColumn
				,MT.RegistrationNumber AS OriginalValue
				,MT.RegistrationNumber_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[DeathRegistrationGeneral]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.RegistrationNumber_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'DeathRegistrationGeneral'
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathRegistrationGeneral_Log_Flag=1
									AND LoadNote LIKE '%|Pending Review%')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'
								AND LoadNote LIKE '%|WARNING%')
	UPDATE [RVRS_testdb].[RVRS].[Execution]
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
 select * from [RVRS_testdb].[RVRS].[Execution] WHERE Entity= 'DeathRegistrationGeneral'
END TRY
 BEGIN CATCH
		PRINT 'CATCH'
		UPDATE [RVRS_testdb].[RVRS].[Execution]
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

	

