--For Code Review 10-05-2022
IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_DeathCauseAcmeOtherAttrPr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathCauseAcmeOtherAttrPr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_DeathCauseAcmeOtherAttrPr]
AS 

/*
NAME	: Load_VIP_DeathCauseAcmeOtherAttrPr
AUTHOR	: SAILENDRA
CREATED	: 16 JUN 2022
PURPOSE	: TOLOAD DATA INTO FACT DeathCauseAcmeOtherAttr TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE		NAME						DESCRIPTION
16 JUN 2022	SAILENDRA					RVRS 162- : Load Decedent Cause of Death Data from Staging to ODS

EXEC RVRS.Load_VIP_DeathCauseAcmeOtherAttrPr

TRUNCATE TABLE [RVRS].[DeathCauseAcmeOtherAttr]
DELETE FROM RVRS.EXECUTION WHERE ENTITY = 'DeathCauseAcmeOtherAttr'
TRUCNATE TABLE [RVRS].[DeathCauseAcmeOtherAttr_Log]
*/
	PRINT '10'
BEGIN
	DECLARE @ExecutionId BIGINT
		,@TotalPendingReviewRecord INT
		,@TotalWarningRecord INT
		,@Err_Message VARCHAR(1000)
		,@LastLoadedDate DATE
		,@CurentTime AS DATETIME=GETDATE()
		,@LastLoadDate DATE
		,@TotalProcessedRecords INT
		,@MaxDateinData DATE
		,@TotalLoadedRecord INT
		,@TotalErrorRecord INT=0
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
	SELECT 'DeathCauseAcmeOtherAttr' AS Entity
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
		PRINT '1'

		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
		IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathCauseAcmeOtherAttr' AND ExecutionStatus='Completed')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(SrCreatedDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'
		PRINT '2'
		SELECT TOP 100 D.DEATH_REC_ID AS SrId
			  ,P.PersonId
			  ,ISNULL(TRX_FLG,'-2') AS LOOKUP_TRX_FLG
			  ,TRX_CAUSE_MANUAL AS CauseManual
			  ,TRX_INJRY_PLACE AS InjuryPlace
			  ,ISNULL(TRX_SYS_REJECT_CD,'-2') AS LOOKUP_TRX_SYS_REJECT_CD
			  ,ISNULL(TRX_INT_REJECT_CD,'-2') AS LOOKUP_TRX_INT_REJECT_CD
			  ,TRX_INJRY_L AS ActivityAtTimeOfDeath
			  ,TRX_CAUSE_ACME AS UnderlyingCause
			  ,TRX_REC_AXIS_CD AS RecordAxisCode
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
			  ,CAUSE_CATEGORY1
			  ,CAUSE_CATEGORY2
			  ,CAUSE_CATEGORY3
			  ,CAUSE_CATEGORY4
			  ,CAUSE_CATEGORY5
			  ,CAUSE_CATEGORY6
			  ,CAUSE_CATEGORY7
			  ,CAUSE_CATEGORY8
			  ,CAUSE_CATEGORY9
			  ,CAUSE_CATEGORY10
			  ,CAUSE_CATEGORY11
			  ,CAUSE_CATEGORY12
			  ,CAUSE_CATEGORY13
			  ,CAUSE_CATEGORY14
			  ,CAUSE_CATEGORY15
			  ,CAUSE_CATEGORY16
			  ,CAUSE_CATEGORY17
			  ,CAUSE_CATEGORY18
			  ,CAUSE_CATEGORY19
			  ,CAUSE_CATEGORY20 INTO #Tmp_HoldData
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(GETDATE() AS DATE)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.RECORD_REGIS_DATE IS NOT NULL
			  AND VRV_REGISTERED_FLAG =1
			  AND FL_CURRENT =1
			  AND FL_VOIDED=0

		ALTER TABLE #Tmp_HoldData ALTER COLUMN LOOKUP_TRX_FLG VARCHAR(10)
		ALTER TABLE #Tmp_HoldData ALTER COLUMN LOOKUP_TRX_INT_REJECT_CD VARCHAR(10)
		ALTER TABLE #Tmp_HoldData ALTER COLUMN LOOKUP_TRX_SYS_REJECT_CD VARCHAR(10)
		UPDATE #Tmp_HoldData SET LOOKUP_TRX_FLG= '-2' WHERE LOOKUP_TRX_FLG = '-'
		UPDATE #Tmp_HoldData SET LOOKUP_TRX_INT_REJECT_CD= '-2' WHERE LOOKUP_TRX_INT_REJECT_CD = '-'
		UPDATE #Tmp_HoldData SET LOOKUP_TRX_SYS_REJECT_CD= '-2' WHERE LOOKUP_TRX_SYS_REJECT_CD = '-'


PRINT @TotalProcessedRecords
		IF @TotalProcessedRecords=0
		BEGIN
		PRINT'3'

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

		SET @MaxDateinData = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

		IF EXISTS(SELECT SrId FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] WHERE CAST(SrUpdatedDate AS DATE)<=@MaxDateinData)

		BEGIN
		SET @LastLoadedDate = @MaxDateinData

		PRINT '3'
			SELECT HD.SrId AS SrId
			  ,HD.PersonId AS PersonId
			  ,HD.LOOKUP_TRX_FLG AS LOOKUP_TRX_FLG
			  ,TR.DimFlTransaxConversionId AS DimFlTransaxConversionId
			  ,HD.CauseManual AS CauseManual
			  ,HD.InjuryPlace AS InjuryPlace
			  ,HD.LOOKUP_TRX_SYS_REJECT_CD AS LOOKUP_TRX_SYS_REJECT_CD
			  ,REJ.DimSystemRejectId AS DimSystemRejectId
			  ,HD.LOOKUP_TRX_INT_REJECT_CD AS LOOKUP_TRX_INT_REJECT_CD
			  ,IT.DimIntentionalRejectId AS DimIntentionalRejectId
			  ,HD.ActivityAtTimeOfDeath AS ActivityAtTimeOfDeath
			  ,HD.UnderlyingCause AS UnderlyingCause
			  ,HD.RecordAxisCode AS RecordAxisCode
			  ,HD.CreatedDate  AS CreatedDate
			  ,HD.SrCreatedDate AS SrCreatedDate
			  ,HD.SrUpdatedDate AS SrUpdatedDate
			  ,CASE WHEN HD.UnderlyingCause IS NOT NULL AND HD.CauseManual IS NOT NULL AND HD.UnderlyingCause <> HD.CauseManual 
					THEN 'TRX_CAUSE_ACME,TRX_CAUSE_MANUAL|Warning:TRX_CAUSE_ACME and TRX_CAUSE_MANUAL mismatch'
					ELSE '' END AS LoadNote
			  ,CASE WHEN HD.UnderlyingCause IS NULL AND (HD.CAUSE_CATEGORY1 IS NOT NULL OR HD.CAUSE_CATEGORY2  IS NOT NULL OR HD.CAUSE_CATEGORY3  IS NOT NULL 
						OR HD.CAUSE_CATEGORY4 IS NOT NULL OR HD.CAUSE_CATEGORY5 IS NOT NULL OR HD.CAUSE_CATEGORY6 IS NOT NULL OR HD.CAUSE_CATEGORY7 IS NOT NULL 
						OR HD.CAUSE_CATEGORY8 IS NOT NULL OR HD.CAUSE_CATEGORY9  IS NOT NULL OR HD.CAUSE_CATEGORY10  IS NOT NULL OR HD.CAUSE_CATEGORY11 IS NOT NULL 
						OR HD.CAUSE_CATEGORY12  IS NOT NULL OR HD.CAUSE_CATEGORY13  IS NOT NULL OR HD.CAUSE_CATEGORY14  IS NOT NULL OR HD.CAUSE_CATEGORY15  IS NOT NULL 
						OR HD.CAUSE_CATEGORY16 IS NOT NULL OR HD.CAUSE_CATEGORY17  IS NOT NULL OR HD.CAUSE_CATEGORY18  IS NOT NULL OR HD.CAUSE_CATEGORY19  IS NOT NULL 
						OR HD.CAUSE_CATEGORY20  IS NOT NULL)
					THEN ''
					WHEN UnderlyingCause IS NULL AND HD.CAUSE_CATEGORY1 IS NULL AND HD.CAUSE_CATEGORY2  IS NULL AND HD.CAUSE_CATEGORY3  IS NULL AND HD.CAUSE_CATEGORY4 IS NULL 
					AND HD.CAUSE_CATEGORY5 IS NULL AND HD.CAUSE_CATEGORY6 IS NULL AND HD.CAUSE_CATEGORY7 IS NULL AND HD.CAUSE_CATEGORY8 IS NULL AND HD.CAUSE_CATEGORY9  IS NULL 
					AND HD.CAUSE_CATEGORY10  IS NULL AND HD.CAUSE_CATEGORY11 IS NULL AND HD.CAUSE_CATEGORY12 IS  NULL AND HD.CAUSE_CATEGORY13  IS  NULL AND HD.CAUSE_CATEGORY14 IS NULL 
					AND HD.CAUSE_CATEGORY15  IS  NULL AND HD.CAUSE_CATEGORY16 IS NULL AND HD.CAUSE_CATEGORY17  IS  NULL AND HD.CAUSE_CATEGORY18  IS  NULL AND HD.CAUSE_CATEGORY19  IS  NULL AND HD.CAUSE_CATEGORY20  IS  NULL
					THEN ''
					ELSE iif ( UnderlyingCause IN (CAUSE_CATEGORY1,CAUSE_CATEGORY2,CAUSE_CATEGORY3,CAUSE_CATEGORY4,CAUSE_CATEGORY5,CAUSE_CATEGORY6,CAUSE_CATEGORY7
										  ,CAUSE_CATEGORY8,CAUSE_CATEGORY9,CAUSE_CATEGORY10,CAUSE_CATEGORY11,CAUSE_CATEGORY12,CAUSE_CATEGORY13,CAUSE_CATEGORY14
										  ,CAUSE_CATEGORY15,CAUSE_CATEGORY16,CAUSE_CATEGORY17,CAUSE_CATEGORY18,CAUSE_CATEGORY19,CAUSE_CATEGORY20)
										  ,'', 'TRX_CAUSE_ACME,CAUSE_CATEGORY|Warning: TRX_CAUSE_ACME AND CAUSE_CATEGORY value mismatch'
						) 
			 END
			   AS LOADNOTE_1
			INTO #Tmp_HoldData_Filter 
			FROM #Tmp_HoldData HD
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimFlTransaxConversion] TR ON HD.LOOKUP_TRX_FLG = CAST(TR.CODE AS VARCHAR)
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSystemReject] REJ ON HD.LOOKUP_TRX_SYS_REJECT_CD = CAST(REJ.CODE AS VARCHAR)
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimIntentionalReject] IT ON HD.LOOKUP_TRX_INT_REJECT_CD = CAST(IT.CODE AS VARCHAR)

	SET @TotalProcessedRecords = @@ROWCOUNT
			
			PRINT '4'

			SELECT SrID
				,PersonId
				,DimFlTransaxConversionId	
				,CauseManual
				,InjuryPlace
				,DimSystemRejectId
				,DimIntentionalRejectId
				,ActivityAtTimeOfDeath
				,UnderlyingCause
				,RecordAxisCode
				,SrUpdatedDate
				,CreatedDate
				,LoadNote +
					(CASE WHEN LoadNote <> '' THEN ' || ' ELSE '' END) +
					LoadNote_1 
					AS LoadNote
				INTO #Tmp_HoldData_Final
				FROM #Tmp_HoldData_Filter
				
				PRINT '5'
		/**************************************************************Other Validations STARTS*************************************************************/
			/*UPDATING LOAD NOTE FOR THE RECORDS WHERE WE HAVE SOME ISSUES WITH CHILD RECORD HOWEVER THE PARENT LOAD IS FINE.*/

			----scenario 1  BUT WE MIGHT NOT NEED THIS PART BECAUSE WE DON'T HAVE ERROR VALIDATIONS
			--UPDATE P
			--SET P.LoadNote= 'DeathCauseAcme|MissingChild:ChildMissing DeathCauseAcme' + CASE WHEN P.LoadNote!='' THEN ' || ' + P.LoadNote ELSE '' END 
			--FROM #Tmp_HoldData_Final HF
			--JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
			--WHERE HF.PersonAKA_log_Flag=1
			--	AND HF.PersonId IS NOT NULL

			--scenario 2 & 3
			UPDATE #Tmp_HoldData_Final
			SET LoadNote=CASE WHEN LoadNote!='' THEN 'Person|ParentMissing:Validation Warning' + ' || ' + LoadNote ELSE '' END
				WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log)


			--scenario 4
			IF EXISTS(SELECT SrUpdatedDate FROM #Tmp_HoldData_Final WHERE PersonId IS NULL 
			   AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
			   AND LoadNote='')
				BEGIN
					SET @ExecutionStatus='Failed'
					set @Note = 'Parent table has not been processed yet'
				END

			--scenario 5
			UPDATE #Tmp_HoldData_Final
				SET LoadNote=CASE WHEN LoadNote!='' THEN 'Person|ParentMissing:Not Processed'+' || '+ LoadNote
					ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL
				  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
				  AND  LoadNote!=''

		/***************************************************************Other Validations ENDS**************************************************************/

		SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathCauseAcmeOtherAttr]
			(
					 PersonId	
					,DimFlTransaxConversionId	
					,CauseManual	
					,InjuryPlace	
					,DimSystemRejectId	
					,DimIntentionalRejectId	
					,ActivityAtTimeOfDeath	
					,UnderlyingCause
					,RecordAxisCode	
					,CreatedDate	
					,LoadNote
			)
			SELECT PersonId
				  ,DimFlTransaxConversionId
				  ,ISNULL(CauseManual,'')
				  ,InjuryPlace
				  ,DimSystemRejectId
				  ,DimIntentionalRejectId
				  ,ActivityAtTimeOfDeath
				  ,ISNULL(UnderlyingCause,'')
				  ,RecordAxisCode
				  ,CreatedDate 
				  ,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE PersonId IS NOT NULL

	SET @TotalLoadedRecord = @@ROWCOUNT
	

			INSERT INTO [RVRS].[DeathCauseAcmeOtherAttr_Log]
			(
				   PersonId	
				  ,SrId	
				  ,DimFlTransaxConversionId	
				  ,CauseManual	
				  ,InjuryPlace	
				  ,DimSystemRejectId	
				  ,DimIntentionalRejectId	
				  ,ActivityAtTimeOfDeath	
				  ,UnderlyingCause	
				  ,RecordAxisCode	
				  ,CreatedDate	
				  ,LoadNote
			)
			SELECT PersonId
				  ,SrId
				  ,DimFlTransaxConversionId
				  ,ISNULL(CauseManual,'')
				  ,InjuryPlace
				  ,DimSystemRejectId
				  ,DimIntentionalRejectId
				  ,ActivityAtTimeOfDeath
				  ,ISNULL(UnderlyingCause,'')
				  ,RecordAxisCode
				  ,CreatedDate 
				  ,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE PersonId IS NULL
			  


			SET @TotalErrorRecord = @@ROWCOUNT

			SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote LIKE '%|Pending Review%')
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

			SET @Err_Message ='We do not have data for '+ CONVERT(VARCHAR(50),@MaxDateinData,106) +' in Person Table'
			RAISERROR (@Err_Message,10,1)
			END
		END
	END TRY

	BEGIN CATCH
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

