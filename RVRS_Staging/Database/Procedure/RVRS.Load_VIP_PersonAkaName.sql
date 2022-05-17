IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_PersonAkaNamePr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_PersonAkaNamePr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_PersonAkaNamePr]
AS 

/*
NAME	: Load_VIP_PersonAkaNamePr
AUTHOR	: SAILENDRA
CREATED	: 05 APR 2022
PURPOSE	: TOLOAD DATA INTO FACT PERSONAKANAME TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE		NAME						DESCRIPTION
05 Apr 2022	SAILENDRA					RVRS-159 : LOAD DECEDENT BASIC DATA FROM STAGING TO ODS

EXEC RVRS.Load_VIP_PersonAkaNamePr
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
	SELECT 'PersonAKAName' AS Entity
		,'In Progress' AS ExecutionStatus
		,NULL AS LastLoadDate
		,GETDATE() AS StartTime
		,NULL AS EndTime
		,NULL AS TotalProcessedRecords
		,NULL AS TotalLoadedRecord
		,NULL AS TotalErrorRecord
		,NULL AS TotalPendingReviewRecord
		,NULL AS TotalWarningRecord

	SET @ExecutionId = (SELECT IDENT_CURRENT('RVRS.Execution'))
		
	PRINT '2'

	BEGIN TRY
		PRINT '3'

		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
		IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='PersonAKAName' AND ExecutionStatus='Completed')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(SrCreatedDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'
			PRINT @LastLoadedDate
			PRINT '4'
	
		SELECT DEATH_REC_ID AS SrId
			,P.PersonId
			,1 AS AkaOrder
			,D.AKA1_FNAME AS FirstName
			,D.AKA1_MNAME AS MiddleName
			,D.AKA1_LNAME AS LastName
			,ISNULL(D.AKA1_SUFFIX,'NULL') AS LOOKUP_SuffixDesc
			,NULL AS LOOKUP_SuffixDesc_DC
			,NULL AS DimSuffixId
			,0 AS DimSuffixId_Flag
			,NULL AS NameChangedDate
			,@CurentTime AS CreatedDate 
			,VRV_REC_DATE_CREATED AS SrCreatedDate INTO #Tmp_HoldData
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_REC_DATE_CREATED AS DATE) > @LastLoadedDate
			AND CAST(VRV_REC_DATE_CREATED AS DATE) != CAST(GETDATE() AS DATE)
			AND D.AKA1_FNAME IS NOT NULL AND D.AKA1_MNAME IS NOT NULL AND D.AKA1_LNAME IS NOT NULL
			AND D.VRV_RECORD_TYPE_ID = '040'
			AND D.RECORD_REGIS_DATE IS NOT NULL
			AND VRV_REC_DATE_CREATED<='2021-10-4'

		UNION ALL

		SELECT DEATH_REC_ID AS SrId
			,P.PersonId
			,2 AS AkaOrder
			,AKA2_FNAME AS FirstName
			,AKA2_MNAME AS MiddleName
			,AKA2_LNAME AS LastName
			,ISNULL(D.AKA2_SUFFIX,'NULL') AS LOOKUP_SuffixDesc
			,NULL AS LOOKUP_SuffixDesc_DC
			,NULL AS DimSuffixId
			,0 AS DimSuffixId_Flag
			,NULL AS NameChangedDate
			,@CurentTime AS CreatedDate
			,VRV_REC_DATE_CREATED AS SrCreatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_REC_DATE_CREATED AS DATE) > @LastLoadedDate
			AND CAST(VRV_REC_DATE_CREATED AS DATE) != CAST(GETDATE() AS DATE)
			AND D.AKA2_FNAME IS NOT NULL AND D.AKA2_MNAME IS NOT NULL AND D.AKA2_LNAME IS NOT NULL
			AND D.VRV_RECORD_TYPE_ID = '040'
			AND D.RECORD_REGIS_DATE IS NOT NULL
			AND VRV_REC_DATE_CREATED<='2021-10-4'

		UNION ALL

		SELECT DEATH_REC_ID AS SrId
			,P.PersonId
			,3 AS AkaOrder
			,AKA3_FNAME AS FirstName
			,AKA3_MNAME AS MiddleName
			,AKA3_LNAME AS LastName
			,ISNULL(D.AKA3_SUFFIX,'NULL') AS LOOKUP_SuffixDesc
			,NULL AS LOOKUP_SuffixDesc_DC
			,NULL AS DimSuffixId
			,0 AS DimSuffixId_Flag
			,NULL AS NameChangedDate
			,@CurentTime AS CreatedDate
			,VRV_REC_DATE_CREATED AS SrCreatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_REC_DATE_CREATED AS DATE) > @LastLoadedDate
			AND CAST(VRV_REC_DATE_CREATED AS DATE) != CAST(GETDATE() AS DATE)
			AND D.AKA3_FNAME IS NOT NULL AND D.AKA3_MNAME IS NOT NULL AND D.AKA3_LNAME IS NOT NULL
			AND D.VRV_RECORD_TYPE_ID = '040'
			AND D.RECORD_REGIS_DATE IS NOT NULL
			AND VRV_REC_DATE_CREATED<='2021-10-4'

		UNION ALL

		SELECT DEATH_REC_ID AS SrId
			,P.PersonId
			,4 AS AkaOrder
			,AKA4_FNAME AS FirstName
			,AKA4_MNAME AS MiddleName
			,AKA4_LNAME AS LastName
			,ISNULL(D.AKA4_SUFFIX,'NULL') AS LOOKUP_SuffixDesc
			,NULL AS LOOKUP_SuffixDesc_DC
			,NULL AS DimSuffixId
			,0 AS DimSuffixId_Flag
			,NULL AS NameChangedDate
			,@CurentTime AS CreatedDate
			,VRV_REC_DATE_CREATED AS SrCreatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_REC_DATE_CREATED AS DATE) > @LastLoadedDate
			AND CAST(VRV_REC_DATE_CREATED AS DATE) != CAST(GETDATE() AS DATE)
			AND D.AKA4_FNAME IS NOT NULL AND D.AKA4_MNAME IS NOT NULL AND D.AKA4_LNAME IS NOT NULL
			AND D.VRV_RECORD_TYPE_ID = '040'
			AND D.RECORD_REGIS_DATE IS NOT NULL
			AND VRV_REC_DATE_CREATED<='2021-10-4'

		SET @TotalProcessedRecords = @@ROWCOUNT
		ALTER TABLE #Tmp_HoldData ADD PersonAKA_Log_LoadNote VARCHAR(2000)
		ALTER TABLE #Tmp_HoldData ALTER COLUMN LOOKUP_SuffixDesc_DC VARCHAR(128) NULL

		
		PRINT @TotalProcessedRecords
		IF @TotalProcessedRecords=0
		BEGIN
		PRINT'ERROR'

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

		SET @MaxDateinData = (SELECT MAX(SrCreatedDate) FROM #Tmp_HoldData)

		IF EXISTS(SELECT SrId FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] WHERE CAST(SrCreatedDate AS DATE)<=@MaxDateinData)

		BEGIN
		SET @LastLoadedDate = @MaxDateinData
		PRINT '5'		

		/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE*/
		UPDATE MT
		SET MT.DimSuffixId=DS.DimSuffixId
		FROM #Tmp_HoldData MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS ON DS.SuffixDesc=MT.LOOKUP_SuffixDesc
	
		PRINT '6'

		/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
			FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix TABLE*/
		UPDATE MT
		SET MT.DimSuffixId=DS.Mapping_Current_ID
			,LOOKUP_SuffixDesc_DC=DS.Mapping_Current
			,MT.DimSuffixId_Flag=1
			,MT.PersonAKA_Log_LoadNote='DimSuffixId|Warning:Suffix got value from data conversion'
		FROM #Tmp_HoldData MT
		JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_SuffixDesc
		WHERE DS.TableName='DimSuffix'
			AND MT.DimSuffixId IS NULL

		PRINT '7'

		SELECT SrId
			,PersonId
			,AkaOrder
			,FirstName
			,MiddleName
			,LastName
			,LOOKUP_SuffixDesc
			,LOOKUP_SuffixDesc_DC
			,DimSuffixId
			,DimSuffixId_Flag
			,NameChangedDate
			,CreatedDate
			,CASE WHEN FirstName ='---' THEN 0
			 WHEN FirstName NOT LIKE '-%' AND FirstName LIKE '%-%' THEN 0
			 WHEN LEFT(FirstName,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
			 END
			 AS FirstName_Flag
			,NULL AS FirstName_DC
			,CASE WHEN MiddleName ='---' THEN 0
				  WHEN MiddleName NOT LIKE '-%' AND MiddleName LIKE '%-%' THEN 0
				  WHEN LEFT(MiddleName,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
				  END
			AS MiddleName_Flag
			,NULL AS MiddleName_DC
			,CASE WHEN LastName ='---' THEN 0
				  WHEN LastName NOT LIKE '-%' AND LastName LIKE '%-%' THEN 0
				  WHEN LEFT(LastName,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
			 END
			 AS LastName_Flag
			,NULL AS LastName_DC
			,0 AS PersonAKA_log_Flag
			,PersonAKA_Log_LoadNote AS PersonAKA_Log_LoadNote INTO #Tmp_HoldData_Final
		FROM #Tmp_HoldData

		PRINT '8'

		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN FirstName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN MiddleName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN LastName_DC VARCHAR(128)

		PRINT '9'

		/*UPDATING THE Person_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
		UPDATE #Tmp_HoldData_Final
		SET PersonAKA_log_Flag=1
			,PersonAKA_Log_LoadNote=CASE WHEN PersonAKA_Log_LoadNote!='' THEN PersonAKA_Log_LoadNote+' || ' ELSE '' END+
				'DimSuffixId|Pending Review:Not a valid Suffix'
		WHERE DimSuffixId IS NULL

		/*************************************************************Code For FirstName STARTS*************************************************************/
			PRINT '18'
			/*MATCH FirstName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.FirstName_DC=DC.Mapping_Current
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.FirstName
				AND DC.TableName='Person_AKA_FirstName'
			WHERE FirstName_Flag=1

			PRINT '19'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.PersonAKA_Log_LoadNote=MT.PersonAKA_Log_LoadNote+' || '+'FirstName|Warning:First Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE FirstName_Flag=1
				AND FirstName_DC IS NOT NULL

			PRINT '20'

			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET PersonAKA_log_Flag=1
				,PersonAKA_Log_LoadNote=CASE WHEN PersonAKA_Log_LoadNote!='' THEN PersonAKA_Log_LoadNote+' || ' ELSE '' END+
					'FirstName|Error:Not a valid first name'
			WHERE FirstName_Flag=1
				AND FirstName_DC IS NULL

		/**************************************************************Code For FirstName ENDS**************************************************************/





		/*************************************************************Code For MiddleName STARTS************************************************************/
			PRINT '21'
			/*MATCH MiddleName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.MiddleName_DC=DC.Mapping_Current
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.MiddleName
				AND DC.TableName='Person_AKA_MiddleName'
			WHERE MiddleName_Flag=1

			PRINT '22'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.PersonAKA_Log_LoadNote=MT.PersonAKA_Log_LoadNote+' || '+'MiddleName|Warning:Middle Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE MiddleName_Flag=1
				AND MiddleName_DC IS NOT NULL

			PRINT '23'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET PersonAKA_log_Flag=1
				,PersonAKA_Log_LoadNote=CASE WHEN PersonAKA_Log_LoadNote!='' THEN PersonAKA_Log_LoadNote+' || ' ELSE '' END+
					'MiddleName|Error:Not a valid middle name'
			WHERE MiddleName_Flag=1
				AND MiddleName_DC IS NULL
		/**************************************************************Code For MiddleName ENDS*************************************************************/





		/**************************************************************Code For LastName STARTS*************************************************************/
			PRINT '24'
			/*MATCH LastName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.LastName_DC=DC.Mapping_Current
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.LastName
				AND DC.TableName='Person_AKA_LastName'
			WHERE LastName_Flag=1

			PRINT '25'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.PersonAKA_Log_LoadNote=MT.PersonAKA_Log_LoadNote+' || '+'LastName|Warning:Last Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE LastName_Flag=1
				AND LastName_DC IS NOT NULL

			PRINT '26'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET PersonAKA_log_Flag=1
				,PersonAKA_Log_LoadNote=CASE WHEN PersonAKA_Log_LoadNote!='' THEN PersonAKA_Log_LoadNote+' || ' ELSE '' END+
					'LastName|Error:Not a valid last name'
			WHERE LastName_Flag=1
				AND LastName_DC IS NULL
		/***************************************************************Code For LastName ENDS**************************************************************/

		/**************************************************************Other Validations STARTS*************************************************************/
			/*UPDATING LOAD NOTE FOR THE RECORDS WHERE WE HAVE SOME ISSUES WITH HILD RECORD HOWEVER THE PARENT LOAD IS FINE*/
			UPDATE P
			SET LoadNote=CASE WHEN LoadNote!='' THEN LoadNote+' || ' ELSE '' END+'PersonAkaName|Missing:ChildMissing AKA1'
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
				AND HF.AkaOrder=1
			WHERE HF.PersonAKA_log_Flag=1
				AND HF.PersonId IS NOT NULL

			UPDATE P
			SET LoadNote=CASE WHEN LoadNote!='' THEN LoadNote+' || ' ELSE '' END+'PersonAkaName|Missing:ChildMissing AKA2'
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
				AND HF.AkaOrder=2
			WHERE HF.PersonAKA_log_Flag=1
				AND HF.PersonId IS NOT NULL

			UPDATE P
			SET LoadNote=CASE WHEN LoadNote!='' THEN LoadNote+' || ' ELSE '' END+'PersonAkaName|Missing:ChildMissing AKA3'
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
				AND HF.AkaOrder=3
			WHERE HF.PersonAKA_log_Flag=1
				AND HF.PersonId IS NOT NULL

			UPDATE P
			SET LoadNote=CASE WHEN LoadNote!='' THEN LoadNote+' || ' ELSE '' END+'PersonAkaName|Missing:ChildMissing AKA4'
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
				AND HF.AkaOrder=4
			WHERE HF.PersonAKA_log_Flag=1
				AND HF.PersonId IS NOT NULL

			/**/
			UPDATE #Tmp_HoldData_Final
			SET PersonAKA_log_Flag=1
				,PersonAKA_Log_LoadNote=CASE WHEN PersonAKA_Log_LoadNote!='' THEN PersonAKA_Log_LoadNote+' || ' ELSE '' END+
					'Person|ParentMissing:Validation Errors'
			WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log)

			DELETE FROM #Tmp_HoldData_Final WHERE PersonId IS NULL AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
			AND PersonAKA_log_Flag=0

			UPDATE #Tmp_HoldData_Final
			SET PersonAKA_log_Flag=1
				,PersonAKA_Log_LoadNote=CASE WHEN PersonAKA_Log_LoadNote!='' THEN 'Person|ParentMissing:Not Processed'+' || '+PersonAKA_Log_LoadNote
					ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL
				  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
				

			IF EXISTS(SELECT PersonAKA_log_Flag FROM #Tmp_HoldData_Final WHERE PersonId IS NULL AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log))
				SET @ExecutionStatus='Failed'

		/***************************************************************Other Validations ENDS**************************************************************/

		SET @LastLoadDate = (SELECT MAX(SrCreatedDate) FROM #Tmp_HoldData)
		
		PRINT '27'

		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[PersonAkaName]
		(
			 PersonId
			,AkaOrder
			,FirstName
			,MiddleName
			,LastName
			,DimSuffixId
			,NameChangedDate
			,CreatedDate
			,LoadNote
		)
		SELECT PersonId
			,AkaOrder
			,ISNULL(FirstName_DC,FirstName)
			,ISNULL(MiddleName_DC,MiddleName)
			,ISNULL(LastName_DC,LastName)
			,DimSuffixId
			,NameChangedDate
			,CreatedDate
			,PersonAKA_Log_LoadNote
		FROM #Tmp_HoldData_Final
		WHERE PersonAKA_log_Flag=0

		SET @TotalLoadedRecord = @@ROWCOUNT

		PRINT '28'

		INSERT INTO [RVRS].[PersonAkaName_Log]
		(
			 PersonId
			,SrId
			,AkaOrder
			,FirstName
			,MiddleName
			,LastName
			,DimSuffixId
			,NameChangedDate
			,CreatedDate
			,LoadNote
		)
		SELECT PersonId
			,SrId
			,AkaOrder
			,ISNULL(FirstName_DC,FirstName)
			,ISNULL(MiddleName_DC,MiddleName)
			,ISNULL(LastName_DC,LastName)
			,DimSuffixId
			,NameChangedDate
			,CreatedDate
			,PersonAKA_Log_LoadNote
		FROM #Tmp_HoldData_Final
		WHERE PersonAKA_log_Flag=1

		SET @TotalErrorRecord = @@ROWCOUNT

		PRINT '29'

		SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE PersonAKA_log_Flag=1
										AND PersonAKA_Log_LoadNote LIKE '%|Pending Review%')
		SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE PersonAKA_Log_LoadNote NOT LIKE '%|Pending Review%'
									AND PersonAKA_Log_LoadNote LIKE '%|WARNING%')

		PRINT '30'

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimSuffixId*/
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
			,'PersonAKAName' AS Entity
			,'PersonAKANameId' AS EntityColumnName
			,PA.PersonAKANameId AS EntityId
			,'DimSuffixID' AS ConvertedColumn
			,MT.LOOKUP_SuffixDesc AS OriginalValue
			,MT.LOOKUP_SuffixDesc_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[PersonAkaName] PA ON PA.PersonId=MT.PersonId
			AND PA.AkaOrder=MT.AkaOrder
		WHERE MT.DimSuffixId_Flag=1

		PRINT '31'

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR PersonAKAFirstName*/
		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
		(
			 SrId
			,Entity
			,EntityColumnName
			,EntityId
			--,EntityOrder
			,ConvertedColumn
			,OriginalValue
			,ConvertedValue
		)
		SELECT MT.SrId AS SrId
			,'PersonAKAName' AS Entity
			,'PersonAKANameId' AS EntityColumnName
			,PA.PersonAKANameId AS EntityId
			--,MT.AkaOrder AS EntityOrder
			,'FirstName' AS ConvertedColumn			
			,MT.LOOKUP_SuffixDesc AS OriginalValue
			,MT.FirstName_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[PersonAkaName] PA ON PA.PersonId=MT.PersonId
			AND PA.AkaOrder=MT.AkaOrder
		WHERE MT.FirstName_Flag=1
			AND MT.FirstName_DC IS NOT NULL

		PRINT '32'

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR PersonAKAMiddleName*/
		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
		(
			 SrId
			,Entity
			,EntityColumnName
			,EntityId
			--,EntityOrder
			,ConvertedColumn
			,OriginalValue
			,ConvertedValue
		)
		SELECT MT.SrId AS SrId
			,'PersonAKAName' AS Entity
			,'PersonAKANameId' AS EntityColumnName
			,PA.PersonAKANameId AS EntityId
			--,MT.AkaOrder AS EntityOrder
			,'MiddleName' AS ConvertedColumn		
			--,'PersonAKAMiddleName' AS ConvertedColumn
			,MT.LOOKUP_SuffixDesc AS OriginalValue
			,MT.MiddleName_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[PersonAkaName] PA ON PA.PersonId=MT.PersonId
			AND PA.AkaOrder=MT.AkaOrder
		WHERE MiddleName_Flag=1
			AND MiddleName_DC IS NOT NULL

		PRINT '33'

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR PersonAKALastName*/
		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal]
		(
			 SrId
			,Entity
			,EntityColumnName
			,EntityId
			--,EntityOrder
			,ConvertedColumn
			,OriginalValue
			,ConvertedValue
		)
		SELECT MT.SrId AS SrId
			,'PersonAKAName' AS Entity
			,'PersonAKANameId' AS EntityColumnName
			,PA.PersonAKANameId AS EntityId
			--,MT.AkaOrder AS EntityOrder
			,'LastName'AS ConvertedColumn		
			--,'PersonAKALatName' AS ConvertedColumn
			,MT.LOOKUP_SuffixDesc AS OriginalValue
			,MT.LastName_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[PersonAkaName] PA ON PA.PersonId=MT.PersonId
			AND PA.AkaOrder=MT.AkaOrder
		WHERE LastName_Flag=1
			AND LastName_DC IS NOT NULL

		PRINT '34'
		
		UPDATE [RVRS].[Execution]
		SET ExecutionStatus=@ExecutionStatus
			,LastLoadDate=@LastLoadDate
			,EndTime=GETDATE()
			,TotalProcessedRecords=@TotalProcessedRecords
			,TotalLoadedRecord=@TotalLoadedRecord
			,TotalErrorRecord=@TotalErrorRecord
			,TotalPendingReviewRecord=@TotalPendingReviewRecord
			,TotalWarningRecord=@TotalWarningRecord
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
				SET @Err_Message ='We do not have data for '+ CONVERT(VARCHAR(50),@MaxDateinData,106) +' in Person Table'
				RAISERROR (@Err_Message,10,1)
			END

		--PRINT '35'		
		END
	END TRY
	BEGIN CATCH
		PRINT 'CATCH'

		UPDATE [RVRS].[Execution]
		SET ExecutionStatus='Failed'
			,LastLoadDate=@LastLoadDate
			,EndTime=GETDATE()
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

