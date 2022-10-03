


IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_DeathCauseAcmePr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathCauseAcmePr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_DeathCauseAcmePr]
AS 

/*
NAME	: Load_VIP_DeathCauseAcmePr
AUTHOR	: SAILENDRA SINGH
CREATED	: 25 MAY 2022
PURPOSE	: TO LOAD DATA INTO FACT DeathCauseAcme TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE			NAME						DESCRIPTION
25 MAY 2022		SAILENDRA SINGH				RVRS-162 : LOAD DECEDENT CAUSE OF DEATH DATA FROM STAGING TO ODS

EXEC RVRS.Load_VIP_DeathCauseAcmePr
*/

BEGIN
	PRINT '1'
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

SELECT 'DeathCauseAcme' AS Entity
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
	BEGIN TRY

		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData

		IF OBJECT_ID('tempdb..#Tmp_HoldData_Filter') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Filter

		IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathCauseAcme' AND ExecutionStatus='Completed')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(SrCreatedDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'


		SELECT TOP 100 DEATH_REC_ID AS SrID
			    ,P.PersonId
			    ,1 AS [Order]	
				,LINE1 AS Line	
				,SEQ1 AS [Sequence]
				,CAUSE_CATEGORY1 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG1 AS InjuryNature	
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate INTO #Tmp_HoldData
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND VRV_REGISTERED_FLAG =1
		AND FL_CURRENT =1
		AND FL_VOIDED=0
		AND (LINE1 IS NOT NULL OR SEQ1 IS NOT NULL OR CAUSE_CATEGORY1 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,2 AS [Order]	
				,LINE2 AS Line	
				,SEQ2 AS [Sequence]	
				,CAUSE_CATEGORY2 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG2 AS InjuryNature	
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE2 IS NOT NULL OR SEQ2 IS NOT NULL OR CAUSE_CATEGORY2 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,3 AS [Order]	
				,LINE3 AS Line	
				,SEQ3 AS [Sequence]	
				,CAUSE_CATEGORY3 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG3 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE3 IS NOT NULL OR SEQ3 IS NOT NULL OR CAUSE_CATEGORY3 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,4 AS [Order]	
				,LINE4 AS Line	
				,SEQ4 AS [Sequence]	
				,CAUSE_CATEGORY3 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG4 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE4 IS NOT NULL OR SEQ4 IS NOT NULL OR CAUSE_CATEGORY4 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,5 AS [Order]	
				,LINE5 AS Line	
				,SEQ5 AS [Sequence]	
				,CAUSE_CATEGORY5 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG5 AS InjuryNature	
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE5 IS NOT NULL OR SEQ5 IS NOT NULL OR CAUSE_CATEGORY5 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,6 AS [Order]	
				,LINE6 AS Line	
				,SEQ6 AS [Sequence]	
				,CAUSE_CATEGORY6 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG6 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE6 IS NOT NULL OR SEQ6 IS NOT NULL OR CAUSE_CATEGORY6 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,7 AS [Order]	
				,LINE7 AS Line	
				,SEQ7 AS [Sequence]	
				,CAUSE_CATEGORY7 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG7 AS InjuryNature	
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE7 IS NOT NULL OR SEQ7 IS NOT NULL OR CAUSE_CATEGORY7 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,8 AS [Order]	
				,LINE8 AS Line	
				,SEQ8 AS [Sequence]	
				,CAUSE_CATEGORY8 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG8 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE8 IS NOT NULL OR SEQ8 IS NOT NULL OR CAUSE_CATEGORY8 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,9 AS [Order]	
				,LINE9 AS Line	
				,SEQ9 AS [Sequence]
				,CAUSE_CATEGORY9 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG9 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE9 IS NOT NULL OR SEQ9 IS NOT NULL OR CAUSE_CATEGORY9 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,10 AS [Order]	
				,LINE10 AS Line	
				,SEQ10 AS [Sequence]	
				,CAUSE_CATEGORY10 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG10 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE10 IS NOT NULL OR SEQ10 IS NOT NULL OR CAUSE_CATEGORY10 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,11 AS [Order]	
				,LINE11 AS Line	
				,SEQ11 AS [Sequence]	
				,CAUSE_CATEGORY11 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG11 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE11 IS NOT NULL OR SEQ11 IS NOT NULL OR CAUSE_CATEGORY11 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,12 AS [Order]	
				,LINE12 AS Line	
				,SEQ12 AS [Sequence]	
				,CAUSE_CATEGORY12 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG12 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE12 IS NOT NULL OR SEQ12 IS NOT NULL OR CAUSE_CATEGORY12 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,13 AS [Order]	
				,LINE13 AS Line	
				,SEQ13 AS [Sequence]	
				,CAUSE_CATEGORY13 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG13 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE13 IS NOT NULL OR SEQ13 IS NOT NULL OR CAUSE_CATEGORY13 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,14 AS [Order]	
				,LINE14 AS Line	
				,SEQ14 AS [Sequence]	
				,CAUSE_CATEGORY14 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG14 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE14 IS NOT NULL OR SEQ14 IS NOT NULL OR CAUSE_CATEGORY14 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,15 AS [Order]	
				,LINE15 AS Line	
				,SEQ15 AS [Sequence]	
				,CAUSE_CATEGORY15 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG15 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE15 IS NOT NULL OR SEQ15 IS NOT NULL OR CAUSE_CATEGORY15 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,16 AS [Order]	
				,LINE16 AS Line	
				,SEQ16 AS [Sequence]	
				,CAUSE_CATEGORY16 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG16 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE16 IS NOT NULL OR SEQ16 IS NOT NULL OR CAUSE_CATEGORY16 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,17 AS [Order]	
				,LINE17 AS Line	
				,SEQ17 AS [Sequence]	
				,CAUSE_CATEGORY17 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG17 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE17 IS NOT NULL OR SEQ17 IS NOT NULL OR CAUSE_CATEGORY17 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,18 AS [Order]	
				,LINE18 AS Line	
				,SEQ18 AS [Sequence]	
				,CAUSE_CATEGORY18 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG18 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE18 IS NOT NULL OR SEQ18 IS NOT NULL OR CAUSE_CATEGORY18 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,19 AS [Order]	
				,LINE19 AS Line	
				,SEQ19 AS [Sequence]	
				,CAUSE_CATEGORY19 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG19 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE19 IS NOT NULL OR SEQ19 IS NOT NULL OR CAUSE_CATEGORY19 IS NOT NULL)

		UNION ALL

		SELECT TOP 100 DEATH_REC_ID AS SrID
				,P.PersonId
				,20 AS [Order]	
				,LINE20 AS Line	
				,SEQ20 AS [Sequence]	
				,CAUSE_CATEGORY20 AS CauseCategory	
				,NATURE_OF_INJURY_FLAG20 AS InjuryNature
				,VRV_DATE_CHANGED AS SrUpdatedDate
				,@CurentTime AS CreatedDate
		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
		AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
		AND D.VRV_RECORD_TYPE_ID = '040'
		AND D.RECORD_REGIS_DATE IS NOT NULL
		AND D.VRV_REGISTERED_FLAG =1
		AND D.FL_CURRENT =1
		AND D.FL_VOIDED=0
		AND (LINE20 IS NOT NULL OR SEQ20 IS NOT NULL OR CAUSE_CATEGORY20 IS NOT NULL)


SET @TotalProcessedRecords = @@ROWCOUNT
		--ALTER TABLE #Tmp_HoldData ADD DeathCauseAcme_Log_LoadNote VARCHAR(2000)
	
		PRINT @TotalProcessedRecords
		IF @TotalProcessedRecords=0
		BEGIN
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

		IF EXISTS(SELECT SrId FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] WHERE CAST(SrUpdatedDate AS DATE)<=@MaxDateinData)

		BEGIN
		SET @LastLoadedDate = @MaxDateinData


				SELECT SrID
					,PersonId
					,[Order]	
					,Line	
					,[Sequence]	
					,CauseCategory	
					,InjuryNature
					,SrUpdatedDate
					,CreatedDate
					,CASE WHEN (CauseCategory IS NULL AND Line IS NOT NULL) OR (CauseCategory IS NOT NULL AND Line IS NULL)
						  THEN 'CAUSE_CATEGORY,LINE|Error:Cause of Death Category and Line mismatch'
						  ELSE '' END AS LoadNote
					,CASE WHEN (CauseCategory IS NULL AND [Sequence] IS NOT NULL) OR (CauseCategory IS NOT NULL AND [Sequence] IS NULL) 
						  THEN 'CAUSE_CATEGORY,SEQ|Error:Cause of Death Category and Sequence mismatch'
						  ELSE '' END AS LoadNote_1						 
					,CASE WHEN CauseCategory IS NULL AND InjuryNature IS NOT NULL 
						  THEN 'CAUSE_CATEGORY,NATURE_OF_INJURY_FLAG|Error:Cause of Death Category and Injury Nature mismatch'
						  ELSE '' END AS LoadNote_2
					,CASE WHEN LEFT(CauseCategory,1) LIKE '[^a-zA-Z]' THEN 'CAUSE_CATEGORY|Warning: Cause of Death Category does not start with alphabet'
						  ELSE '' END AS LoadNote_3
				INTO #Tmp_HoldData_Filter
				FROM #Tmp_HoldData


				SELECT SrID
					,PersonId
					,[Order]	
					,Line	
					,[Sequence]	
					,CauseCategory	
					,InjuryNature
					,SrUpdatedDate
					,CreatedDate
					,CASE WHEN LoadNote<>'' OR LoadNote_1<>'' OR LoadNote_2<>'' 
						  THEN 1 ELSE 0 END AS DeathCauseAcme_Log_Flag
					,LoadNote +
						(CASE WHEN LoadNote <> '' THEN ' || ' ELSE '' END) +
						LoadNote_1 +
						(CASE WHEN LoadNote_1 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_2 +
						(CASE WHEN LoadNote_2 <> '' THEN ' || ' ELSE '' END) +
						LoadNote_3 
						AS DeathCauseAcme_Log_LoadNote
					,LoadNote_3 AS LoadNote
					INTO #Tmp_HoldData_Final
					FROM #Tmp_HoldData_Filter


		/**************************************************************Other Validations STARTS*************************************************************/
			/*UPDATING LOAD NOTE FOR THE RECORDS WHERE WE HAVE SOME ISSUES WITH CHILD RECORD HOWEVER THE PARENT LOAD IS FINE*/

			--scenario 1
			--UPDATE P
			--SET P.LoadNote= 'DeathCauseAcme|MissingChild:ChildMissing DeathCauseAcme' + CASE WHEN P.LoadNote!='' THEN ' || ' + P.LoadNote ELSE '' END 
			--FROM #Tmp_HoldData_Final HF
			--JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
			--WHERE HF.DeathCauseAcme_Log_Flag=1
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
				  --AND  LoadNote!=''

		/***************************************************************Other Validations ENDS**************************************************************/

		SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathCauseAcme]
			(
				PersonId
				,[Order]
				,Line
				,[Sequence]
				,CauseCategory
				,InjuryNature
				,CreatedDate	
				,LoadNote
			)
			SELECT PersonId
				,[Order]
				,Line
				,[Sequence]
				,CauseCategory
				,InjuryNature
				,CreatedDate	
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE PersonId IS NOT NULL
			AND DeathCauseAcme_Log_Flag = 0

SET @TotalLoadedRecord = @@ROWCOUNT

			INSERT INTO [RVRS].[DeathCauseAcme_LOG]
			(
				 PersonId
				,SrId
				,[Order]
				,Line
				,[Sequence]
				,CauseCategory
				,InjuryNature
				,CreatedDate	
				,LoadNote
			)
			SELECT PersonId
				,SrId
				,[Order]
				,Line
				,[Sequence]
				,CauseCategory
				,InjuryNature
				,CreatedDate	
				,DeathCauseAcme_Log_LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathCauseAcme_Log_Flag=1
			OR PersonId IS NULL

			SET @TotalErrorRecord = @@ROWCOUNT

			SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote LIKE '%|Pending Review%')
			SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'	AND LoadNote LIKE '%|WARNING%')

			UPDATE [RVRS].[Execution]
			SET ExecutionStatus=@ExecutionStatus
				,LastLoadDate=@LastLoadedDate
				,EndTime=@CurentTime
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
				,EndTime=@CurentTime
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
			,EndTime=@CurentTime
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