 USE [RVRS_testdb]


IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathFuneralHomePr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathFuneralHomePr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathFuneralHomePr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathFuneralHomePr]
AUTHOR	:Sailendra Singh
CREATED	:Jun 14 2023  
PURPOSE	:TO LOAD DATA INTO FACT DeathFuneralHome TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Jun 14 2023 		Sailendra Singh						RVRS 174 : LOAD DECEDENT DeathFuneralHome DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'DeathFuneralHome'
TRUNCATE TABLE [RVRS_testdb].[RVRS].[DeathFuneralHome]
DROP TABLE [RVRS_testdb].[RVRS].[DeathFuneralHome_Log]
DELETE FROM [RVRS_testdb].[RVRS].[Execution] WHERE Entity = 'DeathFuneralHome'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathFuneralHomePr]
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


IF OBJECT_ID('[RVRS_testdb].[RVRS].[DeathFuneralHome_Log]') IS NULL 
	CREATE TABLE [RVRS_testdb].[RVRS].[DeathFuneralHome_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), FuneralHomeName_DC VARCHAR(128), [PersonId] BIGINT,[DimFuneralHomeNameId] INT,[DimFuneralHomeTypeInternalId] INT, FuneralHomeName VARCHAR(128),FNRL_SERVICE_OOS VARCHAR(128),TRADE_FH_UNLISTED VARCHAR(128),FL_FUNERAL_HOME_UNLISTED VARCHAR(128),FNRL_NME VARCHAR(128),FH_NAME VARCHAR(128),FH_RESPONSIBLE_NAME VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathFuneralHome_Log_Flag BIT ,LoadNote VARCHAR(MAX))

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
		SELECT 'DeathFuneralHome' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS_testdb].[RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathFuneralHome' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,COALESCE(FNRL_NME,'NULL') FuneralHomeName,FNRL_SERVICE_OOS FNRL_SERVICE_OOS,TRADE_FH_UNLISTED TRADE_FH_UNLISTED,FL_FUNERAL_HOME_UNLISTED FL_FUNERAL_HOME_UNLISTED,FNRL_NME FNRL_NME,FH_NAME FH_NAME,FH_RESPONSIBLE_NAME FH_RESPONSIBLE_NAME,1 DimFuneralHomeTypeInternalId
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM [RVRS_Staging].RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				LEFT JOIN [RVRS_STAGING].[RVRS].[VIP_VT_Funeral_Home_CD] F ON D.VRV_FUNERAL_HOME_LOC_ID = F.FH_LOCATION
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                      
    
		          UNION ALL    
				 

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,COALESCE(FH_RESPONSIBLE_NAME,'NULL') ,FNRL_SERVICE_OOS ,TRADE_FH_UNLISTED ,FL_FUNERAL_HOME_UNLISTED ,FNRL_NME ,COALESCE(FH_NAME,'NULL') ,FH_RESPONSIBLE_NAME ,2 DimFuneralHomeTypeInternalId
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        FROM [RVRS_Staging].RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				LEFT JOIN [RVRS_STAGING].[RVRS].[VIP_VT_Funeral_Home_CD] F ON D.VRV_FUNERAL_HOME_LOC_ID = F.FH_LOCATION
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
                       AND FNRL_SERVICE_OOS ='Y'
 
	
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
			
	        ,CASE WHEN DimFuneralHomeTypeInternalId =2 AND FNRL_SERVICE_OOS = 'Y' and COALESCE(FH_RESPONSIBLE_NAME,'')=COALESCE(FNRL_NME,'') THEN 'DimFuneralHomeTypeInternalId,FNRL_SERVICE_OOS,RESPONSIBE_NAME,FNRL_NME|Error:Funeral Home and Responsible Funeral Home names are same for Trade Service Call' ELSE '' END AS LoadNote_1
	        ,CASE WHEN DimFuneralHomeTypeInternalId =1 AND FNRL_SERVICE_OOS = 'N' and COALESCE(FH_RESPONSIBLE_NAME,'')<>COALESCE(FNRL_NME,'') THEN 'DimFuneralHomeTypeInternalId,FNRL_SERVICE_OOS,RESPONSIBE_NAME,FNRL_NME|Error:Funeral Home and Responsible Funeral Home names are different for Non-Trade Service Call' ELSE '' END AS LoadNote_2
	        ,CASE WHEN DimFuneralHomeTypeInternalId =1 AND (TRADE_FH_UNLISTED =  'N' OR FL_FUNERAL_HOME_UNLISTED = 'N') AND FNRL_NME<>FH_NAME THEN 'DimFuneralHomeTypeInternalId,TRADE_FH_UNLISTED,FL_FUNERAL_HOME_UNLISTED,FNRL_NME,VIP_VT_FUNERAL_HOME_CD.FH_NAME|Warning:The Name of the Funeral Home does not match the Name from Code table' ELSE '' END AS LoadNote_3
	        ,CASE WHEN DimFuneralHomeTypeInternalId =1 AND FNRL_NME IS NULL THEN 'DimFuneralHomeTypeInternalId,FNRL_NME|Error:Missing Funeral Home Name' ELSE '' END AS LoadNote_4
	        ,CASE WHEN DimFuneralHomeTypeInternalId =2 AND FH_RESPONSIBLE_NAME IS NULL THEN 'DimFuneralHomeTypeInternalId,FH_RESPONSIBLE_NAME|Error:Missing Responsible Funeral Home Name for Trade Service' ELSE '' END AS LoadNote_5
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  FuneralHomeName_DC VARCHAR(128), FuneralHomeName_Flag BIT NOT NULL DEFAULT 0 ,DeathFuneralHome_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathFuneralHome_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathFuneralHome_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM DimFuneralHomeName TABLE AND UPDATE THE DimFuneralHomeNameId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimFuneralHomeNameId INT
		
			UPDATE MT
			SET MT.DimFuneralHomeNameId =DS.DimFuneralHomeNameId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimFuneralHomeName] DS WITH(NOLOCK) ON DS.FuneralHomeNameDesc=MT.FuneralHomeName

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimFuneralHomeNameId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimFuneralHomeName TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimFuneralHomeNameId=DC.Mapping_Current_ID,
				FuneralHomeName_DC= DC.Mapping_Current
				,MT.FuneralHomeName_Flag=1
				,MT.LoadNote='FuneralHomeName|Warning:DimFuneralHomeNameId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.FuneralHomeName
			WHERE  DC.TableName='DimFuneralHomeName'
				AND MT.DimFuneralHomeNameId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathFuneralHome_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathFuneralHome_Log_Flag=1
					   , LoadNote = 'FuneralHomeName|Pending Review:Not a valid FuneralHomeName' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimFuneralHomeNameId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathFuneralHome_Log_Flag=1
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
					  AND DeathFuneralHome_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathFuneralHome_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log)
                                 AND DeathFuneralHome_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
 select * from #Tmp_HoldData_Final 
 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimFuneralHomeName] DS WITH(NOLOCK) 
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_testdb].[RVRS].[DeathFuneralHome]
			(
				 [PersonId],[DimFuneralHomeNameId],[DimFuneralHomeTypeInternalId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[DimFuneralHomeNameId],[DimFuneralHomeTypeInternalId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathFuneralHome_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathFuneralHome]
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS_testdb].[RVRS].[DeathFuneralHome_Log]
			(
				 SrId, FuneralHomeName_DC 
				 , [PersonId],[DimFuneralHomeNameId],[DimFuneralHomeTypeInternalId]	
				 , FuneralHomeName,FNRL_SERVICE_OOS,TRADE_FH_UNLISTED,FL_FUNERAL_HOME_UNLISTED,FNRL_NME,FH_NAME,FH_RESPONSIBLE_NAME
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathFuneralHome_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , FuneralHomeName_DC 
				, [PersonId],[DimFuneralHomeNameId],[DimFuneralHomeTypeInternalId]
				, FuneralHomeName,FNRL_SERVICE_OOS,TRADE_FH_UNLISTED,FL_FUNERAL_HOME_UNLISTED,FNRL_NME,FH_NAME,FH_RESPONSIBLE_NAME
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathFuneralHome_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathFuneralHome_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathFuneralHome_Log] 
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimFuneralHomeNameId*/

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
				,'DeathFuneralHome' AS Entity
				,'DeathFuneralHomeId' AS EntityColumnName
				,PA.DeathFuneralHomeId AS EntityId
				,'DimFuneralHomeNameId' AS ConvertedColumn
				,MT.FuneralHomeName AS OriginalValue
				,MT.FuneralHomeName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[DeathFuneralHome]  PA ON PA.PersonId=MT.PersonId  AND PA.DimFuneralHomeTypeInternalId=MT.DimFuneralHomeTypeInternalId	
			WHERE MT.FuneralHomeName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'DeathFuneralHome'
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathFuneralHome_Log_Flag=1
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
 select * from [RVRS_testdb].[RVRS].[Execution] WHERE Entity= 'DeathFuneralHome'
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

	


