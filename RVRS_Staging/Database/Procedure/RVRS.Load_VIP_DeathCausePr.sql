USE RVRS_STAGING
IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_DeathCausePr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathCausePr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_DeathCausePr]
AS 

/*
NAME	: Load_VIP_DeathCausePr
AUTHOR	: SAILENDRA 
CREATED	: 25 AUG 2022
PURPOSE	: TO LOAD DATA INTO FACT DeathCause TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE		NAME						DESCRIPTION
06 JUN 2022	SAILENDRA					RVRS 162- : LOAD DECEDENT CAUSE OF DEATH DATA FROM STAGING TO ODS

EXEC RVRS.Load_VIP_DeathCausePr
*/

BEGIN
		PRINT '1' + CONVERT (VARCHAR(50),GETDATE(),109)
	DECLARE @ExecutionId BIGINT
		,@TotalPendingReviewRecord INT
		,@TotalWarningRecord INT
		,@Err_Message VARCHAR(1000)
		,@LastLoadedDate DATE
		,@CurentTime AS DATETIME=GETDATE()
		,@LastLoadDate DATE
		,@TotalProcessedRecords INT
		,@TotalParentMissingRecords INT = 0
		,@MaxDateinData DATE
		,@TotalLoadedRecord INT
		,@TotalErrorRecord INT=0
		,@ExecutionStatus VARCHAR(100)='Completed'
		,@Note VARCHAR(500)
		,@RecordCountDebug INT

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
	SELECT 'DeathCause' AS Entity
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

	PRINT '2' + CONVERT (VARCHAR(50),GETDATE(),109)

	BEGIN TRY
		--PRINT '3'

		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
		IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathCause' AND ExecutionStatus='Completed')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(SrCreatedDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'

		
	    SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId	
			  ,1 AS CauseOrder
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODIA AS Cause	
			  ,D.INTIA AS IntervalOrginal	
			  ,ISNULL(D.UNITA,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId	
			  ,NULL AS DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,D.CONDII AS OtherCause
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
			  into #Tmp_HoldData 
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODIA IS NOT NULL OR D.INTIA IS NOT NULL OR D.UNITA IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId		  
			  ,2 AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODIB AS Cause	
			  ,D.INTIB AS IntervalOrginal	
			  ,ISNULL(D.UNITB,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId	
			  ,NULL AS DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,D.CONDII AS OtherCause
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODIB IS NOT NULL OR D.INTIB IS NOT NULL OR D.UNITB IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId	
			  ,3 AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODIC AS Cause	
			  ,D.INTIC AS IntervalOrginal	
			  ,ISNULL(D.UNITC,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId	
			  ,NULL AS DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,D.CONDII AS OtherCause
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE  D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODIC IS NOT NULL OR D.INTIC IS NOT NULL OR D.UNITC IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId	
			  ,4 AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODID AS Cause	
			  ,D.INTID AS IntervalOrginal	
			  ,ISNULL(D.UNITD,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId 	
			  ,NULL AS  DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,D.CONDII AS OtherCause
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODID IS NOT NULL OR D.INTID IS NOT NULL OR D.UNITD IS NOT NULL)

		SET @TotalProcessedRecords = @@ROWCOUNT
		ALTER TABLE #Tmp_HoldData ADD DeathCause_Log_LoadNote VARCHAR(2000)

		IF @TotalProcessedRecords=0
		BEGIN
		PRINT '3B' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT'ERROR'

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
		END
		ELSE
		BEGIN

		SET @MaxDateinData = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)
		PRINT @MaxDateinData

		IF EXISTS (SElECT top 1 1 from #Tmp_HoldData where PersonId is not null )

		BEGIN
		SET @LastLoadedDate = @MaxDateinData

		PRINT '4' + CONVERT (VARCHAR(50),GETDATE(),109)

		SELECT SrId
			  ,PersonId	
			  ,CertDesig
			  ,CauseOrder	
			  ,Cause	
			  ,IntervalOrginal	
			  ,UnitOriginal
			  ,DimUnitOrginalId	
			  ,DC.IntervalType AS IntervalTypeConv	
			  ,DC.Interval1 AS Interval1Conv	
			  ,DC.Interval2 AS Interval2Conv
			  ,CASE WHEN ISNULL(DC.Unit1,'NULL') = '' THEN 'NULL' ELSE DC.UNIT1 END AS Unit1Conv	--Writing a case statement here because replace function is not giving desirable output
			  ,CASE WHEN ISNULL(DC.Unit2,'NULL') = '' THEN 'NULL' ELSE DC.UNIT2 END AS Unit2Conv 
			  ,DimUnit1ConvId	
			  ,DimUnit2ConvId
			  ,CreatedDate	
			  ,OtherCause	
			  ,SrCreatedDate
			  ,SrUpdatedDate
			  ,CASE WHEN CertDesig = 'MEDICAL EXAMINER'  AND CAUSE = 'PENDING' AND CAUSEORDER !=1 AND OtherCause IS NOT NULL
					THEN '|| CertDesig,Cause|Error:Certifier is ME and CauseStatus is ''Pending'' but other Causes have value' ELSE '' END AS LoadNote
			  ,CASE WHEN Cause = 'PENDING' and CertDesig != 'MEDICAL EXAMINER' 
					THEN '|| CertDesig,Cause|Error:CauseStatus is ''Pending'' but Certifier is NOT ME' ELSE '' END AS LoadNote_1
			  ,CASE WHEN Cause IS NULL AND (IntervalOrginal IS NOT NULL OR UnitOriginal IS NOT NULL) 
					THEN '|| Cause,IntervalOrginal,UnitOriginal|Error:DeathCause is null but Death Interval or Death Unit have value' ELSE '' END AS LoadNote_2
		INTO #Tmp_HoldData_Filter
		FROM #Tmp_HoldData HD
		LEFT JOIN [RVRS].[DeathCauseInterval_Data_Conversion] DC on HD.IntervalOrginal = DC.Interval

		SET @TotalProcessedRecords = @@ROWCOUNT

		SELECT SrId
			  ,PersonId	
			  ,CertDesig
			  ,CauseOrder	
			  ,Cause	
			  ,IntervalOrginal	
			  ,UnitOriginal
			  ,DimUnitOrginalId	
			  ,IntervalTypeConv AS IntervalTypeConv	
			  ,Interval1Conv AS Interval1Conv	
			  ,Interval2Conv AS Interval2Conv
			  ,ISNULL(Unit1Conv,'NULL') AS Unit1Conv
			  ,ISNULL(Unit2Conv,'NULL') AS Unit2Conv
			  ,DimUnit1ConvId	
			  ,DimUnit2ConvId
			  ,CreatedDate	
			  ,OtherCause	
			  ,SrCreatedDate
			  ,SrUpdatedDate
			  ,CASE WHEN LoadNote<>'' OR LoadNote_1<>'' 
					THEN 1 ELSE 0 END AS DeathCause_Log_Flag
			  ,LoadNote +
					(CASE WHEN LoadNote <> '' THEN ' || ' ELSE '' END) +
				LoadNote_1 + 
					(CASE WHEN LoadNote_1 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_2
			AS LoadNote
			INTO #Tmp_HoldData_Final
			FROM #Tmp_HoldData_Filter		

		/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimUnitId WITH CORRECT VALUE*/
		UPDATE MT
		SET MT.DimUnitOrginalId=DS.DimDeathCauseUnitId
		FROM #Tmp_HoldData_Final MT
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDeathCauseUnit] DS WITH(NOLOCK) ON DS.Abbr=MT.UnitOriginal

		UPDATE MT
		SET MT.DimUnit1ConvId=DS.DimDeathCauseUnitId
		FROM #Tmp_HoldData_Final MT
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDeathCauseUnit] DS WITH(NOLOCK) ON DS.Abbr=MT.Unit1Conv

		UPDATE MT
		SET MT.DimUnit2ConvId=DS.DimDeathCauseUnitId
		FROM #Tmp_HoldData_Final MT
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDeathCauseUnit] DS WITH(NOLOCK) ON DS.Abbr=MT.Unit2Conv

		/**************************************************************Other Validations STARTS*************************************************************/
			/*UPDATING LOAD NOTE FOR THE RECORDS WHERE WE HAVE SOME ISSUES WITH CHILD RECORD HOWEVER THE PARENT LOAD IS FINE.*/

			--scenario 2 & 3
			UPDATE #Tmp_HoldData_Final
			SET LoadNote=CASE WHEN LoadNote!='' THEN 'Person|ParentMissing:Validation Warning' + ' || ' + LoadNote ELSE '' END
				WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log)


			--scenario 4
			UPDATE #Tmp_HoldData_Final								
			SET DeathCause_Log_Flag = 1
		   ,LoadNote=CASE WHEN LoadNote!='' 
				THEN 'Person|ParentMissing:Not Processed' + ' || ' + LoadNote ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL 
			AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
			AND DeathCause_Log_Flag = 0

			SET @TotalParentMissingRecords=@@rowcount

			IF @TotalParentMissingRecords>0 
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
		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathCause]
		(
				 PersonId	
				,CauseOrder	
				,Cause	
				,IntervalOrginal	
				,DimUnitOrginalId	
				,IntervalTypeConv	
				,Interval1Conv	
				,Interval2Conv	
				,DimUnit1ConvId	
				,DimUnit2ConvId	
				,CreatedDate	
				,OtherCause	
				,LoadNote
		)
		SELECT PersonId	
			   ,CauseOrder	
			   ,Cause	
			   ,IntervalOrginal	
			   ,DimUnitOrginalId	
			   ,IntervalTypeConv	
			   ,Interval1Conv	
			   ,Interval2Conv
			   ,DimUnit1ConvId	
			   ,DimUnit2ConvId
			   ,CreatedDate	
			   ,OtherCause
			   ,LoadNote
		FROM #Tmp_HoldData_Final
		WHERE DeathCause_Log_Flag = 0

	SET @TotalLoadedRecord = @@ROWCOUNT

		INSERT INTO [RVRS].[DeathCause_Log]
		(
				 SrId
				,PersonId	
				,CauseOrder	
				,Cause	
				,IntervalOrginal	
				,DimUnitOrginalId	
				,IntervalTypeConv	
				,Interval1Conv	
				,Interval2Conv	
				,DimUnit1ConvId	
				,DimUnit2ConvId	
				,CreatedDate	
				,OtherCause	
				,LoadNote
		)
		SELECT  SrId
			   ,PersonId	
			   ,CauseOrder	
			   ,Cause	
			   ,IntervalOrginal	
			   ,DimUnitOrginalId	
			   ,IntervalTypeConv	
			   ,Interval1Conv	
			   ,Interval2Conv
			   ,DimUnit1ConvId	
			   ,DimUnit2ConvId
			   ,CreatedDate	
			   ,OtherCause
			   ,LoadNote
		FROM #Tmp_HoldData_Final
		WHERE DeathCause_Log_Flag = 1

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
