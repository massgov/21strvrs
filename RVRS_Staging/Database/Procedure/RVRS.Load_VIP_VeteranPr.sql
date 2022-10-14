 USE [RVRS_testdb]

IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_VeteranPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_VeteranPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_VeteranPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_VeteranPr]
AUTHOR	:Sailendra Singh
CREATED	:Oct 14 2022  
PURPOSE	:TO LOAD DATA INTO FACT Veteran TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Oct 14 2022 		Sailendra Singh						RVRS 153 : LOAD DECEDENT Veteran DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'Veteran'
TRUNCATE TABLE [RVRS_testdb].[RVRS].[Veteran]
DROP TABLE [RVRS_testdb].[RVRS].[Veteran_Log]
DELETE FROM [RVRS_testdb].[RVRS].[Execution] WHERE Entity = 'Veteran'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_VeteranPr]
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


IF OBJECT_ID('[RVRS_testdb].[RVRS].[Veteran_Log]') IS NULL 
	CREATE TABLE [RVRS_testdb].[RVRS].[Veteran_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), RankOrgOutFit_DC Varchar(128),ServiceNumber_DC Varchar(128),OtherWar_DC Varchar(128), [PersonId] BIGINT,[Order] TINYINT,[DimWarId] INT,[OtherWar] VARCHAR(128),[DimArmyBranchId] INT,[RankOrgOutFit] VARCHAR(128),[DateEntered] VARCHAR(16),[DateDischarged] VARCHAR(16),[ServiceNumber] VARCHAR(32), War varchar (128),ArmyBranch varchar (128),DOD varchar (128),DOB varchar (128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),Veteran_Log_Flag BIT ,LoadNote VARCHAR(MAX))

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
		SELECT 'Veteran' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS_testdb].[RVRS].[Execution] WITH(NOLOCK) WHERE Entity='Veteran' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT   D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,ISNULL(VET1_WAR,'NULL') War,VET1_WAR_OTHER OtherWar,ISNULL(VET1_BRANCH,'NULL') ArmyBranch,VET1_ORG RankOrgOutFit,VET1_DATE_ENTERED DateEntered,VET1_DATE_DISCHARGED DateDischarged,VETR1_SERVICE_NUM ServiceNumber,DOD_4_FD DOD,DOB DOB,1 [Order]
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
					  
	       
                       AND VET1_WAR IS NOT NULL
    
		          UNION ALL    
				 

		        SELECT   D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,ISNULL(VET2_WAR,'NULL') ,VET2_WAR_OTHER ,ISNULL(VET2_BRANCH,'NULL') ,VET2_ORG ,VET2_DATE_ENTERED ,VET2_DATE_DISCHARGED ,VETR2_SERVICE_NUM ,DOD_4_FD ,DOB ,2 [Order]
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        FROM [RVRS_Staging].RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                       AND VET2_WAR IS NOT NULL
    
		          UNION ALL    
				 

		        SELECT   D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,ISNULL(VET3_WAR,'NULL') ,VET3_WAR_OTHER ,ISNULL(VET3_BRANCH,'NULL') ,VET3_ORG ,VET3_DATE_ENTERED ,VET3_DATE_DISCHARGED ,VETR3_SERVICE_NUM ,DOD_4_FD ,DOB ,3 [Order]
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        FROM [RVRS_Staging].RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                       AND VET3_WAR IS NOT NULL
 
	
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
			
	        ,CASE WHEN DateEntered IS NOT NULL AND ISDATE(DateEntered) = 0 THEN 'DateEntered|Error:Not a valid Entered Date' ELSE '' END AS LoadNote_1
	        ,CASE WHEN DATEDIFF(HOUR,try_Cast (DOB AS DateTime),Try_Cast (DateEntered AS DateTime))/8766<=15 THEN 'DateEntered,DOB|Warning:Not a valid Entered Date with respect to Date of Birth' ELSE '' END AS LoadNote_2
	        ,CASE WHEN  try_Cast (DateEntered AS DateTime)>=Try_Cast (DOD AS DateTime) THEN 'DateEntered,DOD|Error:Not a valid Entered Date with respect to Date of Death' ELSE '' END AS LoadNote_3
	        ,CASE WHEN  try_Cast (DateEntered AS DateTime)>Try_Cast (DateDischarged AS DateTime) THEN 'DateEntered,DateDischarged|Error:Not a valid Discharged Date with respect to Entered Date' ELSE '' END AS LoadNote_4
	        ,CASE WHEN DateDischarged IS NOT NULL AND ISDATE(DateDischarged) = 0 THEN 'DateDischarged|Error:Not a valid Discharged Date' ELSE '' END AS LoadNote_5
	        ,CASE WHEN  try_Cast (DateDischarged AS DateTime)<=Try_Cast (DOB AS DateTime) THEN 'DateDischarged,DOB|Error:Not a valid Discharged Date with respect to Date of Birth' ELSE '' END AS LoadNote_6
	        ,CASE WHEN  try_Cast (DateDischarged AS DateTime)>=Try_Cast (DOD AS DateTime) THEN 'DateDischarged,DOD|Error:Not a valid Discharged Date with respect to Date of Death' ELSE '' END AS LoadNote_7
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  RankOrgOutFit_DC Varchar(128),ServiceNumber_DC Varchar(128),OtherWar_DC Varchar(128), RankOrgOutFit_Flag BIT NOT NULL DEFAULT 0 ,ServiceNumber_Flag BIT NOT NULL DEFAULT 0 ,OtherWar_Flag BIT NOT NULL DEFAULT 0 ,Veteran_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '') +  IIF( LoadNote_7 <> '',  '||' + LoadNote_7, '')
	
	UPDATE #Tmp_HoldData_Final SET Veteran_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET Veteran_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM DimWar TABLE AND UPDATE THE DimWarId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimWarId INT
		
			UPDATE MT
			SET MT.DimWarId =DS.DimWarId 
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimWar] DS WITH(NOLOCK) ON DS.WarDesc=MT.War

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE Veteran_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS_Staging].[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET Veteran_Log_Flag=1
					   , LoadNote = 'War|Pending Review:Not a valid War' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimWarId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimArmyBranch TABLE AND UPDATE THE DimArmyBranchId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimArmyBranchId INT
		
			UPDATE MT
			SET MT.DimArmyBranchId =DS.DimArmyBranchId 
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimArmyBranch] DS WITH(NOLOCK) ON DS.ArmyBranchDesc=MT.ArmyBranch

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE Veteran_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS_Staging].[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET Veteran_Log_Flag=1
					   , LoadNote = 'ArmyBranch|Pending Review:Not a valid ArmyBranch' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimArmyBranchId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE RankOrgOutFit WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Veteran_RankOrgOutFit TABLE*/		
			
  			
			UPDATE MT
				SET 
				RankOrgOutFit_DC= DC.Mapping_Current
				,MT.RankOrgOutFit_Flag=1
				,MT.LoadNote='RankOrgOutFit|Warning:RankOrgOutFit got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.RankOrgOutFit
			WHERE  DC.TableName='Veteran_RankOrgOutFit'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE ServiceNumber WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Veteran_ServiceNumber TABLE*/		
			
  			
			UPDATE MT
				SET 
				ServiceNumber_DC= DC.Mapping_Current
				,MT.ServiceNumber_Flag=1
				,MT.LoadNote='ServiceNumber|Warning:ServiceNumber got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.ServiceNumber
			WHERE  DC.TableName='Veteran_ServiceNumber'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '9' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE OtherWar WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Veteran_OtherWar TABLE*/		
			
  			
			UPDATE MT
				SET 
				OtherWar_DC= DC.Mapping_Current
				,MT.OtherWar_Flag=1
				,MT.LoadNote='OtherWar|Warning:OtherWar got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.OtherWar
			WHERE  DC.TableName='Veteran_OtherWar'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '10' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET Veteran_Log_Flag=1
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
					  AND Veteran_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET Veteran_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log)
                                 AND Veteran_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
 select * from #Tmp_HoldData_Final 
 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimWar] DS WITH(NOLOCK) 
			 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimArmyBranch] DS WITH(NOLOCK) 
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_testdb].[RVRS].[Veteran]
			(
				 [PersonId],[Order],[DimWarId],[OtherWar],[DimArmyBranchId],[RankOrgOutFit],[DateEntered],[DateDischarged],[ServiceNumber]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[Order],[DimWarId], ISNULL([OtherWar_DC],[OtherWar]),[DimArmyBranchId], ISNULL([RankOrgOutFit_DC],[RankOrgOutFit]),[DateEntered],[DateDischarged], ISNULL([ServiceNumber_DC],[ServiceNumber])
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE Veteran_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[Veteran]
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS_testdb].[RVRS].[Veteran_Log]
			(
				 SrId, RankOrgOutFit_DC ,ServiceNumber_DC ,OtherWar_DC 
				 , [PersonId],[Order],[DimWarId],[OtherWar],[DimArmyBranchId],[RankOrgOutFit],[DateEntered],[DateDischarged],[ServiceNumber]	
				 , War,ArmyBranch,DOD,DOB
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,Veteran_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , RankOrgOutFit_DC ,ServiceNumber_DC ,OtherWar_DC 
				, [PersonId],[Order],[DimWarId],[OtherWar],[DimArmyBranchId],[RankOrgOutFit],[DateEntered],[DateDischarged],[ServiceNumber]
				, War,ArmyBranch,DOD,DOB
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,Veteran_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE Veteran_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[Veteran_Log] 
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR RankOrgOutFit*/

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
				,'Veteran' AS Entity
				,'VeteranId' AS EntityColumnName
				,PA.VeteranId AS EntityId
				,'RankOrgOutFit' AS ConvertedColumn
				,MT.RankOrgOutFit AS OriginalValue
				,MT.RankOrgOutFit_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[Veteran]  PA ON PA.PersonId=MT.PersonId  AND PA.[Order]=MT.[Order]	
			WHERE MT.RankOrgOutFit_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR ServiceNumber*/

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
				,'Veteran' AS Entity
				,'VeteranId' AS EntityColumnName
				,PA.VeteranId AS EntityId
				,'ServiceNumber' AS ConvertedColumn
				,MT.ServiceNumber AS OriginalValue
				,MT.ServiceNumber_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[Veteran]  PA ON PA.PersonId=MT.PersonId  AND PA.[Order]=MT.[Order]	
			WHERE MT.ServiceNumber_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR OtherWar*/

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
				,'Veteran' AS Entity
				,'VeteranId' AS EntityColumnName
				,PA.VeteranId AS EntityId
				,'OtherWar' AS ConvertedColumn
				,MT.OtherWar AS OriginalValue
				,MT.OtherWar_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[Veteran]  PA ON PA.PersonId=MT.PersonId  AND PA.[Order]=MT.[Order]	
			WHERE MT.OtherWar_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'Veteran'
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE Veteran_Log_Flag=1
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
 select * from [RVRS_testdb].[RVRS].[Execution] WHERE Entity= 'Veteran'
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

	


