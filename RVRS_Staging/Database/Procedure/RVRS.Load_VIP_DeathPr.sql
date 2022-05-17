
IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_DeathPr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathPr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_DeathPr]
AS 

/*
NAME	: Load_VIP_DeathPr
AUTOR	: SAILENDRA SINGH
CREATED	: 31 MAR 2022
PURPOSE	: TO LOAD DATA INTO FACT DEATH TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE			NAME							DESCRIPTION
31 Mar 2022		SAILENDRA SINGH					RVRS-159 : LOAD DECEDENT BASIC DATA FROM STAGING TO ODS

EXEC Load_VIP_DeathPr
*/

SET NOCOUNT ON

BEGIN
	DECLARE @ExecutionId BIGINT
		,@TotalPendingReviewRecord INT
		,@TotalWarningRecord INT
		,@TotalProcessedRecords INT
		,@MaxDateinData DATE
		,@TotalLoadedRecord INT
		,@TotalErrorRecord INT
		,@Err_Message VARCHAR(100)
		,@LastLoadedDate DATE
		,@ExecutionStatus VARCHAR(100)='Completed'
		,@Note VARCHAR(500)

	INSERT INTO RVRS.Execution
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
	SELECT 'Death' AS Entity
		,'In Progress' AS ExecutionStatus
		,NULL AS LastLoadDate
		,GETDATE() AS StartTime
		,NULL AS EndTime
		,0 AS TotalProcessedRecords
		,0 AS TotalLoadedRecord
		,0 AS TotalErrorRecord
		,0 AS TotalPendingReviewRecord
		,0 AS TotalWarningRecord

	SET @ExecutionId = (SELECT IDENT_CURRENT('RVRS.Execution'))

	BEGIN TRY
		--PRINT '1'
		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='Death')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(LastLoadDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'
	
		--PRINT '2'

		IF OBJECT_ID('tempdb..#Tmp_HoldFilteredData') IS NOT NULL 
			DROP TABLE #Tmp_HoldFilteredData
		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
		IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final
		IF OBJECT_ID('tempdb..#Tmp_HD_SFN_Check') IS NOT NULL 
			DROP TABLE #Tmp_HD_SFN_Check
		IF OBJECT_ID('tempdb..#Tmp_HD_SFN_Check_T') IS NOT NULL 
			DROP TABLE #Tmp_HD_SFN_Check_T
	
		--PRINT '3'

		SELECT INTERNAL_CASE_NUMBER
			,SFN_TYPE_ID
			,SFN_NUM
			,SFN_YEAR
			,VRV_RECORD_TYPE_ID
			,OTHER_RECORD_TYPE
			,DOD_4_FD
			,TOD
			,DEATH_REC_ID
			,TOD_IN
			,DSTATEL
			,DOD
			,TOD_ME
			,VRV_REC_DATE_CREATED 
			,VRV_DATE_CHANGED
			,SFN_NUM_OOS INTO #Tmp_HoldFilteredData
		FROM [RVRS].[VIP_VRV_Death_Tbl] D WITH(NOLOCK)
		WHERE VRV_DATE_CHANGED IS NOT NULL
			AND CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(GETDATE() AS DATE)
			AND D.VRV_RECORD_TYPE_ID = '040'
			AND RECORD_REGIS_DATE IS NOT NULL

		SET @TotalProcessedRecords = @@ROWCOUNT

		IF @TotalProcessedRecords=0
		BEGIN
			UPDATE [RVRS].[Execution]
			SET ExecutionStatus='Completed'
				,LastLoadDate=@LastLoadedDate
				,EndTime=GETDATE()
				,TotalProcessedRecords=0
				,TotalLoadedRecord=0
				,TotalErrorRecord=0
				,TotalPendingReviewRecord=0
				,TotalWarningRecord=0
			WHERE ExecutionId=@ExecutionId

		END
		ELSE
		BEGIN
			SET @MaxDateinData = (SELECT MAX(VRV_DATE_CHANGED) FROM #Tmp_HoldFilteredData)

			IF EXISTS(SELECT SrId FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] WHERE CAST(SrUpdatedDate AS DATE)<=@MaxDateinData)
			BEGIN
				SET @LastLoadedDate = @MaxDateinData

				--PRINT '4'

				/*TO CHECK RECORDS IF THEY HAVE NOT UNIQUE SFN_NUM AND INTERNAL_CASE_NUM*/

				SELECT * INTO #Tmp_HD_SFN_Check
				FROM 
				(
					SELECT DEATH_REC_ID
						,INTERNAL_CASE_NUMBER  
						,Rank() OVER(PARTITION BY SFN_NUM,yr ORDER BY ID) AS Rank_Num_SFN
						,SFN_NUM
						,ID
						,Rank() OVER (PARTITION BY INTERNAL_CASE_NUMBER ORDER BY ID) AS Rank_Num_CaseNumber
					FROM 
					(                                    
						SELECT DEATH_REC_ID
							,SFN_NUM
							,Isnull(VRV_BASELINE_RECORD_ID,DEATH_REC_ID) AS ID
							,INTERNAL_CASE_NUMBER 
							,Substring(INTERNAL_CASE_NUMBER, 0,5) AS Yr
						 FROM RVRS.VIP_VRV_Death_Tbl D
						 where  EXISTS (SELECT 1 FROM #Tmp_HoldFilteredData DF WHERE D.INTERNAL_CASE_NUMBER = DF.INTERNAL_CASE_NUMBER)
					) s 
				) s
				where (Rank_Num_SFN > 1 or Rank_Num_CaseNumber>1) 
					AND DEATH_REC_ID NOT IN (SELECT SRID FROM RVRS.DEATH_LOG  where loadnote like '%SFN%Duplicate%')
		

				/*SELECT DISTINCT ISNULL(VRV_BASELINE_RECORD_ID,DEATH_REC_ID) AS VRV_BASELINE_RECORD_ID
					,SFN_NUM
					,INTERNAL_CASE_NUMBER
					,LEFT(INTERNAL_CASE_NUMBER,4) AS Yr INTO #Tmp_HD_SFN_Check_T
				FROM [RVRS].[VIP_VRV_Death_Tbl] D WITH(NOLOCK)
				WHERE SFN_NUM IS NOT NULL
				AND D.VRV_RECORD_TYPE_ID = '040'
				AND RECORD_REGIS_DATE IS NOT NULL

				SELECT D.DEATH_REC_ID INTO #Tmp_HD_SFN_Check												
				FROM
				(
					SELECT INTERNAL_CASE_NUMBER  
						,ROW_NUMBER() OVER(PARTITION BY SFN_NUM,INTERNAL_CASE_NUMBER,Yr ORDER BY VRV_BASELINE_RECORD_ID) AS Row_Num
					FROM #Tmp_HD_SFN_Check_T
				)A
				JOIN [RVRS].[VIP_VRV_Death_Tbl] D WITH(NOLOCK) ON D.INTERNAL_CASE_NUMBER=A.INTERNAL_CASE_NUMBER 
				WHERE A.Row_Num>1
				AND D.VRV_RECORD_TYPE_ID = '040'
				AND RECORD_REGIS_DATE IS NOT NULL
				*/

				--PRINT '5'
	
				SELECT P.PersonId AS PersonId
					,D.INTERNAL_CASE_NUMBER AS InternalCaseNumber
					,D.SFN_TYPE_ID AS SfnType
					,D.SFN_NUM AS Sfn
					,D.SFN_NUM_OOS AS SfnOutOfState
					,D.SFN_YEAR AS SfnYear
					,D.VRV_RECORD_TYPE_ID AS RecordType
					,D.OTHER_RECORD_TYPE AS OtherRecordType
					,CASE WHEN ISDATE(D.DOD_4_FD) = 1 THEN YEAR(CAST(D.DOD_4_FD AS DATE)) 
						  WHEN D.DOD_4_FD LIKE '99/99/[0-9][0-9][0-9][0-9]'THEN RIGHT(D.DOD_4_FD,4)
					 ELSE NULL END AS DeathYear
					,CASE WHEN ISDATE(D.DOD_4_FD) = 1 THEN MONTH(CAST(D.DOD_4_FD AS DATE))
						  WHEN D.DOD_4_FD LIKE '[0-9][0-9]/99/9999'THEN LEFT(D.DOD_4_FD,2)
					ELSE NULL END AS DeathMonth
					,CASE WHEN ISDATE(D.DOD_4_FD) = 1 THEN DAY(CAST(D.DOD_4_FD AS DATE))
						  WHEN D.DOD_4_FD LIKE '99/[0-9][0-9]/9999'THEN SUBSTRING(D.DOD_4_FD,4,2)   
					 ELSE NULL END AS DeathDay
					,SUBSTRING(D.TOD,0,CHARINDEX(':',D.TOD,1)) AS DeathHour
					,SUBSTRING(D.TOD,CHARINDEX(':',D.TOD,1)+1,LEN(D.TOD)) AS DeathMinute
					,TI.DimTimeIndId AS DimDeathTimeIndId
					,P.CreatedDate AS CreatedDate
					,D.DEATH_REC_ID AS SrId

					/*1. VALID DATE CHECK*/																										--GOING TO DEATH_LOG
					,CASE WHEN ISDATE(D.DOD_4_FD) = 0 AND D.DOD_4_FD LIKE '99/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN ''
						  WHEN ISDATE(D.DOD_4_FD) = 0 AND D.DOD_4_FD LIKE '[0-9][0-9]/99/[0-9][0-9][0-9][0-9]' THEN ''
						  WHEN ISDATE(D.DOD_4_FD) = 0 AND D.DOD_4_FD LIKE '[0-9][0-9]/[0-9][0-9]/9999' THEN ''
						  WHEN ISDATE(D.DOD_4_FD) = 0 AND D.DOD_4_FD <> '99/99/9999' THEN 'DOD_4_FD|Error:NOT A VALID DATE'
						  ELSE '' END
					 AS LoadNote

					 /*2. ADD COMPARISON DOD AND DOD_4_FD CAN BE PASSED AS WARNING*/															--GOING TO DEATH WITH WARNING
					,CASE WHEN ISDATE(D.DOD_4_FD) = 1 AND ISDATE(D.DOD) = 1 AND D.DOD_4_FD<>D.DOD 
						THEN 'DOD_4_FD,DOD|Warning:Date of Death Mismatch in Tab 1 and Tab 6'
						ELSE '' END AS LoadNote_1

					/*3. CHECKING IF THE DATES ARE GREATER THAN 2014 AND LESS THAN TODAY*/														--GOING TO DEATH_LOG
					,CASE WHEN ISDATE(D.DOD_4_FD) = 1 AND YEAR(CAST(D.DOD_4_FD AS DATE))<2014 AND YEAR(CAST(D.DOD_4_FD AS DATE))>GETDATE()
						THEN 'DOD_4_FD|Error:Year of Death is before 2014 or later than today'
						ELSE '' END AS LoadNote_2

					/*4. VERIFYING SFN_NUM HAS 6 DIGITS*/																						--GOING TO DEATH_LOG
					,CASE WHEN LEN(D.SFN_NUM)<>6 THEN 'SFN_NUM|Error:SFN Number is not 6 digits'
						 ELSE '' END AS LoadNote_3


					/*5. VERIFYINF SFN_NUM IS UNIQUE FOR YEAR*/																					--GOING TO DEATH_LOG
					,CASE WHEN SFN.DEATH_REC_ID IS NOT NULL AND SFN.Rank_Num_SFN>1 THEN 'SFN_NUM|Error:Duplicate SFN For same Year'
						  ELSE '' END
					 AS LoadNote_4


					 /*6. VRV_RECORD_TYPE_ID VS SFN_NUM (IF REC_TYPE_ID IS 40 THEN SFN SHOULD START WITH 9)*/									--GOING TO DEATH_LOG
					 ,CASE WHEN (D.VRV_RECORD_TYPE_ID=40 AND D.SFN_NUM LIKE '9%') OR (D.VRV_RECORD_TYPE_ID=49 AND D.SFN_NUM NOT LIKE '9%')
						  THEN 'VRV_RECORD_TYPE_ID,SFN_NUM|Error:VRV_RECORD_TYPE_ID & SFN_NUM does not match'
						  ELSE '' END
					 AS LoadNote_5

					 /*7. VERIFYING OTHER_RECORD_TYPE HAS RIGHT VALUE*/																			--GOING TO DEATH_LOG
					 ,CASE WHEN (D.OTHER_RECORD_TYPE IS NOT NULL AND D.OTHER_RECORD_TYPE<>'Y') THEN 'OTHER_RECORD_TYPE|Error:OTHER_RECORD_TYPE has wrong value'
						  ELSE '' END
					 AS LoadNote_6

					 /*8. VERFYING VRV_RECORD_TYPE_ID FOR INSTATE AND OUT OF STATE*/															--GOING TO DEATH_LOG
					 ,CASE WHEN (D.VRV_RECORD_TYPE_ID <> 40 AND D.DSTATEL = 'MASSACHUSETTS') OR (D.VRV_RECORD_TYPE_ID = 40 AND D.DSTATEL != 'MASSACHUSETTS') 
							THEN 'VRV_RECORD_TYPE_ID,DSTATEL|Error:VRV_RECORD_TYPE_ID & Death STATE  Mismatch'
						  ELSE '' END
					 AS LoadNote_7

					 /*9. VERFYING SFN_TYPE_ID  FOR INSTATE AND OUT OF STATE (WARNING ERROR, CAN BE PASSED)*/									--GOING TO DEATH TABLE WITH WARNING
					 ,CASE WHEN (D.SFN_TYPE_ID IN (40,42,47) AND D.DSTATEL != 'MASSACHUSETTS' OR D.SFN_TYPE_ID =49 AND D.DSTATEL = 'MASSACHUSETTS')
							THEN 'SFN_TYPE_ID.DSTATEL|Warning:SFN_TYPE_ID does not match DSTATEL'
						  ELSE '' END AS LoadNote_8


					/*10. VERIFYING INTERNAL_CASE_NUMBER HAS RIGHT CALCULATION*/																--GOING TO DEATH_LOG
					--,CASE WHEN (D.INTERNAL_CASE_NUMBER IS NOT NULL 
					--	AND D.INTERNAL_CASE_NUMBER <> CAST(YEAR(CAST(D.DOD_4_FD AS DATE)) AS VARCHAR(5)) + CAST(CAST(D.VRV_RECORD_TYPE_ID AS INT) AS VARCHAR(5)) + D.SFN_NUM)
					,CASE WHEN (ISNULL(D.INTERNAL_CASE_NUMBER,-1) <> ISNULL((CAST(YEAR(CAST(D.DOD_4_FD AS DATE)) AS VARCHAR(5)) + CAST(CAST(D.VRV_RECORD_TYPE_ID AS INT) AS VARCHAR(5)) + D.SFN_NUM),-1))
						  THEN 'INTERNAL_CASE_NUMBER|Error:INTERNAL_CASE_NUMBER wrongly calculated'
						  ELSE '' END
					 AS LoadNote_9

					 /*11. CHECKING IF INTERAN CASE NUMBER SHOULD BE UNIQUE FOR RELEVANT VERSIONS ACCROSS THE YEARS*/							--GOING TO DEATH_LOG
					 ,CASE WHEN SFN.DEATH_REC_ID IS NOT NULL AND SFN.Rank_Num_CaseNumber>1 THEN 'INTERNAL_CASE_NUMBER|Error:INTERNAL_CASE_NUMBER is not unique'
						ELSE '' END
					 AS LoadNote_10

					/*12. CHECKING IF THE HOUR AND MINUTE ARE IN VALID RANGE*/																	--GOING TO DEATH_LOG
					,CASE WHEN D.TOD IS NOT NULL AND D.TOD = '99:99' THEN ''
						  WHEN(SUBSTRING(D.TOD,0,CHARINDEX(':',D.TOD,1))) =99 THEN ''
						  WHEN SUBSTRING(D.TOD,CHARINDEX(':',D.TOD,1)+1,LEN(D.TOD))=99 THEN '' 
						  WHEN(SUBSTRING(D.TOD,0,CHARINDEX(':',D.TOD,1)) >24 OR SUBSTRING(D.TOD,0,CHARINDEX(':',D.TOD,1))<0) 
					OR (SUBSTRING(D.TOD,CHARINDEX(':',D.TOD,1)+1,LEN(D.TOD)) >60 OR SUBSTRING(D.TOD,CHARINDEX(':',D.TOD,1)+1,LEN(D.TOD))<0) 
						  THEN 'TOD|Error:Death Hour and Minute not in valid range' ELSE '' END AS LoadNote_11
				

					/*13. CHECKING IF TIME OF DEATH ON TAB 1 MATHCES WITH TAB 6*/																--GOING TO DEATH WITH WARNING			
					,CASE WHEN ISNULL(D.TOD,'')!=ISNULL(D.TOD_ME,'')
						THEN 'TOD|Warning:Death Hour and Minute Mismatch in Tab 1 and Tab 6' ELSE '' END AS LoadNote_12

					/*14. VERIFYING VALID DATE RANGE FOR SFN_YEAR*/																				--GOING TO DEATH_LOG
					,CASE WHEN D.SFN_YEAR<2014 OR D.SFN_YEAR>YEAR(CAST(GETDATE() AS DATE)) 
						THEN 'SFN_YEAR|Error:SFN_YEAR not in valid range' ELSE '' END AS LoadNote_13
				
					----15. Excluding the Records that are not in Person table																	--GOING TO DEATH_LOG
					--,CASE WHEN P.PersonId IS NULL THEN 'PersonID|Warning:This records does not exists in person table'
					--	  ELSE '' END AS LoadNote_14

	
					--16. VRV_RECORD_TYPE_ID VS SFN_TYPE_ID					
					,CASE WHEN (D.SFN_TYPE_ID=40 AND D.VRV_RECORD_TYPE_ID=49 OR D.SFN_TYPE_ID=49 AND D.VRV_RECORD_TYPE_ID=40) --6 RECORDS WHERE SFN_TYPE AND RECORD_TYPE DO NOT MATCH
						THEN 'SFN_TYPE_ID|Warning:SFN_TYPE_ID & VRV_RECORD_TYPE_ID Mismatch' ELSE '' END AS LoadNote_15
								
		
				INTO #Tmp_HoldData
				FROM #Tmp_HoldFilteredData D
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[PERSON] P ON P.SrId=D.DEATH_REC_ID
				LEFT JOIN #Tmp_HD_SFN_Check SFN ON SFN.DEATH_REC_ID=D.DEATH_REC_ID
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] TI ON TI.Abbr=ISNULL(D.TOD_IN,'NULL')	

				--PRINT '6'

				SELECT PersonId
					,InternalCaseNumber
					,SfnType
					,Sfn
					,SfnOutOfState
					,SfnYear
					,RecordType
					,OtherRecordType
					,DeathYear
					,DeathMonth
					,DeathDay
					,DeathHour
					,DeathMinute
					,DimDeathTimeIndId
					,CreatedDate
					,SrId
					,CASE WHEN LoadNote<>'' OR LoadNote_2<>'' OR LoadNote_3<>'' OR LoadNote_4<>''OR LoadNote_5<>'' OR LoadNote_6<>'' OR LoadNote_7<>'' 
					  OR LoadNote_9<>''  OR LoadNote_10<>''  OR LoadNote_11<>'' OR LoadNote_13<>'' 
					  THEN 1 ELSE 0 END AS Death_Log_Flag
					,LoadNote  +
						(CASE WHEN LoadNote <> '' THEN ' || ' ELSE '' END) +
						LoadNote_1 +
						(CASE WHEN LoadNote_1 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_2 +
						(CASE WHEN LoadNote_2 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_3 +
						(CASE WHEN LoadNote_3 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_4  +
						(CASE WHEN LoadNote_4 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_5 +
						(CASE WHEN LoadNote_5 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_6 +
						(CASE WHEN LoadNote_6 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_7 +
						(CASE WHEN LoadNote_7 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_8 +
						(CASE WHEN LoadNote_8 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_9 +
						(CASE WHEN LoadNote_9 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_10 +
						(CASE WHEN LoadNote_10 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_11 +
						(CASE WHEN LoadNote_11 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_12 +
						(CASE WHEN LoadNote_12 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_13 +
						(CASE WHEN LoadNote_13 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_15 AS Death_Log_LoadNote
					,LoadNote_1 +
						(CASE WHEN LoadNote_1 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_8 +
						(CASE WHEN LoadNote_8 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_12 +
						(CASE WHEN LoadNote_12 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_15 
						AS LoadNote

						INTO #Tmp_HoldData_Final
				FROM #Tmp_HoldData

		/**************************************************************Other Validations STARTS*************************************************************/
			/*UPDATING LOAD NOTE FOR THE RECORDS WHERE WE HAVE SOME ISSUES WITH CHILD RECORD HOWEVER THE PARENT LOAD IS FINE*/

			--Scenario 1
			UPDATE P
			SET P.LoadNote= 'DEATH|MissingChild:ChildMissing Death' + CASE WHEN P.LoadNote!='' THEN ' || ' + P.LoadNote ELSE '' END
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
			WHERE HF.Death_Log_Flag=1
				AND HF.PersonId IS NOT NULL

			--Scenarion 2 & 3
			UPDATE #Tmp_HoldData_Final
			SET Death_Log_Flag=1
				,Death_Log_LoadNote=CASE WHEN Death_Log_LoadNote!='' THEN 'Person|ParentMissing:Validation Errors' + ' || ' + Death_Log_LoadNote ELSE '' END
				WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log)

			--Scenario 4
				IF EXISTS(SELECT Death_Log_Flag FROM #Tmp_HoldData_Final WHERE PersonId IS NULL 
								AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
								AND Death_Log_Flag=0)
				BEGIN
					SET @ExecutionStatus='Failed'
					set @Note = 'Parent table has not been processed yet'
				END
				

			--Scenario 5			
			UPDATE #Tmp_HoldData_Final
				SET Death_Log_Flag=1
				   ,Death_Log_LoadNote=CASE WHEN Death_Log_LoadNote!='' THEN 'Person|ParentMissing:Not Processed'+' || '+Death_Log_LoadNote
					ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL
				  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
				




		/***************************************************************Other Validations ENDS**************************************************************/
				--PRINT '7'

				INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[Death]
				(
					 PersonId
					,InternalCaseNumber
					,SfnType
					,Sfn
					,SfnOutOfState
					,SfnYear
					,RecordType
					,OtherRecordType
					,DeathYear
					,DeathMonth
					,DeathDay
					,DeathHour
					,DeathMinute
					,DimDeathTimeIndId
					,CreatedDate
					,LoadNote
				)
				SELECT PersonId
					,InternalCaseNumber
					,SfnType
					,Sfn
					,SfnOutOfState
					,SfnYear
					,RecordType
					,OtherRecordType
					,DeathYear
					,DeathMonth
					,DeathDay
					,DeathHour
					,DeathMinute
					,DimDeathTimeIndId
					,CreatedDate
					,LoadNote
				FROM #Tmp_HoldData_Final
				WHERE Death_log_Flag=0
				AND PersonId IS NOT NULL

				SET @TotalLoadedRecord = @@ROWCOUNT

				--PRINT '8'

				INSERT INTO [RVRS].[Death_Log]
				(
					 PersonId
					,SrId
					,InternalCaseNumber
					,SfnType
					,Sfn
					,SfnOutOfState
					,SfnYear
					,RecordType
					,OtherRecordType
					,DeathYear
					,DeathMonth
					,DeathDay
					,DeathHour
					,DeathMinute
					,DimDeathTimeIndId
					,CreatedDate
					,LoadNote
				)
				SELECT PersonId
					,SrId
					,InternalCaseNumber
					,SfnType
					,Sfn
					,SfnOutOfState
					,SfnYear
					,RecordType
					,OtherRecordType
					,DeathYear
					,DeathMonth
					,DeathDay
					,DeathHour
					,DeathMinute
					,DimDeathTimeIndId
					,CreatedDate
					,Death_Log_LoadNote
				FROM #Tmp_HoldData_Final
				WHERE Death_log_Flag=1

				SET @TotalErrorRecord = @@ROWCOUNT

				--PRINT '9'

				SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE Death_log_Flag=1 AND LoadNote LIKE '%|Pending Review%')
				SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'	AND LoadNote LIKE '%|WARNING%')

				UPDATE [RVRS].[Execution]
				SET ExecutionStatus=@ExecutionStatus
					,LastLoadDate=@LastLoadedDate
					,EndTime=GETDATE()
					,TotalProcessedRecords=@TotalProcessedRecords
					,TotalLoadedRecord=@TotalLoadedRecord
					,TotalErrorRecord=@TotalErrorRecord
					,TotalPendingReviewRecord=@TotalPendingReviewRecord
					,TotalWarningRecord=@TotalWarningRecord
					,NOTE= @Note 
				WHERE ExecutionId=@ExecutionId
			END
			ELSE
			BEGIN
				UPDATE [RVRS].[Execution]
				SET ExecutionStatus=@ExecutionStatus
					,LastLoadDate=@LastLoadedDate
					,EndTime=GETDATE()
					,TotalProcessedRecords=@TotalProcessedRecords
					,TotalLoadedRecord=@TotalLoadedRecord
					,TotalErrorRecord=@TotalErrorRecord
					,TotalPendingReviewRecord=@TotalPendingReviewRecord
					,TotalWarningRecord=@TotalWarningRecord
				WHERE ExecutionId=@ExecutionId
				--PRINT 'ELSE'
				--is not going to catch block
				SET @Err_Message ='We do not have data for '+ CONVERT(VARCHAR(50),@MaxDateinData,106) +' in Person Table'
				RAISERROR (@Err_Message,10,1)
			END
		END
	END TRY
	BEGIN CATCH
	PRINT '32'
		UPDATE [RVRS].[Execution]
		SET ExecutionStatus='Failed'
			,LastLoadDate=@LastLoadedDate
			,EndTime=GETDATE()
			,TotalProcessedRecords=@TotalProcessedRecords
			,TotalLoadedRecord=@TotalLoadedRecord
			,TotalErrorRecord=@TotalErrorRecord
			,TotalPendingReviewRecord=@TotalPendingReviewRecord
			,TotalWarningRecord=@TotalWarningRecord
		WHERE ExecutionId=@ExecutionId
	
		SET @Err_Message = ERROR_MESSAGE()
		RAISERROR (@Err_Message,11,1)
	END CATCH
END
