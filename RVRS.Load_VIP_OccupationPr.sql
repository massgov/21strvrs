 USE RVRS_Testdb


IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_OccupationPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_OccupationPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_OccupationPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_OccupationPr]
AUTHOR	:Foyzur Rahman
CREATED	:Dec 14 2022  
PURPOSE	:TO LOAD DATA INTO FACT Occupation TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Dec 14 2022 		Foyzur Rahman						RVRS 163 : LOAD DECEDENT Occupation DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM RVRS_Testdb.[RVRS].[DeathOriginal] WHERE Entity = 'Occupation'
TRUNCATE TABLE RVRS_Testdb.[RVRS].[Occupation]
DROP TABLE RVRS_Testdb.[RVRS].[Occupation_Log]
DELETE FROM RVRS_Testdb.[RVRS].[Execution] WHERE Entity = 'Occupation'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_OccupationPr]
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
IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData

/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Create log table 
----------------------------------------------------------------------------------------------------------------------------------------------
*/


IF OBJECT_ID('RVRS_Testdb.[RVRS].[Occupation_Log]') IS NULL 
	CREATE TABLE RVRS_Testdb.[RVRS].[Occupation_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), Occupation_DC Varchar(128),Industry_DC Varchar(128), [PersonId] BIGINT,[Industry] VARCHAR(64),[Occupation] VARCHAR(64),[DimNioshIndustryId] INT,[DimNioshOccupationId] INT, OccupCode VARCHAR(128),IndusCode VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),Occupation_Log_Flag BIT ,LoadNote VARCHAR(MAX))

BEGIN TRY

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Set Execution intial status
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '1'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			
INSERT INTO RVRS_Testdb.[RVRS].[Execution] 
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
		SELECT 'Occupation' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM RVRS_Testdb.[RVRS].[Execution] WITH(NOLOCK) WHERE Entity='Occupation' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT  D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,OCCUP Occupation,INDUST Industry,COALESCE(Census_Occ_code,'-2') OccupCode,COALESCE(Census_Ind_code,'-2') IndusCode
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM RVRS_Staging.RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				LEFT JOIN RVRS_Staging.[RVRS].[Data_Conversion_Niosh_Occupation] C ON C.Industry=D.Indust AND C.Occupation=D.Occup				
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
						
				UPDATE RVRS_Testdb.[RVRS].[Execution]
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
					UPDATE RVRS_Testdb.[RVRS].[Execution]
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
6 - Add/Update Flag on #Tmp_HoldData
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData ADD  Occupation_DC Varchar(128),Industry_DC Varchar(128), Occupation_Flag BIT NOT NULL DEFAULT 0 ,Industry_Flag BIT NOT NULL DEFAULT 0 ,Occupation_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	 UPDATE #Tmp_HoldData SET LoadNote = ''
	
	UPDATE #Tmp_HoldData SET Occupation_Log_Flag = 0

	UPDATE #Tmp_HoldData SET Occupation_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM RVRS_Staging.[RVRS].[Data_Conversion] TABLE AND UPDATE THE Occupation WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Occupation_Occupation TABLE*/		
			
  			
			UPDATE MT
				SET 
				Occupation_DC= DC.Mapping_Current
				,MT.Occupation_Flag=1
				,MT.LoadNote='Occupation|Warning:Occupation got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData MT
			JOIN RVRS_Staging.[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.Occupation
			WHERE  DC.TableName='Occupation_Occupation'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '6' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM RVRS_Staging.[RVRS].[Data_Conversion] TABLE AND UPDATE THE Industry WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Occupation_Industry TABLE*/		
			
  			
			UPDATE MT
				SET 
				Industry_DC= DC.Mapping_Current
				,MT.Industry_Flag=1
				,MT.LoadNote='Industry|Warning:Industry got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData MT
			JOIN RVRS_Staging.[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.Industry
			WHERE  DC.TableName='Occupation_Industry'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '7' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM DimNioshOccupation TABLE AND UPDATE THE DimNioshOccupationId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData ADD DimNioshOccupationId Varchar(128)
		
			UPDATE MT
			SET MT.DimNioshOccupationId =DS.DimNioshOccupationId  
			FROM #Tmp_HoldData MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimNioshOccupation] DS WITH(NOLOCK) ON DS.Code=MT.OccupCode

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE Occupation_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS_Staging.[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData 
					SET Occupation_Log_Flag=1
					   , LoadNote = 'OccupCode|Pending Review:Not a valid OccupCode' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimNioshOccupationId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimNioshIndustry TABLE AND UPDATE THE DimNioshIndustryId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData ADD DimNioshIndustryId Varchar(128)
		
			UPDATE MT
			SET MT.DimNioshIndustryId =DS.DimNioshIndustryId  
			FROM #Tmp_HoldData MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimNioshIndustry] DS WITH(NOLOCK) ON DS.Code=MT.IndusCode

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE Occupation_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS_Staging.[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData 
					SET Occupation_Log_Flag=1
					   , LoadNote = 'IndusCode|Pending Review:Not a valid IndusCode' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimNioshIndustryId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData
				SET Occupation_Log_Flag=1
					,LoadNote= 'Person|ParentMissing:Validation Errors' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					WHERE PersonId IS NULL
					AND SrId IN (SELECT SRID FROM RVRS_Staging.RVRS.Person_Log WITH(NOLOCK))

				SET @RecordCountDebug=@@ROWCOUNT 
				
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 5
				UPDATE #Tmp_HoldData
					SET LoadNote='Person|ParentMissing:Not Processed' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					 WHERE PersonId IS NULL
					  AND SrId NOT IN (SELECT SRID FROM RVRS_Staging.RVRS.Person_Log WITH(NOLOCK))
					  AND Occupation_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData                                               
                                 SET Occupation_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM RVRS_Staging.RVRS.Person_Log)
                                 AND Occupation_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
 select * from #Tmp_HoldData 
 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimNioshOccupation] DS WITH(NOLOCK) 
			 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimNioshIndustry] DS WITH(NOLOCK) 
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO RVRS_Testdb.[RVRS].[Occupation]
			(
				 [PersonId],[Industry],[Occupation],[DimNioshIndustryId],[DimNioshOccupationId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId], ISNULL([Industry_DC],[Industry]), ISNULL([Occupation_DC],[Occupation]),[DimNioshIndustryId],[DimNioshOccupationId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData
			WHERE Occupation_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
 select * from RVRS_Testdb.[RVRS].[Occupation]
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO RVRS_Testdb.[RVRS].[Occupation_Log]
			(
				 SrId, Occupation_DC ,Industry_DC 
				 , [PersonId],[Industry],[Occupation],[DimNioshIndustryId],[DimNioshOccupationId]	
				 , OccupCode,IndusCode
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,Occupation_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , Occupation_DC ,Industry_DC 
				, [PersonId],[Industry],[Occupation],[DimNioshIndustryId],[DimNioshOccupationId]
				, OccupCode,IndusCode
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,Occupation_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData
			WHERE Occupation_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
 select * from RVRS_Testdb.[RVRS].[Occupation_Log] 
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR Occupation*/

			INSERT INTO RVRS_Testdb.[RVRS].[DeathOriginal]
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
				,'Occupation' AS Entity
				,'OccupationId' AS EntityColumnName
				,PA.OccupationId AS EntityId
				,'Occupation' AS ConvertedColumn
				,MT.Occupation AS OriginalValue
				,MT.Occupation_DC AS ConvertedValue
			FROM #Tmp_HoldData MT
			JOIN RVRS_Testdb.[RVRS].[Occupation]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.Occupation_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR Industry*/

			INSERT INTO RVRS_Testdb.[RVRS].[DeathOriginal]
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
				,'Occupation' AS Entity
				,'OccupationId' AS EntityColumnName
				,PA.OccupationId AS EntityId
				,'Industry' AS ConvertedColumn
				,MT.Industry AS OriginalValue
				,MT.Industry_DC AS ConvertedValue
			FROM #Tmp_HoldData MT
			JOIN RVRS_Testdb.[RVRS].[Occupation]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.Industry_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
 select * from RVRS_Testdb.[RVRS].[DeathOriginal] WHERE Entity = 'Occupation'
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData WHERE Occupation_Log_Flag=1
									AND LoadNote LIKE '%|Pending Review%')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData WHERE LoadNote NOT LIKE '%|Pending Review%'
								AND LoadNote LIKE '%|WARNING%')
	UPDATE RVRS_Testdb.[RVRS].[Execution]
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
 select * from RVRS_Testdb.[RVRS].[Execution] WHERE Entity= 'Occupation'
END TRY
 BEGIN CATCH
		PRINT 'CATCH'
		UPDATE RVRS_Testdb.[RVRS].[Execution]
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

	


