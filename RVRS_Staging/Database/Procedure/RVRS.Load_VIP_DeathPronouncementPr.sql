use RVRS_Staging

IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathPronouncementPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathPronouncementPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathPronouncementPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathPronouncementPr]
AUTHOR	:Rashmi Nagaraj
CREATED	:Jan 25 2023  
PURPOSE	:TO LOAD DATA INTO FACT DeathPronouncement TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Jan 25 2023 		Rashmi Nagaraj						RVRS TBD : LOAD DECEDENT DeathPronouncement DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal] WHERE Entity = 'DeathPronouncement'
TRUNCATE TABLE [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathPronouncement]
DROP TABLE [RVRS].[DeathPronouncement_Log]
DELETE FROM [RVRS].[Execution] WHERE Entity = 'DeathPronouncement'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathPronouncementPr]
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


IF OBJECT_ID('[RVRS].[DeathPronouncement_Log]') IS NULL 
	CREATE TABLE [RVRS].[DeathPronouncement_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), [PersonId] BIGINT,[PronouncedYear] VARCHAR(16),[PronouncedMonth] VARCHAR(16),[PronouncedDay] VARCHAR(16),[PronouncedHour] VARCHAR(16),[PronouncedMinute] VARCHAR(16),[DimPronouncedTimeIndId] INT, PRO_DATE VARCHAR(128),PRO_TIME VARCHAR(128),PronouncedTimeInd VARCHAR(128),FL_PRONOUNCEMENT_EXISTS VARCHAR(128),DOD VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathPronouncement_Log_Flag BIT ,LoadNote VARCHAR(MAX))

BEGIN TRY

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Set Execution intial status
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '1'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			
INSERT INTO [RVRS].[Execution] 
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
		SELECT 'DeathPronouncement' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathPronouncement' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT   D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,PRO_DATE PRO_DATE,RIGHT(PRO_DATE,4) PronouncedYear,LEFT(PRO_DATE,2) PronouncedMonth,SUBSTRING(PRO_DATE,4,2) PronouncedDay,PRO_TIME PRO_TIME,LEFT(PRO_TIME,2) PronouncedHour,RIGHT(PRO_TIME,2) PronouncedMinute,COALESCE(PRO_TIME_IN,'NULL') PronouncedTimeInd,FL_PRONOUNCEMENT_EXISTS FL_PRONOUNCEMENT_EXISTS,DOD DOD
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
					  AND (D.PRO_DATE IS NOT NULL OR D.PRO_TIME IS NOT NULL)
					  
	       
 
	
	       SET @TotalProcessedRecords = @@ROWCOUNT

		   PRINT  @TotalProcessedRecords
			
PRINT '4'  + CONVERT (VARCHAR(50),GETDATE(),109)
			

	 IF @TotalProcessedRecords=0
			BEGIN 
                PRINT '5'  + CONVERT (VARCHAR(50),GETDATE(),109)	
						
				UPDATE [RVRS].[Execution]
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
					UPDATE [RVRS].[Execution]
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
			
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(PRO_DATE,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'PRO_DATE|Error:Not a valid Date of Pronouncement' ELSE '' END AS LoadNote_1
	        ,CASE WHEN Try_Cast(PRO_DATE AS DateTime)>GETDATE() OR Try_Cast(PRO_DATE AS DateTime)< '01/01/2014'  THEN 'PRO_DATE|Error:Date of Pronouncement is greater than Current Date Or less than 2014' ELSE '' END AS LoadNote_2
	        ,CASE WHEN PRO_DATE NOT LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'PRO_DATE|Error:Date of Pronouncement is not in valid format' ELSE '' END AS LoadNote_3
	        ,CASE WHEN TRY_CAST (DOD AS DateTime)<TRY_CAST(DOD AS DateTime) THEN 'PRO_DATE,DOD|Error:Date of Pronouncement is greater than Date of Death' ELSE '' END AS LoadNote_4
	        ,CASE WHEN ((PronouncedTimeInd ='M' AND ISDATE(REPLACE(PRO_TIME,'99','01')) = 0) OR (PronouncedTimeInd IN( 'A', 'P') 
							AND ISDATE(PRO_TIME + REPLACE(REPLACE(PronouncedTimeInd,'A','AM'),'P','PM')) = 0)) THEN 'PRO_TIME,DimPronouncedTimeIndId|Error:Time of Pronouncement not in a valid  range' ELSE '' END AS LoadNote_5
	        ,CASE WHEN PRO_TIME NOT LIKE '[0-9][0-9]:[0-9][0-9]' THEN 'PRO_TIME|Error:Not a valid format for Time of Pronouncement' ELSE '' END AS LoadNote_6
	        ,CASE WHEN PRO_TIME LIKE '12:00' AND PronouncedTimeInd NOT IN ('N','D') THEN 'PRO_TIME,DimPronouncedTimeIndId|Error:Time of Pronouncement not in align with Time Indicator' ELSE '' END AS LoadNote_7
	        ,CASE WHEN (FL_PRONOUNCEMENT_EXISTS = 'Y' AND PRO_TIME IS  NULL ) OR (FL_PRONOUNCEMENT_EXISTS = 'Y' AND PRO_DATE IS  NULL) THEN 'FL_PRONOUNCEMENT_EXISTS,PRO_DATE,PRO_TIME|Warning: If FL_PRONOUNCEMENT_EXISTS is YES Pronouncement Date and Time should not be blank' ELSE '' END AS LoadNote_8
	        ,CASE WHEN ( PRO_TIME IS NOT NULL AND PRO_DATE IS  NULL )  THEN 'PRO_DATE,PRO_TIME|Error: When Pronouncement Time is populated Pronouncement date cannot be blank' ELSE '' END AS LoadNote_9
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD DeathPronouncement_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '') +  IIF( LoadNote_7 <> '',  '||' + LoadNote_7, '') +  IIF( LoadNote_8 <> '',  '||' + LoadNote_8, '') +  IIF( LoadNote_9 <> '',  '||' + LoadNote_9, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathPronouncement_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathPronouncement_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM DimTimeInd TABLE AND UPDATE THE DimPronouncedTimeIndId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimPronouncedTimeIndId INT
		
			UPDATE MT
			SET MT.DimPronouncedTimeIndId =DS.DimTimeIndId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] DS WITH(NOLOCK) ON DS.Abbr=MT.PronouncedTimeInd

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
 
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathPronouncement_Log_Flag=1
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
					  AND DeathPronouncement_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathPronouncement_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
                                 AND DeathPronouncement_Log_Flag = 0

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

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathPronouncement]
			(
				 [PersonId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathPronouncement_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS].[DeathPronouncement_Log]
			(
				 SrId
				 , [PersonId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]	
				 , PRO_DATE,PRO_TIME,PronouncedTimeInd,FL_PRONOUNCEMENT_EXISTS,DOD
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathPronouncement_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId 
				, [PersonId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]
				, PRO_DATE,PRO_TIME,PronouncedTimeInd,FL_PRONOUNCEMENT_EXISTS,DOD
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathPronouncement_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathPronouncement_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathPronouncement_Log_Flag=1
									AND LoadNote LIKE '%|Pending Review%')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'
								AND LoadNote LIKE '%|WARNING%')
	UPDATE [RVRS].[Execution]
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
		UPDATE [RVRS].[Execution]
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

	

