IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_PersonPr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_PersonPr]
GO

CREATE PROCEDURE [RVRS].[Load_VIP_PersonPr]
AS 

/*
AUTHOR	: SAILENDRA SINGH
CREATED	: 28 MAR 2022
PURPOSE	: TO LOAD DATA INTO FACT PERSON TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE			NAME							DESCRIPTION
28 Mar 2022		SAILENDRA SINGH					RVRS-159 : LOAD DECEDENT BASIC DATA FROM STAGING TO ODS

EXEC [RVRS].[Load_VIP_PersonPr]
*/

BEGIN
	DECLARE @TotalLoadedRecord INT
			,@TotalErrorRecord INT
			,@LastLoadDate DATE
			,@TotalProcessedRecords INT
			,@ExecutionId BIGINT
			,@TotalPendingReviewRecord INT
			,@TotalWarningRecord INT

	BEGIN TRY
		--PRINT '1'

		EXEC [RVRS].[Load_VIP_Person_TempPr] @DEATH_REC_ID=NULL
			,@LastLoadDate_OUT=@LastLoadDate OUTPUT
			,@TotalProcessedRecords_OUT=@TotalProcessedRecords OUTPUT
			,@ExecutionId_OUT=@ExecutionId OUTPUT
	
		/************************************************************Code For DimSuffixId STARTS************************************************************/
			--PRINT '2'
			/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE*/
			UPDATE MT
			SET MT.DimSuffixId=DS.DimSuffixId
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS ON DS.SuffixDesc=MT.LOOKUP_SuffixDesc
	
			--PRINT '3'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDATED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PESON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'Suffix' AS ConvertedColumn
				,MT.LOOKUP_SuffixDesc AS OriginalValue
				,DS.Mapping_Current AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_SuffixDesc
			WHERE DS.TableName='DimSuffix'
				AND MT.DimSuffixId IS NULL

			--PRINT '3A'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'DimSuffixId|Warning:Suffix got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'DimSuffixId|Warning:Suffix got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_SuffixDesc
			WHERE DS.TableName='DimSuffix'
				AND MT.DimSuffixId IS NULL
	
			--PRINT '4'

			/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
				FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix TABLE*/
			UPDATE MT
			SET MT.DimSuffixId=DS.Mapping_Current_ID
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_SuffixDesc
			WHERE DS.TableName='DimSuffix'
				AND MT.DimSuffixId IS NULL			

			--PRINT '5'
	
			/*IF THERE IS NO MATCH FOUND IN BOTH RVRS.DimSuffix AND RVRS.Data_Conversion THEN THE RECORDS WILL GO TO LOG TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END
					+'DimSuffixId|Pending Review:Could not find a match for Suffix'
			WHERE DimSuffixId IS NULL
		/*************************************************************Code For DimSuffixId ENDS*************************************************************/





		/********************************************************Code For DimMaritalStatusId STARTS*********************************************************/
			--PRINT '6'
			/*THIS CODE IS TO GET MATCH FROM DimMaritalStatus TABLE AND UPDATE THE DimMaritalStatusId WITH CORRECT VALUE*/
			UPDATE MT
			SET MT.DimMaritalStatusId=DS.DimMaritalStatusId
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimMaritalStatus] DS ON DS.Abbr=MT.LOOKUP_MaritalStatus_Abbr
	
			--PRINT '7'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAtED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PERSON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'MaritalStatus' AS ConvertedColumn
				,MT.LOOKUP_MaritalStatus_Abbr AS OriginalValue
				,DS.Mapping_Current AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_MaritalStatus_Abbr
			WHERE DS.TableName='DimMaritalStatus'
				AND MT.DimMaritalStatusId IS NULL

			--PRINT '7A'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'DimMaritalStatusId|Warning:Marital Status got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'DimMaritalStatusId|Warning:Marital Status got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_MaritalStatus_Abbr
			WHERE DS.TableName='DimMaritalStatus'
				AND MT.DimMaritalStatusId IS NULL
	
			--PRINT '8'

			/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimMaritalStatusId WITH CORRECT VALUE,
				FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimMaritalStatus TABLE*/
			UPDATE MT
			SET MT.DimMaritalStatusId=DS.Mapping_Current_ID
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_MaritalStatus_Abbr
			WHERE DS.TableName='DimMaritalStatus'
				AND MT.DimMaritalStatusId IS NULL
	
			--PRINT '9'

			--/*IF THERE IS NO MATCH FOUND IN BOTH RVRS.DimMaritalStatus AND RVRS.Data_Conversion TABLE THEN THE RECORDS WILL GO TO LOG TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END
					+'DimMaritalStatusId|Pending Review:Could not find a match for Marital Status'
			WHERE DimMaritalStatusId IS NULL
		/*********************************************************Code For DimMaritalStatusId ENDS**********************************************************/





		/*************************************************************Code For DimSexId STARTS**************************************************************/
			--PRINT '10'
			/*THIS CODE IS TO GET MATCH FROM DimSex TABLE AND UPDATE THE DimSexId WITH CORRECT VALUE*/
			UPDATE MT
			SET MT.DimSexId=DS.DimSexId
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSex] DS ON DS.Abbr=MT.LOOKUP_Sex_Abbr
			WHERE DS.DimSexId IS NOT NULL
	
			--PRINT '11'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PESON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'Sex' AS ConvertedColumn
				,MT.LOOKUP_Sex_Abbr AS OriginalValue
				,DS.Mapping_Current AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_Sex_Abbr
			WHERE DS.TableName='DimSex'
				AND MT.DimSexId IS NULL

			--PRINT '11A'
		
			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'DimSexId|Warning:Sex got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'DimSexId|Warning:Sex got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_Sex_Abbr
			WHERE DS.TableName='DimSex'
				AND MT.DimSexId IS NULL
	
			--PRINT '12'

			/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimSexId WITH CORRECT VALUE,
				FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSex TABLE*/
			UPDATE MT
			SET MT.DimSexId=DS.Mapping_Current_ID
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_Sex_Abbr
			WHERE DS.TableName='DimSex'
				AND MT.DimSexId IS NULL
	
			--PRINT '13'

			--/*IF THERE IS NO MATCH FOUND IN BOTH RVRS.DimSex AND RVRS.Data_Conversion TABLE THEN THE RECORDS WILL GO TO LOG TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END
					+'DimSexId|Pending Review:Could not find a match for SEX'
			WHERE DimSexId IS NULL
		/**************************************************************Code For DimSexId ENDS***************************************************************/





		/***********************************************************Code For DimAgeTypeId STARTS************************************************************/
			--PRINT '14'
			/*THIS CODE IS TO GET MATCH FROM DimAgeType TABLE AND UPDATE THE DimAgeTypeId WITH CORRECT VALUE*/
			UPDATE MT
			SET MT.DimAgeTypeId=DS.DimAgeTypeId
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimAgeType] DS ON CAST(DS.Code AS VARCHAR(24))=MT.LOOKUP_AgeType_Code
				OR DS.AgeTypeDesc = MT.LOOKUP_AgeType_Code
			WHERE DS.DimAgeTypeId IS NOT NULL
	
			--PRINT '15'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PESON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'AgeType' AS ConvertedColumn
				,MT.LOOKUP_AgeType_Code AS OriginalValue
				,DS.Mapping_Current AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_AgeType_Code
			WHERE DS.TableName='DimAgeType'
				AND MT.DimAgeTypeId IS NULL

			--PRINT '15'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'DimAgeTypeId|Warning:Age Type got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'DimAgeTypeId|Warning:Age Type got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_AgeType_Code
			WHERE DS.TableName='DimAgeType'
				AND MT.DimAgeTypeId IS NULL
	
			--PRINT '16'

			/*THIS CODE IS TO GET MATCH FROM Data_Conversion TABLE AND UPDATE THE DimAgeTypeId WITH CORRECT VALUE,
				FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSex TABLE*/
			UPDATE MT
			SET MT.DimAgeTypeId=DS.Mapping_Current_ID
			FROM rvrs.Tran_VIP_Person_Death MT
			JOIN RVRS.Data_Conversion DS ON DS.Mapping_Previous=MT.LOOKUP_AgeType_Code
			WHERE DS.TableName='DimAgeType'
				AND MT.DimAgeTypeId IS NULL

			--PRINT '17'

			/*IF THERE IS NO MATCH FOUND IN BOTH RVRS.DimSex AND RVRS.Data_Conversion TABLE THEN THE RECORDS WILL GO TO LOG TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END+
					'DimAgeTypeId|Pending Review:Could not find a match for Age Type'
			WHERE DimAgeTypeId IS NULL
		/************************************************************Code For DimAgeTypeId ENDS*************************************************************/
	
	


		/*************************************************************Code For FirstName STARTS*************************************************************/
			--PRINT '18'
			/*MATCH FirstName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.FirstName_DC=DC.Mapping_Current
			FROM RVRS.Tran_VIP_Person_Death PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.FirstName
				AND DC.TableName='Person_FirstName'
			WHERE FirstName_Flag=1

			--PRINT '19'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PERSON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'FirstName' AS ConvertedColumn
				,FirstName AS OriginalValue
				,FirstName_DC AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE FirstName_Flag=1
				AND FirstName_DC IS NOT NULL

			--PRINT '19A'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'GNAME|Warning:First Name got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'GNAME|Warning:First Name got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE FirstName_Flag=1
				AND FirstName_DC IS NOT NULL



			--PRINT '20'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END+
					'GName|Error:Not a valid first name'
			WHERE FirstName_Flag=1
				AND FirstName_DC IS NULL
		/**************************************************************Code For FirstName ENDS**************************************************************/





		/*************************************************************Code For MiddleName STARTS************************************************************/
			--PRINT '21'
			/*MATCH MiddleName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.MiddleName_DC=DC.Mapping_Current
			FROM RVRS.Tran_VIP_Person_Death PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.MiddleName
				AND DC.TableName='Person_MiddleName'
			WHERE MiddleName_Flag=1

			--PRINT '22'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PERSON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'MiddleName' AS ConvertedColumn
				,MiddleName AS OriginalValue
				,MiddleName_DC AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE MiddleName_Flag=1
				AND MiddleName_DC IS NOT NULL

			--PRINT '22A'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'MNAME|Warning:Middle Name got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'MNAME|Warning:Middle Name got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE MiddleName_Flag=1
				AND MiddleName_DC IS NOT NULL

			--PRINT '23'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END+
					'MName|Error:Not a valid middle name'
			WHERE MiddleName_Flag=1
				AND MiddleName_DC IS NULL
		/**************************************************************Code For MiddleName ENDS*************************************************************/





		/**************************************************************Code For LastName STARTS*************************************************************/
			--PRINT '24'
			/*MATCH LastName ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.LastName_DC=DC.Mapping_Current
			FROM RVRS.Tran_VIP_Person_Death PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.LastName
				AND DC.TableName='Person_LastName'
			WHERE LastName_Flag=1

			--PRINT '25'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PERSON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'LastName' AS ConvertedColumn
				,LastName AS OriginalValue
				,LastName_DC AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE LastName_Flag=1
				AND LastName_DC IS NOT NULL

			--PRINT '25A'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'LNAME|Warning:Last Name got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'LNAME|Warning:Last Name got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE LastName_Flag=1
				AND LastName_DC IS NOT NULL

			--PRINT '26'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END+
					'LName|Error:Not a valid last name'
			WHERE LastName_Flag=1
				AND LastName_DC IS NULL
		/***************************************************************Code For LastName ENDS**************************************************************/





		/***********************************************************Code For LastNameMaiden STARTS**********************************************************/
			--PRINT '27'
			/*MATCH LastNameMaiden ISSUE RECORDS IN RVRS.Data_Conversion TABLE*/
			UPDATE PD
			SET PD.LastNameMaiden_DC=DC.Mapping_Current
			FROM RVRS.Tran_VIP_Person_Death PD
			JOIN RVRS.Data_Conversion DC ON DC.Mapping_Previous=PD.LastNameMaiden
				AND DC.TableName='Person_LastNameMaiden'
			WHERE LastNameMaiden_Flag=1

			--PRINT '28'

			/*THE RECORDS WHICH WILL HAVE A MATCH IN RVRS.Data_Conversion TABLE, WILL BE INSERTED INTO RVRS.DeathOriginal TABLE
				EntityId COLUMN WOULD BE LATER UPDAED WITH PERSONID COLUMN'S VALUE IN CODE, ONCE WE POPULATE PERSON TABLE*/
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
				,'Person' AS Entity
				,'PersonId' AS EntityColumnName
				,NULL AS EntityId
				,'LastNameMaiden' AS ConvertedColumn
				,LastNameMaiden AS OriginalValue
				,LastNameMaiden_DC AS ConvertedValue
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE LastNameMaiden_Flag=1
				AND LastNameMaiden_DC IS NOT NULL

			--PRINT '28A'

			/*UPDATING THE LOAD NOTE FOR THE RECORDS WE WILL MATCH FROM RVRS.Data_Conversion TABLE*/
			UPDATE MT
			SET MT.LoadNote=MT.LoadNote+' || '+'LNAME_Maiden|Warning:Last Name Maiden got value from data conversion'
				,MT.Person_Log_LoadNote=MT.Person_Log_LoadNote+' || '+'LNAME_Maiden|Warning:Last Name Maiden got value from data conversion'
			FROM rvrs.Tran_VIP_Person_Death MT
			WHERE LastNameMaiden_Flag=1
				AND LastNameMaiden_DC IS NOT NULL

			--PRINT '29'
			/*UPDATING THEPerson_log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN RVRS.Data_Conversion TABLE*/
			UPDATE rvrs.Tran_VIP_Person_Death
			SET Person_log_Flag=1
				,Person_Log_LoadNote=CASE WHEN Person_Log_LoadNote!='' THEN Person_Log_LoadNote+' || ' ELSE '' END+
					'LastNameMaiden|Error:Not a valid Last Name Maiden'
			WHERE LastNameMaiden_Flag=1
				AND LastNameMaiden_DC IS NULL
		/************************************************************Code For LastNameMaiden ENDS***********************************************************/





		/*INSERTS DATA INTO RVRS.Person TABLE - GOOD RECORDS*/
		INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[Person]
		(
			 DimModuleInternalId
			,DimPersonTypeInternalId
			,SrId
			,[Guid]
			,GuidBaseLine
			,GuidOriginate
			,SrVersion
			,FlCurrent
			,FlAbandoned
			,SrVoided
			,FirstName
			,MiddleName
			,MiddleInitial
			,LastName
			,LastNameMaiden
			,DimSuffixId
			,DimSexId
			,BirthYear
			,BirthMonth
			,BirthDay
			,AgeCalcYear
			,AgeYear
			,AgeMonth
			,AgeDay
			,AgeHour
			,AgeMinute
			,DimAgeTypeId
			,DimMaritalStatusId
			,Ssn
			,SrCreatedDate
			,SrUpdatedDate
			,SrCreatedUserId
			,SrUpdatedUserId
			,LoadNote
		)
		SELECT DimModuleInternalId
			,DimPersonTypeInternalId
			,SrId
			,[Guid]
			,GuidBaseLine
			,GuidOriginate
			,SrVersion
			,FlCurrent
			,FlAbandoned
			,SrVoided
			,ISNULL(FirstName_DC,FirstName) AS FirstName
			,ISNULL(MiddleName_DC,MiddleName) AS MiddleName
			,MiddleInitial
			,ISNULL(LastName_DC,LastName) AS LastName
			,ISNULL(LastNameMaiden_DC,LastNameMaiden) AS LastNameMaiden
			,DimSuffixId
			,DimSexId
			,BirthYear
			,BirthMonth
			,BirthDay
			,AgeCalcYear
			,AgeYear
			,AgeMonth
			,AgeDay
			,AgeHour
			,AgeMinute
			,DimAgeTypeId
			,DimMaritalStatusId
			,Ssn
			,SrCreatedDate
			,SrUpdatedDate
			,SrCreatedUserId
			,SrUpdatedUserId
			,LoadNote
		FROM rvrs.Tran_VIP_Person_Death
		WHERE Person_log_Flag=0

		SET @TotalLoadedRecord = @@ROWCOUNT

		--PRINT '30'


		/*INSERTS DATA INTO RVRS.Person_Log TABLE - BAD RECORDS*/
		INSERT INTO RVRS.Person_Log
		(
			 DimModuleInternalId
			,DimPersonTypeInternalId
			,SrId
			,[Guid]
			,GuidBaseLine
			,GuidOriginate
			,SrVersion
			,FlCurrent
			,FlAbandoned
			,SrVoided
			,FirstName
			,MiddleName
			,MiddleInitial
			,LastName
			,LastNameMaiden
			,SuffixDesc
			,DimSuffixId
			,SexDesc
			,DimSexId
			,BirthYear
			,BirthMonth
			,BirthDay
			,AgeCalcYear
			,AgeYear
			,AgeMonth
			,AgeDay
			,AgeHour
			,AgeMinute
			,DimAgeTypeId
			,MaritalStatusDesc
			,DimMaritalStatusId
			,Ssn
			,SrCreatedDate
			,SrUpdatedDate
			,SrCreatedUserId
			,SrUpdatedUserId
			,LoadNote
		)
		SELECT DimModuleInternalId
			,DimPersonTypeInternalId
			,SrId
			,[Guid]
			,GuidBaseLine
			,GuidOriginate
			,SrVersion
			,FlCurrent
			,FlAbandoned
			,SrVoided
			,ISNULL(FirstName_DC,FirstName) AS FirstName
			,ISNULL(MiddleName_DC,MiddleName) AS MiddleName
			,MiddleInitial
			,ISNULL(LastName_DC,LastName) AS LastName
			,ISNULL(LastNameMaiden_DC,LastNameMaiden) AS LastNameMaiden
			,LOOKUP_SuffixDesc
			,DimSuffixId
			,LOOKUP_Sex_Abbr
			,DimSexId
			,BirthYear
			,BirthMonth
			,BirthDay
			,AgeCalcYear
			,AgeYear
			,AgeMonth
			,AgeDay
			,AgeHour
			,AgeMinute
			,DimAgeTypeId
			,LOOKUP_MaritalStatus_Abbr
			,DimMaritalStatusId
			,Ssn
			,SrCreatedDate
			,SrUpdatedDate
			,SrCreatedUserId
			,SrUpdatedUserId
			,Person_Log_LoadNote
		FROM rvrs.Tran_VIP_Person_Death
		WHERE Person_log_Flag=1

		SET @TotalErrorRecord = @@ROWCOUNT

		SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM rvrs.Tran_VIP_Person_Death WHERE Person_log_Flag=1 AND Person_Log_LoadNote LIKE '%Pending Review%')
		SET @TotalWarningRecord=(SELECT COUNT(1) FROM rvrs.Tran_VIP_Person_Death WHERE LoadNote NOT LIKE '%Pending Review%'	AND LoadNote LIKE '%WARNING%')

		--PRINT '31'

		/*UPDATE DEATH ORIGINAL TABLE'S ENTITYID COLUMN*/
		UPDATE DO
		SET DO.EntityID = P.PersonId
		FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal] DO
		JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[PERSON] P ON P.SrId = DO.SrId
		WHERE DO.EntityID IS NULL
		AND DO.Entity = 'Person'
	
		--PRINT '32'
		UPDATE [RVRS].[Execution]
		SET ExecutionStatus='Completed'
			,LastLoadDate=@LastLoadDate
			,EndTime=GETDATE()
			,TotalProcessedRecords=@TotalProcessedRecords
			,TotalLoadedRecord=@TotalLoadedRecord
			,TotalErrorRecord=@TotalErrorRecord
			,TotalPendingReviewRecord=@TotalPendingReviewRecord
			,TotalWarningRecord=@TotalWarningRecord
		WHERE ExecutionId=@ExecutionId
	END TRY
	BEGIN CATCH
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
	END CATCH
END