use rvrs_staging
IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_FamilyMemberPr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_FamilyMemberPr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_FamilyMemberPr]
AS 

/*
NAME	: Load_VIP_PersonAkaNamePr
AUTHOR	: SAILENDRA
CREATED	: 05 APR 2022
PURPOSE	: TOLOAD DATA INTO FACT PERSONAKANAME TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE		NAME						DESCRIPTION
06 JUN 2022	SAILENDRA					RVRS 162- : LOAD DECEDENT FAMILY MEMBER DATA FROM STAGING TO ODS

EXEC RVRS.Load_VIP_FamilyMemberPr
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
	SELECT 'FamilyMember' AS Entity
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
		--PRINT '3'

		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
		IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='FamilyMember' AND ExecutionStatus='Completed')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(SrCreatedDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId
			  ,D.MARITAL AS MaritalStatus
			  ,D.SPOUSE_GNAME AS FirstName
			  ,D.SPOUSE_MNAME AS MiddleName
			  ,D.SPOUSE_LNAME AS LastName
			  ,D.SPOUSE_LNAME_PRIOR AS LastNamePrior
			  ,1 AS DimFamilyTypeInternalId
			  ,ISNULL(D.SPOUSE_SUFFIX,'NULL') AS LOOKUP_SuffixDesc
			  ,NULL AS LOOKUP_SuffixDesc_DC
			  ,NULL AS DimSuffixId
			  ,0 AS DimSuffixId_Flag
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
			  INTO #Tmp_HoldData
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(GETDATE() AS DATE)
			  AND (D.SPOUSE_GNAME IS NOT NULL OR D.SPOUSE_MNAME IS NOT NULL OR D.SPOUSE_LNAME IS NOT NULL)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.RECORD_REGIS_DATE IS NOT NULL

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId
			  ,D.MARITAL AS MaritalStatus
			  ,D.FATHER_GNAME AS FirstName
			  ,D.FATHER_MNAME AS MiddleName
			  ,D.FATHER_LNAME AS LastName
			  ,D.FATHER_LNAME_PRIOR AS LastNamePrior
			  ,2 AS DimFamilyTypeInternalId
			  ,ISNULL(D.FATHER_SUFF,'NULL') AS LOOKUP_SuffixDesc
			  ,NULL AS LOOKUP_SuffixDesc_DC
			  ,NULL AS DimSuffixId
			  ,0 AS DimSuffixId_Flag
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate 
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(GETDATE() AS DATE)
			  AND (D.FATHER_GNAME IS NOT NULL OR D.FATHER_MNAME IS NOT NULL OR D.FATHER_LNAME IS NOT NULL)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.RECORD_REGIS_DATE IS NOT NULL

		UNION ALL

		SELECT D.DEATH_REC_ID AS SrId
			  ,P.PersonId
			  ,D.MARITAL AS MaritalStatus
			  ,D.MOTHER_GNAME AS FirstName
			  ,D.MOTHER_MNAME AS MiddleName
			  ,D.MOTHER_LNAME AS LastName
			  ,D.MOTHER_LNAME_PRIOR AS LastNamePrior
			  ,3 AS DimFamilyTypeInternalId
			  ,ISNULL(D.MOTHER_SUFF,'NULL') AS LOOKUP_SuffixDesc
			  ,NULL AS LOOKUP_SuffixDesc_DC
			  ,NULL AS DimSuffixId
			  ,0 AS DimSuffixId_Flag
			  ,@CurentTime AS CreatedDate 
			  ,VRV_REC_DATE_CREATED AS SrCreatedDate
			  ,VRV_DATE_CHANGED AS SrUpdatedDate
		FROM RVRS.VIP_VRV_Death_Tbl D
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(GETDATE() AS DATE)
			  AND (D.MOTHER_GNAME IS NOT NULL OR D.MOTHER_MNAME IS NOT NULL OR D.MOTHER_LNAME IS NOT NULL)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.RECORD_REGIS_DATE IS NOT NULL

		SET @TotalProcessedRecords = @@ROWCOUNT
		ALTER TABLE #Tmp_HoldData ADD FamilyMember_Log_LoadNote VARCHAR(2000)
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

		SET @MaxDateinData = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

		IF EXISTS(SELECT SrId FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] WHERE CAST(SrUpdatedDate AS DATE)<=@MaxDateinData)

		BEGIN
		SET @LastLoadedDate = @MaxDateinData

		PRINT '1'
		SELECT SrId
			,PersonId
			,MaritalStatus
			,DimFamilyTypeInternalId
			,FirstName
			,FMF.Mapping_Current as FirstName_DC
			,MiddleName
			,FMM.Mapping_Current as MiddleName_DC
			,LastName
			,FML.Mapping_Current as LastName_DC
			,LastNamePrior
			,FMLP.Mapping_Current as LastNamePrior_DC
			,LOOKUP_SuffixDesc
			,LOOKUP_SuffixDesc_DC
			,DimSuffixId
			,DimSuffixId_Flag
			,CreatedDate
			,CASE WHEN DimFamilyTypeInternalId =1 AND MaritalStatus = 'S' 
				AND  (FirstName IS NOT NULL OR MiddleName IS NOT NULL OR LastName IS NOT NULL OR LastNamePrior IS NOT NULL)
				AND FirstName NOT IN ('N/A','UNKNOWN')
				AND MiddleName NOT IN ('N/A','UNKNOWN')
				AND LastName NOT IN ('N/A','UNKNOWN')
				AND LastNamePrior NOT IN ('N/A','UNKNOWN')
			   THEN 'MARITAL,SPOUSE_GNAME,SPOUSE_MNAME,SPOUSE_LNAME|Error:Marital Status and Spouse have value' 
			   ELSE '' END AS LoadNote
			,0 AS Loadnote_Log_Flag
			,CASE WHEN FirstName ='---' THEN 0
			 WHEN FirstName NOT LIKE '-%' AND FirstName LIKE '%-%' THEN 0
			 WHEN LEFT(FirstName,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
			 END
			 AS FirstName_Flag
			,CASE WHEN FMF.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS FirstName_DC_Flag

			,CASE WHEN MiddleName ='---' THEN 0
				  WHEN MiddleName NOT LIKE '-%' AND MiddleName LIKE '%-%' THEN 0
				  WHEN LEFT(MiddleName,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
				  END
			AS MiddleName_Flag
			,CASE WHEN FMM.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS MiddleName_DC_Flag

			,CASE WHEN LastName ='---' THEN 0
				  WHEN LastName NOT LIKE '-%' AND LastName LIKE '%-%' THEN 0
				  WHEN LEFT(LastName,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
			 END
			 AS LastName_Flag
			,CASE WHEN FML.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS LastName_DC_Flag

			,CASE WHEN LastNamePrior ='---' THEN 0
				  WHEN LastNamePrior NOT LIKE '-%' AND LastName LIKE '%-%' THEN 0
				  WHEN LEFT(LastNamePrior,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
			 END
			 AS LastNamePrior_Flag
			,CASE WHEN FMLP.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS LastNamePrior_DC_Flag

			,0 AS FamilyMember_log_Flag
			,FamilyMember_Log_LoadNote AS FamilyMember_Log_LoadNote INTO #Tmp_HoldData_Final
		FROM #Tmp_HoldData HD
		LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_FirstName') FMF ON FMF.Mapping_Previous=HD.FirstName
		LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_MiddleName') FMM ON FMF.Mapping_Previous=HD.MiddleName
		LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_LastName') FML ON FMF.Mapping_Previous=HD.LastName
		LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_LastNamePrior') FMLP ON FMLP.Mapping_Previous=HD.LastNamePrior

		PRINT '2'

		UPDATE #Tmp_HoldData_Final 
		SET Loadnote_Log_Flag = 1 WHERE LoadNote <> ''

		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN FirstName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN MiddleName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN LastName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN LastNamePrior_DC VARCHAR(128)


		/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE*/
		UPDATE MT
		SET MT.DimSuffixId=DS.DimSuffixId
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS ON DS.SuffixDesc=MT.LOOKUP_SuffixDesc	


		/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
			FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix TABLE*/
		UPDATE MT
		SET MT.DimSuffixId=DS.Mapping_Current_ID
			,LOOKUP_SuffixDesc_DC=DS.Mapping_Current
			,MT.DimSuffixId_Flag=1
			,MT.FamilyMember_Log_LoadNote='DimSuffixId|Warning:Suffix got value from data conversion'
		FROM #Tmp_HoldData_Final MT
		JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_SuffixDesc
		WHERE DS.TableName='DimSuffix'
			AND MT.DimSuffixId IS NULL


		/*UPDATING THE Person_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
		UPDATE #Tmp_HoldData_Final
		SET FamilyMember_Log_Flag=1
			,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
				'DimSuffixId|Pending Review:Not a valid Suffix'
		WHERE DimSuffixId IS NULL

		/*************************************************************Code For FirstName STARTS*************************************************************/
			PRINT '18'
			/*MATCH FirstName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.FirstName_DC=DC.Mapping_Current
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.FirstName
				AND DC.TableName='Family_Member_FirstName'
			WHERE FirstName_Flag=1

			PRINT '19'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.FamilyMember_Log_LoadNote=MT.FamilyMember_Log_LoadNote+' || '+'FirstName|Warning:First Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE FirstName_Flag=1
				AND FirstName_DC IS NOT NULL

			PRINT '20'

			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
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
				AND DC.TableName='Family_Member_MiddleName'
			WHERE MiddleName_Flag=1

			PRINT '22'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.FamilyMember_Log_LoadNote=MT.FamilyMember_Log_LoadNote+' || '+'MiddleName|Warning:Middle Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE MiddleName_Flag=1
				AND MiddleName_DC IS NOT NULL

			PRINT '23'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
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
				AND DC.TableName='Family_Member_LastName'
			WHERE LastName_Flag=1

			PRINT '25'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.FamilyMember_Log_LoadNote=MT.FamilyMember_Log_LoadNote+' || '+'LastName|Warning:Last Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE LastName_Flag=1
				AND LastName_DC IS NOT NULL

			PRINT '26'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
					'LastName|Error:Not a valid last name'
			WHERE LastName_Flag=1
				AND LastName_DC IS NULL
		/***************************************************************Code For LastName ENDS**************************************************************/

		/**************************************************************Code For LastNamePrior STARTS*************************************************************/
			PRINT '24'
			/*MATCH LastNamePrior ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.LastNamePrior_DC=DC.Mapping_Current
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.LastName
				AND DC.TableName='Family_Member_LastNamePrior'
			WHERE LastNamePrior_Flag=1

			PRINT '25'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.FamilyMember_Log_LoadNote=MT.FamilyMember_Log_LoadNote+' || '+'LastNamePrior|Warning:Last Name got value from data conversion'
			FROM #Tmp_HoldData_Final MT
			WHERE LastNamePrior_Flag=1
				AND LastNamePrior_DC IS NOT NULL

			PRINT '26'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
					'LastName|Error:Not a valid last name'
			WHERE LastNamePrior_Flag=1
				AND LastNamePrior_DC IS NULL
		/***************************************************************Code For LastNamePrior ENDS**************************************************************/

	/**************************************************************Other Validations STARTS*************************************************************/

			/**/
			--scenario 1
			UPDATE P
			SET P.LoadNote= 'FamilyMember|MissingChild:ChildMissing FamilyMember' + CASE WHEN P.LoadNote!='' THEN ' || ' + P.LoadNote ELSE '' END
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.PersonId=HF.PersonId
			WHERE HF.FamilyMember_Log_Flag=1
				AND HF.PersonId IS NOT NULL

			--scenario 2 & 3
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN 'Person|ParentMissing:Validation Errors' + ' || ' + FamilyMember_Log_LoadNote ELSE '' END
				WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log)


			--scenario 4
			IF EXISTS(SELECT FamilyMember_Log_Flag FROM #Tmp_HoldData_Final WHERE PersonId IS NULL 
			   AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
			   AND FamilyMember_Log_Flag=0)
				BEGIN
					SET @ExecutionStatus='Failed'
					set @Note = 'Parent table has not been processed yet'
				END

			--scenario 5
			UPDATE #Tmp_HoldData_Final
				SET FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN 'Person|ParentMissing:Not Processed'+' || '+FamilyMember_Log_LoadNote
					ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL
				  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
				  AND  FamilyMember_Log_Flag=1

		/***************************************************************Other Validations ENDS**************************************************************/
		SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember]
		(
			 PersonId
			,FirstName
			,MiddleName
			,LastName
			,LastNamePrior
			,DimFamilyTypeInternalId
			,DimSuffixId
			,CreatedDate
			,LoadNote
		)
		SELECT PersonId
			,ISNULL(FirstName_DC,FirstName)
			,ISNULL(MiddleName_DC,MiddleName)
			,ISNULL(LastName_DC,LastName)
			,ISNULL(LastNamePrior_DC,LastNamePrior)
			,DimFamilyTypeInternalId
			,DimSuffixId
			,CreatedDate
			,FamilyMember_Log_LoadNote
		FROM #Tmp_HoldData_Final
		WHERE FamilyMember_log_Flag=0
		AND PersonId IS NOT NULL

		SET @TotalLoadedRecord = @@ROWCOUNT

		INSERT INTO [RVRS].[FamilyMember_Log]
		(
			 PersonId
			,SrId
			,FirstName
			,MiddleName
			,LastName
			,LastNamePrior
			,DimFamilyTypeInternalId
			,DimSuffixId
			,CreatedDate
			,LoadNote
		)
		SELECT PersonId
			,SrId
			,ISNULL(FirstName_DC,FirstName)
			,ISNULL(MiddleName_DC,MiddleName)
			,ISNULL(LastName_DC,LastName)
			,ISNULL(LastNamePrior_DC,LastNamePrior)
			,DimFamilyTypeInternalId
			,DimSuffixId
			,CreatedDate
			,FamilyMember_Log_LoadNote
		FROM #Tmp_HoldData_Final
		WHERE FamilyMember_log_Flag=1

		SET @TotalErrorRecord = @@ROWCOUNT

		SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE FamilyMember_log_Flag=1
										AND FamilyMember_Log_LoadNote LIKE '%|Pending Review%')
		SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE FamilyMember_Log_LoadNote NOT LIKE '%|Pending Review%'
									AND FamilyMember_Log_LoadNote LIKE '%|WARNING%')

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
			,'FamilyMember' AS Entity
			,'FamilyMemberId' AS EntityColumnName
			,PA.FamilyMemberId AS EntityId
			,'DimSuffixID' AS ConvertedColumn
			,MT.LOOKUP_SuffixDesc AS OriginalValue
			,MT.LOOKUP_SuffixDesc_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember] PA ON PA.PersonId=MT.PersonId
			AND PA.DimFamilyTypeInternalId=MT.DimFamilyTypeInternalId
		WHERE MT.DimSuffixId_Flag=1

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR FamilyMemberFirstName*/
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
			,'FamilyMember' AS Entity
			,'FamilyMemberId' AS EntityColumnName
			,PA.FamilyMemberId AS EntityId
			,'FirstName' AS ConvertedColumn			
			,MT.FirstName AS OriginalValue
			,MT.FirstName_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember] PA ON PA.PersonId=MT.PersonId
			AND PA.DimFamilyTypeInternalId=MT.DimFamilyTypeInternalId
		WHERE MT.FirstName_Flag=1
			AND MT.FirstName_DC IS NOT NULL


		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR FamilyMemberMiddleName*/
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
			,'FamilyMember' AS Entity
			,'FamilyMemberId' AS EntityColumnName
			,PA.FamilyMemberId AS EntityId
			,'MiddleName' AS ConvertedColumn			
			,MT.LOOKUP_SuffixDesc AS OriginalValue
			,MT.MiddleName AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember] PA ON PA.PersonId=MT.PersonId
			AND PA.DimFamilyTypeInternalId=MT.DimFamilyTypeInternalId
		WHERE MT.MiddleName_Flag=1
			AND MT.MiddleName_DC IS NOT NULL

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR FamilyMemberLastName*/
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
			,'FamilyMember' AS Entity
			,'FamilyMemberId' AS EntityColumnName
			,PA.FamilyMemberId AS EntityId
			,'LastName' AS ConvertedColumn			
			,MT.LastName AS OriginalValue
			,MT.LastName_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember] PA ON PA.PersonId=MT.PersonId
			AND PA.DimFamilyTypeInternalId=MT.DimFamilyTypeInternalId
		WHERE MT.LastName_Flag=1
			AND MT.LastName_DC IS NOT NULL

		/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR FamilyMemberLastNamePrior*/
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
			,'FamilyMember' AS Entity
			,'FamilyMemberId' AS EntityColumnName
			,PA.FamilyMemberId AS EntityId
			,'LastNamePrior' AS ConvertedColumn			
			,MT.LastNamePrior AS OriginalValue									
			,MT.LastNamePrior_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember] PA ON PA.PersonId=MT.PersonId
			AND PA.DimFamilyTypeInternalId=MT.DimFamilyTypeInternalId
		WHERE MT.LastNamePrior_Flag=1
			AND MT.LastNamePrior IS NOT NULL

UPDATE [RVRS].[Execution]
		SET ExecutionStatus=@ExecutionStatus
			,LastLoadDate=@LastLoadDate
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
				SET @Err_Message ='We do not have data for '+ CONVERT(VARCHAR(50),@MaxDateinData,106) +' in Person Table'
				RAISERROR (@Err_Message,10,1)
			END
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

