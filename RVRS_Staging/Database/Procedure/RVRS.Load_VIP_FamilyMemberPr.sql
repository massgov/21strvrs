--use rvrs_staging
IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_FamilyMemberPr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_FamilyMemberPr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_FamilyMemberPr]
AS 

/*
NAME	: Load_VIP_FamilyMemberPr
AUTHOR	: SAILENDRA
CREATED	: 05 APR 2022
PURPOSE	: TOLOAD DATA INTO FACT FamilyMember TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE		NAME						DESCRIPTION
06 JUN 2022	SAILENDRA					RVRS 161- : LOAD DECEDENT FAMILY MEMBER DATA FROM STAGING TO ODS

EXEC RVRS.Load_VIP_FamilyMemberPr
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
		,@MaxDateinData DATE
		,@TotalLoadedRecord INT
		,@TotalErrorRecord INT=0
		,@ExecutionStatus VARCHAR(100)='Completed'
		,@Note VARCHAR(500)
		,@RecordCountDebug int

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
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
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
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
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
		FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
		LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P ON P.SrId=D.DEATH_REC_ID
		WHERE CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)
			  AND (D.MOTHER_GNAME IS NOT NULL OR D.MOTHER_MNAME IS NOT NULL OR D.MOTHER_LNAME IS NOT NULL)
			  AND D.VRV_RECORD_TYPE_ID = '040'
			  AND D.RECORD_REGIS_DATE IS NOT NULL

		SET @TotalProcessedRecords = @@ROWCOUNT
		ALTER TABLE #Tmp_HoldData ADD FamilyMember_Log_LoadNote VARCHAR(2000)
		ALTER TABLE #Tmp_HoldData ALTER COLUMN LOOKUP_SuffixDesc_DC VARCHAR(128) NULL


		--PRINT '3' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '3A' + CAST(@TotalProcessedRecords AS VARCHAR(10))
		--PRINT @TotalProcessedRecords

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

		--IF EXISTS(SELECT SrId FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] WHERE CAST(SrUpdatedDate AS DATE)<=@MaxDateinData)
		IF EXISTS (SElECT top 1 1 from #Tmp_HoldData where PersonId is not null )

		BEGIN
		SET @LastLoadedDate = @MaxDateinData

		PRINT '4' + CONVERT (VARCHAR(50),GETDATE(),109)
		SELECT SrId
			,PersonId
			,MaritalStatus
			,DimFamilyTypeInternalId
			,FirstName
			--,FMF.Mapping_Current 
			,NULL as FirstName_DC
			,MiddleName
			--,FMM.Mapping_Current 
			,NULL as MiddleName_DC
			,LastName
			--,FML.Mapping_Current 
			,NULL as LastName_DC
			,LastNamePrior
			--,FMLP.Mapping_Current
			,NULL as LastNamePrior_DC
			,LOOKUP_SuffixDesc
			,LOOKUP_SuffixDesc_DC
			,DimSuffixId
			,DimSuffixId_Flag
			,CreatedDate
			,CASE WHEN DimFamilyTypeInternalId =1 AND MaritalStatus = 'S' 
				AND  (FirstName IS NOT NULL OR MiddleName IS NOT NULL OR LastName IS NOT NULL OR LastNamePrior IS NOT NULL)
				AND FirstName NOT IN ('N/A','NA')
				AND MiddleName NOT IN ('N/A','NA')
				AND LastName NOT IN ('N/A','NA')
				AND LastNamePrior NOT IN ('N/A','NA')
			   THEN 'MARITAL,SPOUSE_GNAME,SPOUSE_MNAME,SPOUSE_LNAME|Error:Marital Status and Spouse have value' 
			   ELSE '' END AS LoadNote
			,0 AS Loadnote_Log_Flag
			--,CASE WHEN SPOUSE_GNAME ='---' THEN 0
			-- WHEN SPOUSE_GNAME NOT LIKE '-%' AND SPOUSE_GNAME LIKE '%-%' THEN 0
			-- WHEN LEFT(SPOUSE_GNAME,1) LIKE '[^a-zA-Z]' THEN 1 ELSE 0
			,CASE WHEN LEFT(FirstName,1) LIKE '[^a-zA-Z]' and FirstName NOT LIKE '-%' THEN 1 ELSE 0
			 END
			 AS FirstName_Flag
			 ,CASE WHEN FirstName ='---' THEN 0
				WHEN FirstName LIKE '-%' THEN 1 --AND FirstName NOT LIKE '%-%' THEN 1
				WHEN FirstName LIKE 'U%K%N' THEN 1 ELSE 0
			 END
			 AS FirstName_DC_Flag
			--,CASE WHEN FMF.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS FirstName_DC_Flag

			,CASE WHEN LEFT(MiddleName,1) LIKE '[^a-zA-Z]' and MiddleName NOT LIKE '-%' THEN 1 ELSE 0
			 END AS MiddleName_Flag
			,CASE WHEN MiddleName ='---' THEN 0
				  WHEN MiddleName LIKE '-%' THEN 1 --AND MiddleName NOT LIKE '%-%' THEN 0
				  WHEN MiddleName LIKE 'U%K%N' THEN 1 ELSE 0
				  END
			AS MiddleName_DC_Flag
			--,CASE WHEN FMM.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS MiddleName_DC_Flag

			,CASE WHEN LEFT(LastName,1) LIKE '[^a-zA-Z]' and LastName NOT LIKE '-%' THEN 1 ELSE 0
			 END AS LastName_Flag
			,CASE WHEN LastName ='---' THEN 0
				  WHEN LastName LIKE '-%' THEN 1 --AND LastName NOT LIKE '%-%' THEN 0
				  WHEN LastName LIKE 'U%K%N' THEN 1 ELSE 0
			 END
			 AS LastName_DC_Flag
			--,CASE WHEN FML.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS LastName_DC_Flag

			,CASE WHEN LEFT(LastNamePrior,1) LIKE '[^a-zA-Z]' and LastNamePrior NOT LIKE '-%' THEN 1 ELSE 0
			 END AS LastNamePrior_Flag
			,CASE WHEN LastNamePrior ='---' THEN 0
				  WHEN LastNamePrior LIKE '-%' THEN 1 --AND LastNamePrior NOT  LIKE '%-%' THEN 0
				  WHEN LastNamePrior LIKE 'U%K%N' THEN 1 ELSE 0
			 END
			 AS LastNamePrior_DC_Flag
			--,CASE WHEN FMLP.Mapping_Current IS NOT NULL THEN 1 ELSE NULL END AS LastNamePrior_DC_Flag

			,0 AS FamilyMember_log_Flag
			,FamilyMember_Log_LoadNote AS FamilyMember_Log_LoadNote INTO #Tmp_HoldData_Final
		FROM #Tmp_HoldData HD
		--LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_FirstName') FMF ON FMF.Mapping_Previous=HD.FirstName
		--LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_MiddleName') FMM ON FMM.Mapping_Previous=HD.MiddleName
		--LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_LastName') FML ON FMM.Mapping_Previous=HD.LastName
		--LEFT JOIN (SELECT Mapping_Previous,Mapping_Current FROM RVRS.Data_Conversion WHERE TableName = 'Family_Member_LastNamePrior') FMLP ON FMLP.Mapping_Previous=HD.LastNamePrior

		set @RecordCountDebug=@@rowcount
		--PRINT '5' + CONVERT (VARCHAR(50),GETDATE(),109)
		
		--PRINT '5A' + CAST(@RecordCountDebug AS VARCHAR(10))
		UPDATE #Tmp_HoldData_Final 
		SET Loadnote_Log_Flag = 1 WHERE LoadNote <> ''

		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN FirstName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN MiddleName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN LastName_DC VARCHAR(128)
		ALTER TABLE #Tmp_HoldData_Final ALTER COLUMN LastNamePrior_DC VARCHAR(128)

		PRINT '6' + CONVERT (VARCHAR(50),GETDATE(),109)

		/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE*/
		UPDATE MT
		SET MT.DimSuffixId=DS.DimSuffixId
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS WITH(NOLOCK) ON DS.SuffixDesc=MT.LOOKUP_SuffixDesc	

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '7' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '7A' + CAST(@RecordCountDebug AS VARCHAR(10))



		/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
			FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix TABLE*/
		UPDATE MT
		SET MT.DimSuffixId=DS.Mapping_Current_ID
			,LOOKUP_SuffixDesc_DC=DS.Mapping_Current
			,MT.DimSuffixId_Flag=1
			,MT.FamilyMember_Log_LoadNote='DimSuffixId|Warning:Suffix got value from data conversion'
		FROM #Tmp_HoldData_Final MT
		JOIN RVRS.Data_Conversion DS WITH(NOLOCK) ON DS.Mapping_Previous=MT.LOOKUP_SuffixDesc
		WHERE DS.TableName='DimSuffix'
			AND MT.DimSuffixId IS NULL

		SET @RecordCountDebug=@@ROWCOUNT
		PRINT '8' + CONVERT (VARCHAR(50),GETDATE(),109)
		PRINT '8A' + CAST(@RecordCountDebug AS VARCHAR(10))

		/*UPDATING THE Person_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
		UPDATE #Tmp_HoldData_Final
		SET FamilyMember_Log_Flag=1
			,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
				'DimSuffixId|Pending Review:Not a valid Suffix'
		WHERE DimSuffixId IS NULL


		/*************************************************************Code For FirstName STARTS*************************************************************/
		SET @RecordCountDebug=@@ROWCOUNT
		PRINT '9' + CONVERT (VARCHAR(50),GETDATE(),109)
		PRINT '9A' + CAST(@RecordCountDebug AS VARCHAR(10))

			/*MATCH FirstName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.FirstName_DC=DC.Mapping_Current
				,PD.FamilyMember_Log_LoadNote=ISNULL(PD.FamilyMember_Log_LoadNote,'')+' || '+'FirstName|Warning:First Name got value from data conversion'
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC WITH(NOLOCK) ON DC.Mapping_Previous=PD.FirstName
				AND DC.TableName='Family_Member_FirstName'  --check this caue suffix does not have this format
			WHERE FirstName_DC_Flag=1
			AND FirstName_DC IS NULL

		SET @RecordCountDebug=@@ROWCOUNT
		PRINT '10' + CONVERT (VARCHAR(50),GETDATE(),109)
		PRINT '10A' + CAST(@RecordCountDebug AS VARCHAR(10))

			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
					'FirstName|Error:Not a valid first name'	
			WHERE FirstName_Flag=1													--check this section
			OR (FirstName_DC_Flag=1 AND FirstName_DC IS NULL)	
		
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '11' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '11A' + CAST(@RecordCountDebug AS VARCHAR(10))
		/**************************************************************Code For FirstName ENDS**************************************************************/

		/*************************************************************Code For MiddleName STARTS************************************************************/
			--PRINT '21'
			/*MATCH MiddleName ISSUE RECORDS IN RVRS.Data_Conversion TABLE AND UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.MiddleName_DC=DC.Mapping_Current
				,PD.FamilyMember_Log_LoadNote= ISNULL(PD.FamilyMember_Log_LoadNote,'') +' || '+'MiddleName|Warning:Middle Name got value from data conversion'
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC WITH(NOLOCK) ON DC.Mapping_Previous=PD.MiddleName
				AND DC.TableName='Family_Member_MiddleName'
			WHERE MiddleName_DC_Flag=1
			AND MiddleName_DC IS NULL
	
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '12' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '12A' + CAST(@RecordCountDebug AS VARCHAR(10))

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '13' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '13A' + CAST(@RecordCountDebug AS VARCHAR(10))
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
					'MiddleName|Error:Not a valid middle name'
			WHERE MiddleName_Flag=1
				OR (MiddleName_DC_Flag=1 AND MiddleName_DC IS NULL)
				
		/**************************************************************Code For MiddleName ENDS*************************************************************/


		/**************************************************************Code For LastName STARTS*************************************************************/
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '14' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '14A' + CAST(@RecordCountDebug AS VARCHAR(10))
			/*MATCH LastName ISSUE RECORDS IN RVRS.Data_Conversion TABLE AND UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.LastName_DC=DC.Mapping_Current
				,PD.FamilyMember_Log_LoadNote= ISNULL(PD.FamilyMember_Log_LoadNote,'')+' || '+'LastName|Warning:Last Name got value from data conversion'
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC WITH(NOLOCK) ON DC.Mapping_Previous=PD.LastName
				AND DC.TableName='Family_Member_LastName'
			WHERE LastName_DC_Flag=1
			AND LastName_DC IS NULL

		SET @RecordCountDebug=@@ROWCOUNT
		PRINT '15' + CONVERT (VARCHAR(50),GETDATE(),109)
		PRINT '15A' + CAST(@RecordCountDebug AS VARCHAR(10))
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
					'LastName|Error:Not a valid last name'
			WHERE LastName_Flag=1
				OR (LastName_DC_Flag=1 AND LastName_DC IS NULL)
				
		/***************************************************************Code For LastName ENDS**************************************************************/

		/**************************************************************Code For LastNamePrior STARTS*************************************************************/
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '16' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '16A' + CAST(@RecordCountDebug AS VARCHAR(10))
			/*MATCH LastNamePrior ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.LastNamePrior_DC=DC.Mapping_Current
				,PD.FamilyMember_Log_LoadNote=ISNULL(PD.FamilyMember_Log_LoadNote,'')+' || '+'LastNamePrior|Warning:Last Name got value from data conversion'
			FROM #Tmp_HoldData_Final PD
			JOIN RVRS.Data_Conversion DC WITH(NOLOCK) ON DC.Mapping_Previous=PD.LastNamePrior
				AND DC.TableName='Family_Member_LastNamePrior'
			WHERE LastNamePrior_DC_Flag=1
			AND LastNamePrior_DC IS NULL

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '17' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '17A' + CAST(@RecordCountDebug AS VARCHAR(10))
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN FamilyMember_Log_LoadNote+' || ' ELSE '' END+
					'LastNamePrior|Error:Not a valid last name prior'
			WHERE LastNamePrior_Flag=1
				OR (LastNamePrior_DC_Flag = 1 AND LastNamePrior_DC IS NULL)
				
	/***************************************************************Code For LastNamePrior ENDS**************************************************************/

	/**************************************************************Other Validations STARTS*************************************************************/
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '18' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '18A' + CAST(@RecordCountDebug AS VARCHAR(10))
			/**/
			--scenario 1
			UPDATE P
			SET P.LoadNote= 'FamilyMember|MissingChild:ChildMissing FamilyMember' + CASE WHEN P.LoadNote!='' THEN ' || ' + P.LoadNote ELSE '' END
			FROM #Tmp_HoldData_Final HF
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.PersonId=HF.PersonId
			WHERE HF.FamilyMember_Log_Flag=1
				AND HF.PersonId IS NOT NULL

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '19' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '19A' + CAST(@RecordCountDebug AS VARCHAR(10))

			--scenario 2 & 3
			UPDATE #Tmp_HoldData_Final
			SET FamilyMember_Log_Flag=1
				,FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN 'Person|ParentMissing:Validation Errors' + ' || ' + FamilyMember_Log_LoadNote ELSE '' END
				WHERE PersonId IS NULL
				AND SrId IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))
	
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '20' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '20A' + CAST(@RecordCountDebug AS VARCHAR(10))

			--scenario 4
			IF EXISTS(SELECT FamilyMember_Log_Flag FROM #Tmp_HoldData_Final WHERE PersonId IS NULL 
			   AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))
			   AND FamilyMember_Log_Flag=0)
				BEGIN
					SET @ExecutionStatus='Failed'
					set @Note = 'Parent table has not been processed yet'
				END
		
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '21' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '21A' + CAST(@RecordCountDebug AS VARCHAR(10))

			--scenario 5
			UPDATE #Tmp_HoldData_Final
				SET FamilyMember_Log_LoadNote=CASE WHEN FamilyMember_Log_LoadNote!='' THEN 'Person|ParentMissing:Not Processed'+' || '+FamilyMember_Log_LoadNote
					ELSE 'Person|ParentMissing:Not Processed' END
			WHERE PersonId IS NULL
				  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))
				  AND  FamilyMember_Log_Flag=1
		
		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '22' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '22A' + CAST(@RecordCountDebug AS VARCHAR(10))
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
		--PRINT '23' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '23A' + CAST(@TotalLoadedRecord AS VARCHAR(10))

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


		--PRINT '24' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '24A' + CAST(@TotalErrorRecord AS VARCHAR(10))

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

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '25' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '25A' + CAST(@RecordCountDebug AS VARCHAR(10))

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
		WHERE MT.FirstName_DC_Flag=1
			AND MT.FirstName_DC IS NOT NULL

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '26' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '26A' + CAST(@RecordCountDebug AS VARCHAR(10))


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
			,MT.MiddleName AS OriginalValue
			,MT.MiddleName_DC AS ConvertedValue
		FROM #Tmp_HoldData_Final MT
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[FamilyMember] PA ON PA.PersonId=MT.PersonId
			AND PA.DimFamilyTypeInternalId=MT.DimFamilyTypeInternalId
		WHERE MT.MiddleName_DC_Flag=1
			AND MT.MiddleName_DC IS NOT NULL

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '27' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '27A' + CAST(@RecordCountDebug AS VARCHAR(10))

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
		WHERE MT.LastName_DC_Flag=1
			AND MT.LastName_DC IS NOT NULL

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '28' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '28A' + CAST(@RecordCountDebug AS VARCHAR(10))

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
		WHERE MT.LastNamePrior_DC_Flag=1
			AND MT.LastNamePrior IS NOT NULL

		SET @RecordCountDebug=@@ROWCOUNT
		--PRINT '29' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '29A' + CAST(@RecordCountDebug AS VARCHAR(10))

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
		--PRINT '30' + CONVERT (VARCHAR(50),GETDATE(),109)
		--PRINT '30A' + CAST(@RecordCountDebug AS VARCHAR(10))
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

