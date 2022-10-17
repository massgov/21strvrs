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
---------------------------------------------------------------------------------------------------------
DATE		NAME						DESCRIPTION
06 JUN 2022	SAILENDRA					RVRS 162- : LOAD DECEDENT CAUSE OF DEATH DATA FROM STAGING TO ODS

EXEC RVRS.Load_VIP_DeathCausePr

TRUNCATION
DELETE FROM RVRS.EXECUTION WHERE Entity = 'DeathCause'
TRUNCATE TABLE RVRS.DEATHCAUSE_LOG
TRUNCATE TABLE RVRS.DEATHCAUSE
DELETE FROM RVRS.DEATHORIGINAL WHERE Entity = 'DeathCause'
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
			  ,'A' AS CauseOrder
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODIA AS Cause	
			  ,D.INTIA AS IntervalOrginal	
			  ,COALESCE(D.UNITA,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId	
			  ,NULL AS DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
			  into #Tmp_HoldData 
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODIA IS NOT NULL OR D.INTIA IS NOT NULL OR D.UNITA IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId		  
			  ,'B' AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODIB AS Cause	
			  ,D.INTIB AS IntervalOrginal	
			  ,COALESCE(D.UNITB,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId	
			  ,NULL AS DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODIB IS NOT NULL OR D.INTIB IS NOT NULL OR D.UNITB IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId	
			  ,'C' AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODIC AS Cause	
			  ,D.INTIC AS IntervalOrginal	
			  ,COALESCE(D.UNITC,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId	
			  ,NULL AS DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODIC IS NOT NULL OR D.INTIC IS NOT NULL OR D.UNITC IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId	
			  ,'D' AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CODID AS Cause	
			  ,D.INTID AS IntervalOrginal	
			  ,COALESCE(D.UNITD,'NULL') AS UnitOriginal
			  ,NULL AS DimUnitOrginalId 	
			  ,NULL AS  DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND (D.CODID IS NOT NULL OR D.INTID IS NOT NULL OR D.UNITD IS NOT NULL)

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId	
			  ,'OTHER' AS CauseOrder	
			  ,D.CERT_DESIG as CertDesig
			  ,D.CONDII AS Cause	
			  ,NULL AS IntervalOrginal	
			  ,'NULL' AS UnitOriginal
			  ,NULL AS DimUnitOrginalId 	
			  ,NULL AS  DimUnit1ConvId	
			  ,NULL AS DimUnit2ConvId
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.VRV_REGISTERED_FLAG =1
			  AND D.FL_CURRENT =1
		      AND D.FL_VOIDED=0
			  AND CONDII IS NOT NULL

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
			  ,COALESCE(DC.Unit1,'NULL') AS Unit1Conv	
			  ,COALESCE(DC.Unit2,'NULL') AS Unit2Conv 
			  ,DimUnit1ConvId	
			  ,DimUnit2ConvId
			  ,CreatedDate	
			  ,SrCreatedDate
			  ,SrUpdatedDate
			  ,CASE WHEN CertDesig = 'MEDICAL EXAMINER'  AND CAUSE = 'PENDING' AND CAUSEORDER !='A' 
					THEN '|| CertDesig,Cause|Error:Certifier is ME and CauseStatus is ''Pending'' but other Causes have value' ELSE '' END AS LoadNote
			  ,CASE WHEN Cause = 'PENDING' and CertDesig != 'MEDICAL EXAMINER' 
					THEN '|| CertDesig,Cause|Error:CauseStatus is ''Pending'' but Certifier is NOT ME' ELSE '' END AS LoadNote_1
			  ,CASE WHEN Cause IS NULL AND (IntervalOrginal IS NOT NULL OR UnitOriginal IS NOT NULL) 
					THEN '|| Cause,IntervalOrginal,UnitOriginal|Error: Cause of death is blank but the interval or unit have value' ELSE '' END AS LoadNote_2
			  		INTO #Tmp_HoldData_Filter
		FROM #Tmp_HoldData HD
		LEFT JOIN [RVRS].[DeathCauseInterval_Data_Conversion] DC on HD.IntervalOrginal = DC.Interval

		SET @TotalProcessedRecords = @@ROWCOUNT
		
		PRINT '5'

		SELECT SrId
			  ,PersonId	
			  ,CertDesig
			  ,CauseOrder	
			  ,Cause
			  ,NULL AS CAUSE_DC
			  ,IntervalOrginal	
			  ,UnitOriginal
			  ,DimUnitOrginalId	
			  ,IntervalTypeConv AS IntervalTypeConv	
			  ,Interval1Conv AS Interval1Conv	
			  ,Interval2Conv AS Interval2Conv
			  ,Unit1Conv
			  ,Unit2Conv
			  ,DimUnit1ConvId	
			  ,DimUnit2ConvId
			  ,CreatedDate	
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
			,0 AS CAUSE_DC_FLAG
			INTO #Tmp_HoldData_Final
			FROM #Tmp_HoldData_Filter	
			
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN CAUSE_DC VARCHAR(240) --BY DEFAULT THIS COLUMN IS BEING DEFINED AS INT SO CHANGING IT TO VARCHAR

		PRINT '6'

		/*THIS CODE IS TO GET MATCH FROM DimDeathCauseUnit TABLE AND UPDATE THE DimUnitId WITH CORRECT VALUE*/
		UPDATE MT
		SET MT.DimUnitOrginalId=DS.DimDeathCauseUnitId			
		FROM #Tmp_HoldData_Final MT
		INNER JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDeathCauseUnit] DS WITH(NOLOCK) ON DS.Abbr=MT.UnitOriginal

		UPDATE MT
		SET MT.DimUnit1ConvId=DS.DimDeathCauseUnitId
		FROM #Tmp_HoldData_Final MT
		INNER JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDeathCauseUnit] DS WITH(NOLOCK) ON DS.Abbr=MT.Unit1Conv

		UPDATE MT
		SET MT.DimUnit2ConvId=DS.DimDeathCauseUnitId
		FROM #Tmp_HoldData_Final MT
		INNER JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDeathCauseUnit] DS WITH(NOLOCK) ON DS.Abbr=MT.Unit2Conv

		PRINT '7'

		/*UPDATING THE DeathCause_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE DimUnitId*/
		UPDATE #Tmp_HoldData_Final
		SET DeathCause_Log_Flag=1
			,LoadNote=CASE WHEN LoadNote!='' THEN LoadNote +' || ' ELSE '' END +
				'DimUnitOrginalId|Pending Review:Not a valid DimUnitOrginalId'
		WHERE DimUnitOrginalId IS NULL

		UPDATE #Tmp_HoldData_Final
		SET DeathCause_Log_Flag=1
			,LoadNote=CASE WHEN LoadNote!='' THEN LoadNote +' || ' ELSE '' END +
				'DimUnit1ConvId|Pending Review:Not a valid DimUnit1ConvId'
		WHERE DimUnit1ConvId IS NULL

		UPDATE #Tmp_HoldData_Final
		SET DeathCause_Log_Flag=1
			,LoadNote=CASE WHEN LoadNote!='' THEN LoadNote +' || ' ELSE '' END +
				'DimUnit2ConvId|Pending Review:Not a valid DimUnit2ConvId'
		WHERE DimUnit2ConvId IS NULL


		PRINT '8'
		/****************************************************************Code For Cause Other Starts********************************************************/
		/*MATCH OTHER CAUSE WITH RECORDS IN RVRS.Data_Conversion TABLE FOR STANDARIZATION*/
		UPDATE PD
		SET PD.CAUSE_DC=DC.Mapping_Current
		,PD.CAUSE_DC_FLAG = 1
		,PD.LoadNote=ISNULL(PD.LoadNote,'')+' || ' + 'Cause|Warning:Other Cause got value from data conversion'
		 FROM #Tmp_HoldData_Final PD
		JOIN RVRS.Data_Conversion DC WITH(NOLOCK) ON DC.Mapping_Previous=PD.CAUSE
		AND DC.TableName='DeathCause_Other' 
		WHERE PD.CauseOrder = 'OTHER'

		SET @RecordCountDebug=@@ROWCOUNT

		PRINT '9'
		/**************************************************************Other Validations STARTS*************************************************************/
			/*UPDATING LOAD NOTE FOR THE RECORDS WHERE WE HAVE SOME ISSUES WITH CHILD RECORD HOWEVER THE PARENT LOAD IS FINE.*/

			--scenario 2 & 3
			UPDATE #Tmp_HoldData_Final
			SET LoadNote=CASE WHEN LoadNote!='' THEN 'Person|ParentMissing:Validation Warning' + ' || ' + LoadNote ELSE '' END
				WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log)

			--scenario 5
			UPDATE #Tmp_HoldData_Final
				SET LoadNote=CASE WHEN LoadNote!='' THEN 'Person|ParentMissing:Not Processed'+' || '+ LoadNote
					ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL
				  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
				  AND  LoadNote!=''

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


		PRINT '10'
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
				,LoadNote
		)
		SELECT PersonId	
			   ,CauseOrder	
			   ,COALESCE(Cause_DC,Cause)	
			   ,IntervalOrginal	
			   ,DimUnitOrginalId	
			   ,IntervalTypeConv	
			   ,Interval1Conv	
			   ,Interval2Conv
			   ,DimUnit1ConvId	
			   ,DimUnit2ConvId
			   ,CreatedDate	
			   ,LoadNote
		FROM #Tmp_HoldData_Final
		WHERE DeathCause_Log_Flag = 0

	SET @TotalLoadedRecord = @@ROWCOUNT


	PRINT '11'
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
				,LoadNote
		)
		SELECT  SrId
			   ,PersonId	
			   ,CauseOrder	
			   ,COALESCE(Cause_DC, Cause)	
			   ,IntervalOrginal	
			   ,DimUnitOrginalId	
			   ,IntervalTypeConv	
			   ,Interval1Conv	
			   ,Interval2Conv
			   ,DimUnit1ConvId	
			   ,DimUnit2ConvId
			   ,CreatedDate	
			   ,LoadNote
		FROM #Tmp_HoldData_Final
		WHERE DeathCause_Log_Flag = 1

		SET @TotalErrorRecord = @@ROWCOUNT

		SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote LIKE '%|Pending Review%')
		SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'	AND LoadNote LIKE '%|WARNING%')

			PRINT '12'
		
		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR Death Cause Other*/
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
			,'DeathCause' AS Entity
			,'DeathCauseId' AS EntityColumnName
			,PA.DeathCauseId AS EntityId
			,'Cause' AS ConvertedColumn
			,MT.Cause AS OriginalValue
			,MT.Cause_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathCause] PA ON PA.PersonId=MT.PersonId
		WHERE MT.CAUSE_DC_FLAG=1

			PRINT '13'
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
