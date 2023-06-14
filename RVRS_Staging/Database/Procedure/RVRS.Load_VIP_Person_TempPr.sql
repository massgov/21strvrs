use RVRS_Staging
IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('RVRS.Load_VIP_Person_TempPr') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_Person_TempPr]
GO
	

CREATE PROCEDURE [RVRS].[Load_VIP_Person_TempPr]
(
	 @DEATH_REC_ID NUMERIC(10,0)=NULL
	,@LastLoadDate_OUT DATE OUTPUT
	,@TotalProcessedRecords_OUT INT OUTPUT
	,@ExecutionId_OUT BIGINT OUTPUT
)
AS

/*
NAME	: Load_VIP_Person_TempPr
AUTHOR	: SAILENDRA SINGH
CREATED	: 14 MAR 2022
PURPOSE	: TO LOAD DATA INTO RVRS.Tran_VIP_Person_Death TABLE, WHICH IS INTERMEDIATELY GETTING USED TO LOAD FACT PERSON TABLE

REVISION HISTORY
---------------------------------------------------------------------------------------
DATE			NAME							DESCRIPTION
14 Mar 2022		SAILENDRA SINGH					RVRS-159 : LOAD DECEDENT BASIC DATA FROM STAGING TO ODS


EXEC RVRS.Load_VIP_Person_TempPr @DEATH_REC_ID = NULL
EXEC RVRS.Load_VIP_Person_TempPr @DEATH_REC_ID = 375882
*/

BEGIN
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
	SELECT 'Person' AS Entity
		,'In Progress' AS ExecutionStatus
		,NULL AS LastLoadDate
		,GETDATE() AS StartTime
		,NULL AS EndTime
		,0 AS TotalProcessedRecords
		,0 AS TotalLoadedRecord
		,0 AS TotalErrorRecord
		,0 AS TotalPendingReviewRecord
		,0 AS TotalWarningRecord

	SET @ExecutionId_OUT = (SELECT IDENT_CURRENT('RVRS.Execution'))

	BEGIN TRY

		IF OBJECT_ID('RVRS.Tran_VIP_Person_Death','U') IS NOT NULL 
			DROP TABLE RVRS.Tran_VIP_Person_Death						--ADDED VIP IN TABLE NAME
		IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
		IF OBJECT_ID('tempdb..#Tmp_HoldData_FLCurrent_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_FLCurrent_Final

		DECLARE @LastLoadedDate DATE
		SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='Person')
		/*WHEN WE WILL BE LOADING FOR THE FIRST TIME THE MAX(SrCreatedDate) WOULD BE NULL,
			WE ARE SETTING A LOAD DATE PRIOR TO OUR EXISTING RECORDS MINIMUM DATE*/
		IF(@LastLoadedDate IS NULL)
			SET @LastLoadedDate='01/01/1900'


		/*WE ARE CHECKING HERE IF WE HAVE MULTIPLE RECORDS FOR THE SAME VRV_BASELINE_RECORD_ID AND FL_CURRENT VALUE IS 1*/
	
		SELECT DEATH_REC_ID
			,VRV_BASELINE_RECORD_ID
			,FL_CURRENT INTO #Tmp_HoldData_FLCurrent_Final
		FROM rvrs.VIP_VRV_Death_Tbl WITH(NOLOCK)
		WHERE VRV_BASELINE_RECORD_ID IN 
		(
			SELECT VRV_BASELINE_RECORD_ID
			FROM 
			(
				SELECT VRV_BASELINE_RECORD_ID, 
				ROW_NUMBER() OVER (PARTITION BY ISNULL(VRV_BASELINE_RECORD_ID,DEATH_REC_ID) ORDER BY VRV_REC_REPLACE_NBR) AS ROWNUM
				FROM rvrs.VIP_VRV_Death_Tbl WITH(NOLOCK)
				WHERE FL_CURRENT = 1
			) A
			WHERE ROWNUM>1
		)
		CREATE INDEX IX_Temp_DEATH_REC_ID ON #Tmp_HoldData_FLCurrent_Final(DEATH_REC_ID)

		SELECT 1 AS DimModuleInternalId
			,1 AS DimPersonTypeInternalId
			,D.DEATH_REC_ID AS SrId
			,'01'+'01'+'01' + CAST(D.DEATH_REC_ID AS VARCHAR(50)) AS [Guid]
			,'01'+'01'+'01' + CAST(D.VRV_BASELINE_RECORD_ID AS VARCHAR(50)) AS GuidBaseLine
			,'01'+'01'+'01' + CAST(D.VRV_ORIGINATING_REC_ID AS VARCHAR(50)) AS GuidOriginate 
			,D.VRV_REC_REPLACE_NBR AS SrVersion
			,D.FL_CURRENT AS FlCurrent
			,CASE WHEN D.FL_ABANDONED = 'N' THEN 0 ELSE 1 END AS FlAbandoned
			,D.FL_VOIDED AS SrVoided
			,ISNULL(D.SUFF,'NULL') AS LOOKUP_SuffixDesc
			,NULL AS DimSuffixId
			,D.GNAME AS FirstName
			,D.MNAME AS MiddleName
			,NULL AS MiddleInitial
			,D.LNAME AS LastName
			,D.LNAME_MAIDEN AS LastNameMaiden
			,ISNULL(D.SEX,'NULL') AS LOOKUP_Sex_Abbr
			,NULL AS DimSexId
			,D.AGE1_CALC AS AgeCalcYear
			,AGE1 AS AgeYear
			,AGE2 AS AgeMonth
			,AGE3 AS AgeDay
			,AGE4 AS AgeHour
			,AGE5 AS AgeMinute
			,ISNULL(CAST(D.AGETYPE AS VARCHAR(24)),'NULL') AS LOOKUP_AgeType_Code
			,NULL AS DimAgeTypeId
			,CASE WHEN ISDATE(D.DOB) = 1 THEN YEAR(CAST(D.DOB AS DATE)) 
				  WHEN D.DOB='99/99/9999' THEN '9999'
				  WHEN D.DOB LIKE '99/99/[0-9][0-9][0-9][0-9]'THEN RIGHT(D.DOB,4)
				  ELSE NULL
			 END AS BirthYear 
			,CASE WHEN ISDATE(D.DOB) = 1 THEN MONTH(CAST(D.DOB AS DATE))
				  WHEN D.DOB='99/99/9999' THEN '99'
				  WHEN D.DOB LIKE '[0-9][0-9]/99/9999'THEN LEFT(D.DOB,2)
				  ELSE NULL
			 END AS BirthMonth
			,CASE WHEN ISDATE(D.DOB) = 1 THEN DAY(CAST(D.DOB AS DATE))
				  WHEN D.DOB='99/99/9999' THEN '99'
				  WHEN D.DOB LIKE '99/[0-9][0-9]/9999'THEN SUBSTRING(D.DOB,4,2)   
				  ELSE NULL
			 END AS BirthDay
			,ISNULL(D.MARITAL,'NULL') AS LOOKUP_MaritalStatus_Abbr
			,NULL AS DimMaritalStatusId
			,D.SSN AS Ssn
			,D.VRV_REC_DATE_CREATED AS SrCreatedDate						
			,D.VRV_DATE_CHANGED AS SrUpdatedDate
			,D.VRV_REC_INIT_USER_ID AS SrCreatedUserId
			,D.VRV_REC_CHANGED_USER_ID AS SrUpdatedUserId
							/*NEWLY ADDED*/
			/*,CASE WHEN D.DOB='99/99/9999' OR ISDATE(D.DOB) = 1 
				OR D.DOB LIKE '99/99/[0-9][0-9][0-9][0-9]' OR D.DOB LIKE '99/[0-9][0-9]/9999' OR D.DOB LIKE '[0-9][0-9]/99/9999' 
			THEN ''	ELSE 'DOB|Error:Not a valid date'
			 END AS LoadNote--LOG TABLE*/
			,CASE WHEN D.DOB='99/99/9999' THEN ''												--REVIEW THIS PART AS WRONG DATES ARE SHOWING NULL IN LOADNOTE
				  --WHEN ISDATE(D.DOB)=0 THEN 'DOB|Error:Not a valid date'						--NEWLY ADDED
				  WHEN ISDATE(D.DOB) = 1 THEN ''
					WHEN D.DOB LIKE '99/99/[0-9][0-9][0-9][0-9]' THEN ''						--NEWLY ADDED
					WHEN D.DOB LIKE '99/[0-9][0-9]/9999' THEN ''								--NEWLY ADDED
					WHEN D.DOB LIKE '[0-9][0-9]/99/9999' THEN ''								--NEWLY ADDED
				  ELSE 'DOB|Error:Not a valid date'
			 END AS LoadNote--LOG TABLE
			,CASE WHEN D.GNAME<>D.ME_GNAME THEN 'GNAME|Warning:First Name Mismatch with the Medical Record' ELSE '' END AS LoadNote_1--PERSON TABLE
			,CASE WHEN D.MNAME<>D.ME_MNAME THEN 'MNAME|Warning:Middle Name Mismatch with the Medical Record' ELSE '' END AS LoadNote_2--PERSON TABLE
			,CASE WHEN D.LNAME<>D.ME_LNAME THEN 'LNAME|Warning:Last Name Mismatch with the Medical Record' ELSE '' END AS LoadNote_3--PERSON TABLE
			,CASE WHEN D.SEX IS NULL OR D.SEX = '' THEN 'SEX|Warning:Sex is Blank' ELSE '' END AS LoadNote_4--PERSON TABLE
			,CASE WHEN ISDATE(D.DOB) = 1 AND ISDATE(D.DOD_4_FD) = 1 THEN
									/*NEW ADDED LOGIC*/
						CASE WHEN LEFT(DOB,5)=LEFT(dod_4_fd,5) AND (DATEDIFF(HOUR,dob,dod_4_fd)/8760) <>AGE1_CALC 
							THEN 'AGE1_CALC|Error:Age Calculated Value is not right'
							WHEN LEFT(DOB,5)<>LEFT(dod_4_fd,5) AND (DATEDIFF(HOUR,dob,dod_4_fd)/8766)<>AGE1_CALC 
							THEN 'AGE1_CALC|Error:Age Calculated Value is not right'
						ELSE  '' END 
			
					ELSE  CASE WHEN (RIGHT(DOB,4) = '9999' OR RIGHT(DOD_4_FD,4) = '9999') AND AGE1_CALC <>'999' THEN 'AGE1_CALC|Error:Age Calculated for Unknown Year' 
							 WHEN (LEFT(DOB,2) = '99' OR LEFT(DOD_4_FD,2) = '99') AND AGE1_CALC <>'999' THEN 'AGE1_CALC|Error:Age Calculated for Unknown Month' 
							 WHEN (SUBSTRING(DOB,4,2) = '99' OR SUBSTRING(DOD_4_FD,4,2) = '99') AND AGE1_CALC <>'999' THEN 'AGE1_CALC|Error:Age Calculated for Unknown Day'
							ELSE '' END
			END AS LoadNote_5--LOG TABLE
			,CASE WHEN FL.DEATH_REC_ID IS NOT NULL THEN 'FL_CURRENT|Error:Multiple related records have FL_CURRENT Value as 1' ELSE '' END AS LoadNote_6--LOG TABLE
			,CASE WHEN D.VRV_REC_REPLACE_NBR = 0 AND D.VRV_BASELINE_RECORD_ID IS NOT NULL 
					THEN  'VRV_BASELINE_RECORD_ID,VRV_REC_REPLACE_NBR|Error:Record Version is 0 but VRV_BASELINE_RECORD_ID is not null'
				  WHEN D.VRV_REC_REPLACE_NBR>0 AND D.VRV_BASELINE_RECORD_ID IS NULL
					THEN 'VRV_BASELINE_RECORD_ID,VRV_REC_REPLACE_NBR|Error:Record Version is greater than 0 but VRV_BASELINE_RECORD_ID is null'
				  ELSE ''  END		  
			AS LoadNote_7--LOG TABLE
			,CASE WHEN D.VRV_REC_REPLACE_NBR>0 AND (D.DEATH_REC_ID<= D.VRV_BASELINE_RECORD_ID Or D.DEATH_REC_ID<= D.VRV_ORIGINATING_REC_ID)
					THEN 'VRV_BASELINE_RECORD_ID,VRV_ORIGINATING_REC_ID|Error: VRV_BASELINE_RECORD_ID or VRV_ORIGINATING_REC_ID greater than DEATH_REC_ID'
				  ELSE ''  END	
			AS LoadNote_8--LOG TABLE
			,CASE WHEN D.VRV_REC_DATE_CREATED IS NULL 
					THEN 'VRV_REC_DATE_CREATED|Error: VRV_REC_DATE_CREATED is Null'
				ELSE '' END
			AS LoadNote_9--LOG TABLE
			,CASE WHEN D.VRV_DATE_CHANGED IS NULL 
					THEN 'VRV_DATE_CHANGED|Error: VRV_DATE_CHANGED is Null'
				ELSE '' END
			AS LoadNote_10--LOG TABLE
			,CASE WHEN D.LAST_UPDATED_USER_ID IS NULL
					THEN 'VRV_REC_CHANGED_USER_ID|Error: VRV_REC_CHANGED_USER_ID is Null'
				ELSE '' END
			AS LoadNote_11--Person TABLE
			,CASE WHEN D.AGETYPE IS NULL			
					THEN 'AGETYPE|Warning: AGETYPE is Null'
				ELSE '' END
			AS LoadNote_12--Log TABLE
			,CASE WHEN D.VRV_REC_INIT_USER_ID IS NULL
					THEN 'VRV_REC_INIT_USER_ID|Error: VRV_REC_INIT_USER_ID is Null'
				ELSE '' END
			AS LoadNote_13--LOG TABLE
			,CASE WHEN D.SSN NOT LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]' 
					THEN 'SSN|Warning: SSN is not Valid'
				ELSE '' END
			AS LoadNote_14--LOG TABLE
			,CASE WHEN D.AGETYPE=1 AND (D.AGE2 IS NOT NULL OR D.AGE3 IS NOT NULL OR D.AGE4 IS NOT NULL OR D.AGE5 IS NOT NULL)
					THEN 'AGETYPE,1|Error: Only AGE1 should have value'
				ELSE '' END
			AS LoadNote_15--LOG TABLE
			,CASE WHEN D.AGETYPE=2 AND (D.AGE1 IS NOT NULL OR D.AGE4 IS NOT NULL OR D.AGE5 IS NOT NULL)
					THEN 'AGETYPE,2|Error: Only AGE2 and AGE3 should have value'
				ELSE '' END
			AS LoadNote_16--LOG TABLE
			,CASE WHEN D.AGETYPE=3 AND (D.AGE1 IS NOT NULL OR D.AGE2 IS NOT NULL OR D.AGE3 IS NOT NULL)
					THEN 'AGETYPE,3|Error: Only AGE4 and AGE5 should have value'
				ELSE '' END
			AS LoadNote_17--LOG TABLE
			,CASE WHEN LEFT(D.GNAME,1) LIKE '[0-9]'
					THEN 'GNAME|Error: First Name starts with number'
				ELSE '' END
			AS LoadNote_18--LOG TABLE
			,CASE WHEN LEFT(D.MNAME,1) LIKE '[0-9]'
					THEN 'MNAME|Error: Middle Name starts with number'
				ELSE '' END
			AS LoadNote_19--LOG TABLE
			,CASE WHEN LEFT(D.LNAME,1) LIKE '[0-9]'
					THEN 'LNAME|Error: Last Name starts with number'
				ELSE '' END
			AS LoadNote_20--LOG TABLE
			,CASE WHEN LEFT(D.LNAME_MAIDEN,1) LIKE '[0-9]'
					THEN 'LNAME_MAIDEN|Error: Last Maiden Name starts with number'
				ELSE '' END
			AS LoadNote_21--LOG TABLE
			,CASE WHEN D.DOB='99/99/9999' THEN''
					WHEN D.DOB LIKE '99/99/[0-9][0-9][0-9][0-9]' THEN ''						--NEWLY ADDED
					WHEN D.DOB LIKE '99/[0-9][0-9]/9999' THEN ''								--NEWLY ADDED
					WHEN D.DOB LIKE '[0-9][0-9]/99/9999' THEN ''								--NEWLY ADDED
					WHEN ISDATE(D.DOB) = 1 AND (YEAR(CAST(D.DOB AS DATE))>=1900 AND YEAR(CAST(D.DOB AS DATE))<=YEAR(GETDATE())) THEN ''
				ELSE 'DOB|Error:DOB not in valid range' END
			AS LoadNote_22--LOG TABLE

			INTO #Tmp_HoldData

		FROM [RVRS].[VIP_VRV_Death_Tbl] D
		LEFT JOIN #Tmp_HoldData_FLCurrent_Final FL ON D.DEATH_REC_ID = FL.DEATH_REC_ID
		WHERE (@DEATH_REC_ID IS NULL OR D.DEATH_REC_ID = @DEATH_REC_ID)
			AND CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
			AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(GETDATE() AS DATE)
			AND D.VRV_RECORD_TYPE_ID = '040'
			AND D.RECORD_REGIS_DATE IS NOT NULL

		SET @TotalProcessedRecords_OUT = @@ROWCOUNT
		SET @LastLoadDate_OUT = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)
	
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
			,LOOKUP_SuffixDesc
			,DimSuffixId
			,FirstName
			,MiddleName
			,MiddleInitial
			,LastName
			,LastNameMaiden
			,LOOKUP_Sex_Abbr
			,DimSexId
			,AgeCalcYear
			,AgeYear
			,AgeMonth
			,AgeDay
			,AgeHour
			,AgeMinute
			,LOOKUP_AgeType_Code
			,DimAgeTypeId
			,BirthYear 
			,BirthMonth
			,BirthDay
			,LOOKUP_MaritalStatus_Abbr
			,Ssn
			,DimMaritalStatusId
			,SrCreatedDate
			,SrUpdatedDate
			,SrCreatedUserId
			,SrUpdatedUserId
			,CASE WHEN LoadNote<>'' OR LoadNote_5<>'' OR LoadNote_6<>'' OR LoadNote_7<>'' OR LoadNote_8<>'' OR LoadNote_9<>'' OR LoadNote_10<>''
					OR LoadNote_12<>'' OR LoadNote_13<>''  OR LoadNote_14 <>'' OR LoadNote_15 <>'' OR LoadNote_16 <>'' OR LoadNote_17 <>'' OR LoadNote_18 <>''
					OR LoadNote_19 <>'' OR LoadNote_20 <>'' OR LoadNote_21 <>'' OR LoadNote_22 <>'' THEN 1 
				  ELSE 0 END
			 AS Person_log_Flag

			 ,CASE WHEN FirstName ='---' THEN 0
				   WHEN FirstName NOT LIKE '-%' AND FirstName LIKE '%-%' THEN 0
				   WHEN LEFT(FirstName,1) LIKE '[^a-zA-Z]%' THEN 1 ELSE 0
				   END AS FirstName_Flag
			,NULL AS FirstName_DC

			--,CASE WHEN FirstName NOT LIKE '-%' AND FirstName LIKE '%-%' THEN 0
			--		WHEN FirstName!='---' AND FirstName LIKE '[^a-zA-Z'']%'						--NEWLY ADDED
			--	  --WHEN FirstName!='---' AND REPLACE(FirstName,' ','') LIKE '%[^a-zA-Z'']%'
			--	  --AND SUBSTRING(FirstName,2,1)!='.' 
			--	  THEN 1
			--	  ELSE 0 END
			-- AS FirstName_Flag
			--,NULL AS FirstName_DC

			,CASE WHEN MiddleName ='---' THEN 0
				  WHEN MiddleName NOT LIKE '-%' AND FirstName LIKE '%-%' THEN 0
				  WHEN LEFT(MiddleName,1) LIKE '[^a-zA-Z]%' THEN 1 ELSE 0
				  END AS MiddleName_Flag
			,NULL AS MiddleName_DC

			-- ,CASE WHEN MiddleName NOT LIKE '-%' AND MiddleName LIKE '%-%' THEN 0
			--		WHEN MiddleName!='---' AND MiddleName LIKE '[^a-zA-Z'']%'					--NEWLY ADDED
			--	   --WHEN MiddleName!='---' AND REPLACE(MiddleName,' ','') LIKE '%[^a-zA-Z'']%'
			--		--AND SUBSTRING(MiddleName,2,1)!='.' 
			--		THEN 1
			--	  ELSE 0 END
			-- AS MiddleName_Flag
			--,NULL AS MiddleName_DC

			,CASE WHEN LastName ='---' THEN 0
				  WHEN LastName NOT LIKE '-%' AND LastName LIKE '%-%' THEN 0
				  WHEN LEFT(LastName,1) LIKE '[^a-zA-Z]%' THEN 1 ELSE 0
				  END AS LastName_Flag
			,NULL AS LastName_DC

			-- ,CASE WHEN LastName NOT LIKE '-%' AND LastName LIKE '%-%' THEN 0
			--		WHEN LastName!='---' AND LastName LIKE '[^a-zA-Z'']%'						--NEWLY ADDED
			--	   --WHEN LastName!='---' AND REPLACE(LastName,' ','') LIKE '%[^a-zA-Z'']%'
			--		--AND SUBSTRING(LastName,2,1)!='.' 
			--		THEN 1
			--	  ELSE 0 END
			-- AS LastName_Flag
			--,NULL AS LastName_DC

			,CASE WHEN LastNameMaiden ='---' THEN 0
				  WHEN LastNameMaiden NOT LIKE '-%' AND LastNameMaiden LIKE '%-%' THEN 0
				  WHEN LEFT(LastNameMaiden,1) LIKE '[^a-zA-Z]%' THEN 1 ELSE 0
				  END AS LastNameMaiden_Flag
			,NULL AS LastNameMaiden_DC

			--,CASE WHEN LastNameMaiden NOT LIKE '-%' AND LastNameMaiden LIKE '%-%' THEN 0
			--		WHEN LastNameMaiden!='---' AND LastNameMaiden LIKE '[^a-zA-Z'']%'			--NEWLY ADDED
			--	--WHEN LastNameMaiden!='---' AND REPLACE(LastNameMaiden,' ','') LIKE '%[^a-zA-Z'']%'
			--		--AND SUBSTRING(LastNameMaiden,2,1)!='.'
			--		THEN 1
			--	  ELSE 0 END
			-- AS LastNameMaiden_Flag
			--,NULL AS LastNameMaiden_DC
			,LoadNote  +
				(CASE WHEN LoadNote <> '' THEN ' || ' ELSE '' END) +
				LoadNote_1 +
				(CASE WHEN LoadNote_1 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_2 +
				(CASE WHEN LoadNote_2 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_3 +
				(CASE WHEN LoadNote_3 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_4 +
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
				LoadNote_14 +
				(CASE WHEN LoadNote_14 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_15 +
				(CASE WHEN LoadNote_15 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_16 +
				(CASE WHEN LoadNote_16 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_17 +
				(CASE WHEN LoadNote_17 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_18 +
				(CASE WHEN LoadNote_18 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_19 +
				(CASE WHEN LoadNote_19 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_20 +
				(CASE WHEN LoadNote_20 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_21 +
				(CASE WHEN LoadNote_21 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_22
			AS Person_Log_LoadNote
			,LoadNote_1 +
				(CASE WHEN LoadNote_1 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_2 +
				(CASE WHEN LoadNote_2 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_3 +
				(CASE WHEN LoadNote_3 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_4 +
				(CASE WHEN LoadNote_4 <> '' THEN ' || ' ELSE '' END) +
				LoadNote_11 
				AS LoadNote 
			
				INTO RVRS.Tran_VIP_Person_Death
		FROM #Tmp_HoldData

		ALTER TABLE RVRS.Tran_VIP_Person_Death ALTER COLUMN FirstName_DC VARCHAR(128)
		ALTER TABLE RVRS.Tran_VIP_Person_Death ALTER COLUMN MiddleName_DC VARCHAR(128)
		ALTER TABLE RVRS.Tran_VIP_Person_Death ALTER COLUMN LastName_DC VARCHAR(128)
		ALTER TABLE RVRS.Tran_VIP_Person_Death ALTER COLUMN LastNameMaiden_DC VARCHAR(128)


		UPDATE RVRS.Tran_VIP_Person_Death
		SET Person_Log_LoadNote = (CASE WHEN LEFT(LTRIM(REVERSE(Person_Log_LoadNote)),1)='|'
										THEN REVERSE(STUFF(LTRIM(REVERSE(Person_Log_LoadNote)),1, CHARINDEX(' ',LTRIM(REVERSE(Person_Log_LoadNote)),0),''))
										ELSE Person_Log_LoadNote END)
			,LoadNote = (CASE WHEN LEFT(LTRIM(REVERSE(LoadNote)),1)='|'
							  THEN REVERSE(STUFF(LTRIM(REVERSE(LoadNote)),1, CHARINDEX(' ',LTRIM(REVERSE(LoadNote)),0),''))
							  ELSE LoadNote END)
	END TRY
	BEGIN CATCH
		UPDATE [RVRS].[Execution]
		SET ExecutionStatus='Failed'
			,LastLoadDate=@LastLoadDate_OUT
			,EndTime=GETDATE()
			,TotalProcessedRecords=0
			,TotalLoadedRecord=0
			,TotalErrorRecord=0
			,TotalPendingReviewRecord=0
			,TotalWarningRecord=0
		WHERE ExecutionId=@ExecutionId_OUT
	END CATCH
END