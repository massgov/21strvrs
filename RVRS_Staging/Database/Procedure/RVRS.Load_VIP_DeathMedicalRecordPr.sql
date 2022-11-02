 USE [RVRS_testdb]


IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathMedicalRecordPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathMedicalRecordPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathMedicalRecordPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathMedicalRecordPr]
AUTHOR	:Sailendra Singh
CREATED	:Nov  2 2022  
PURPOSE	:TO LOAD DATA INTO FACT DeathMedicalRecord TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Nov  2 2022 		Sailendra Singh						RVRS 170 : LOAD DECEDENT DeathMedicalRecord DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'DeathMedicalRecord'
TRUNCATE TABLE [RVRS_testdb].[RVRS].[DeathMedicalRecord]
DROP TABLE [RVRS_testdb].[RVRS].[DeathMedicalRecord_Log]
DELETE FROM [RVRS_testdb].[RVRS].[Execution] WHERE Entity = 'DeathMedicalRecord'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathMedicalRecordPr]
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
		,@MAXDateinData DATE
		,@TotalLoadedRecord INT
		,@TotalErrorRecord INT=0
		,@ExecutionStatus VARCHAR(100)='Completed'
		,@Note VARCHAR(500)
		,@RecordCountDebug INT  
		,@TotalParentMissingRecords INT = 0
		
	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
1 - Create temp table 
----------------------------------------------------------------------------------------------------------------------------------------------
*/


IF OBJECT_ID('tempdb..#Tmp_HoldData') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
IF OBJECT_ID('tempdb..#Tmp_HoldData_Final') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Create log table 
----------------------------------------------------------------------------------------------------------------------------------------------
*/


IF OBJECT_ID('[RVRS_testdb].[RVRS].[DeathMedicalRecord_Log]') IS NULL 
	CREATE TABLE [RVRS_testdb].[RVRS].[DeathMedicalRecord_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), FirstName_DC VARCHAR(128),MiddleName_DC VARCHAR(128),LastName_DC VARCHAR(128),Suffix_DC VARCHAR(128), [PersonId] BIGINT,[RecordNumber] VARCHAR(32),[CaseYear] VARCHAR(16),[CaseNumber] VARCHAR(16),[FirstName] VARCHAR(128),[MiddleName] VARCHAR(128),[LastName] VARCHAR(128),[DimSuffixId] INT,[DimSexId] INT,[BirthYear] VARCHAR(16),[BirthMonth] VARCHAR(16),[BirthDay] VARCHAR(16),[DeathYear] VARCHAR(16),[DeathMonth] VARCHAR(16),[DeathDay] VARCHAR(16),[DeathHour] VARCHAR(16),[DeathMinute] VARCHAR(16),[DimTimeIndId] INT,[PronouncedYear] VARCHAR(16),[PronouncedMonth] VARCHAR(16),[PronouncedDay] VARCHAR(16),[PronouncedHour] VARCHAR(16),[PronouncedMinute] VARCHAR(16),[DimPronouncedTimeIndId] INT, FirstNameTab1 VARCHAR(128),MiddleNameTab1 VARCHAR(128),LastNameTab1 VARCHAR(128),Suffix VARCHAR(128),SuffixTab1 VARCHAR(128),Sex VARCHAR(128),SexTab1 VARCHAR(128),ME_DOB VARCHAR(128),DobTab1 VARCHAR(128),ME_DOD VARCHAR(128),DodTab1 VARCHAR(128),ME_TOD VARCHAR(128),TimeInd VARCHAR(128),ProDateTab5A VARCHAR(128),ME_PRO_DATE VARCHAR(128),ME_PRO_TIME VARCHAR(128),PronouncedTimeInd VARCHAR(128),ME_MNAME_NONE VARCHAR(128),TOD VARCHAR(128),ProTimeTab5A VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathMedicalRecord_Log_Flag BIT ,LoadNote VARCHAR(MAX))

BEGIN TRY

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Set Execution intial status
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '1'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			
INSERT INTO [RVRS_testdb].[RVRS].[Execution] 
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
		SELECT 'DeathMedicalRecord' AS Entity
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
	
		
/*
----------------------------------------------------------------------------------------------------------------------------------------------
3 - Collect data from Staging
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS_testdb].[RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathMedicalRecord' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT   D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,MED_REC_NUM RecordNumber,ME_CASE_YEAR CaseYear,ME_CASE_NUM CaseNumber,ME_GNAME FirstName,GNAME FirstNameTab1,ME_MNAME MiddleName,MNAME MiddleNameTab1,ME_LNAME LastName,LNAME LastNameTab1,COALESCE(ME_SUFF,'NULL') Suffix,COALESCE(SUFF,'NULL') SuffixTab1,COALESCE(ME_SEX,'NULL') Sex,COALESCE(SEX,'NULL') SexTab1,ME_DOB ME_DOB,DOB DobTab1,RIGHT(ME_DOB,4) BirthYear,LEFT(ME_DOB,2) BirthMonth,SUBSTRING(ME_DOB,4,2) BirthDay,DOD ME_DOD,DOD_4_FD DodTab1,RIGHT(DOD,4) DeathYear,LEFT(DOD,2) DeathMonth,SUBSTRING(DOD,4,2) DeathDay,TOD_ME ME_TOD,LEFT(TOD_ME,2) DeathHour,RIGHT(TOD_ME,2) DeathMinute,COALESCE(TOD_IN_ME,'NULL') TimeInd,PRO_DATE ProDateTab5A,PRO_DATE_ME ME_PRO_DATE,RIGHT(PRO_DATE_ME,4) PronouncedYear,LEFT(PRO_DATE_ME,2) PronouncedMonth,SUBSTRING(PRO_DATE_ME,4,2) PronouncedDay,PRO_TIME_ME ME_PRO_TIME,LEFT(PRO_TIME_ME,2) PronouncedHour,RIGHT(PRO_TIME_ME,2) PronouncedMinute,COALESCE(PRO_TIME_IND_M,'NULL') PronouncedTimeInd,ME_MNAME_NONE ME_MNAME_NONE,TOD TOD,PRO_TIME ProTimeTab5A
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM [RVRS_Staging].RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE 
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = '040'
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  
	       
 
	
	       SET @TotalProcessedRecords = @@ROWCOUNT

		   PRINT  @TotalProcessedRecords
			
 select * from #Tmp_HoldData 
PRINT '4'  + CONVERT (VARCHAR(50),GETDATE(),109)
			

	 IF @TotalProcessedRecords=0
			BEGIN 
                PRINT '5'  + CONVERT (VARCHAR(50),GETDATE(),109)	
						
				UPDATE [RVRS_testdb].[RVRS].[Execution]
						SET ExecutionStatus='Completed'
						,LastLoadDate=@LastLoadedDate						
						,EndTime=@CurentTime
						,TotalProcessedRecords=0
						,TotalLoadedRecord=0
						,TotalErrorRecord=0
						,TotalPendingReviewRecord=0
						,TotalWarningRecord=0
					WHERE ExecutionId=@ExecutionId
			
					RETURN 
			END
			
				
/*
----------------------------------------------------------------------------------------------------------------------------------------------
4 - Check if there is parent  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
IF (SElECT count(1) from #Tmp_HoldData where PersonId is not null ) = 0
			BEGIN
					UPDATE [RVRS_testdb].[RVRS].[Execution]
					SET ExecutionStatus=@ExecutionStatus
						,LastLoadDate=@LastLoadedDate					
						,EndTime=@CurentTime
						,TotalProcessedRecords=@TotalProcessedRecords
						,TotalLoadedRecord=@TotalLoadedRecord
						,TotalErrorRecord=@TotalErrorRecord
						,TotalPendingReviewRecord=@TotalPendingReviewRecord
						,TotalWarningRecord=@TotalWarningRecord
					WHERE ExecutionId=@ExecutionId
					SET @Err_Message ='We do not have data for '+ CONVERT(VARCHAR(50),@MAXDateinData,106) +'in Person Table'
					RAISERROR (@Err_Message,10,1)			
			END
		
			
SET @MAXDateinData = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)
PRINT  @MAXDateinData
SET @LastLoadedDate = @MAXDateinData

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
5 - Validation checking  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '6'  + CONVERT (VARCHAR(50),GETDATE(),109)	
					
   
		SELECT *
			
	        ,CASE WHEN COALESCE(FirstName,'')<>COALESCE(FirstNameTab1,'') THEN 'FirstName,Person.FirstName|Warning:FirstName Mismatch in Decedent and Autopsy page' ELSE '' END AS LoadNote_1
	        ,CASE WHEN LEFT(FirstName,1) LIKE '[^a-zA-Z]' AND FirstName NOT LIKE '-%' THEN 'FirstName|Error:FirstName does not start with Alphabet' ELSE '' END AS LoadNote_2
	        ,CASE WHEN COALESCE(MiddleName,'')<>COALESCE(MiddleNameTab1,'') THEN 'MiddleName,Person.MiddleNameTab1|Warning:MiddleName Mismatch in Decedent and Autopsy' ELSE '' END AS LoadNote_3
	        ,CASE WHEN LEFT(MiddleName,1) LIKE '[^a-zA-Z]' and MiddleName NOT LIKE '-%' THEN 'MiddleName|Error:MiddleName does not start with Alphabet' ELSE '' END AS LoadNote_4
	        ,CASE WHEN COALESCE(LastName,'')<>COALESCE(LastNameTab1,'') THEN 'LastName,Person.LastNameTab1|Warning:LastName Mismatch in Tab Decedent and Autopsy Mismatch' ELSE '' END AS LoadNote_5
	        ,CASE WHEN LEFT(LastName,1) LIKE '[^a-zA-Z]' and LastName NOT LIKE '-%' THEN 'LastName|Error:LastName does not start with Alphabet' ELSE '' END AS LoadNote_6
	        ,CASE WHEN (ME_MNAME_NONE = 'Y' AND MiddleName IS NOT NULL) OR (ME_MNAME_NONE = 'N' AND MiddleName IS NULL) THEN 'MiddleName,ME_MNAME_NONE|Warning:Mismatch between MiddleName and NoMiddleName fields' ELSE '' END AS LoadNote_7
	        ,CASE WHEN COALESCE(Suffix,'')<>COALESCE(SuffixTab1,'') THEN 'Suffix,Person.Suffix|Warning:Suffix Mismatch in Decedent and Autopsy page ' ELSE '' END AS LoadNote_8
	        ,CASE WHEN COALESCE(Sex,'')<>COALESCE(SexTab1,'') THEN 'Sex,Person.Sex|Warning:Sex Mismatch in Decedent and Autopsy page' ELSE '' END AS LoadNote_9
	        ,CASE WHEN COALESCE(ME_DOB,'')<>COALESCE(DobTab1,'') THEN 'ME_DOB,DOB|Warning:Date of Birth Mismatch in Decedent and Autopsy page' ELSE '' END AS LoadNote_10
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(ME_DOB,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'ME_DOB|Error:Not a valid Date of Birth' ELSE '' END AS LoadNote_11
	        ,CASE WHEN TRY_CAST (ME_DOD AS DateTime)<TRY_CAST(ME_DOB AS DateTime) THEN 'ME_DOB,ME_DOD|Error:Date of Birth is greater than Date of Death' ELSE '' END AS LoadNote_12
	        ,CASE WHEN TRY_CAST (ME_DOB AS DateTime)<'01/01/1885' AND Try_Cast(ME_DOB AS DateTime)>GETDATE() THEN 'ME_DOB|Error:Date of Birth is not in valid range' ELSE '' END AS LoadNote_13
	        ,CASE WHEN ME_DOB NOT LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'ME_DOB|Error:Date of Birth is not in valid format' ELSE '' END AS LoadNote_14
	        ,CASE WHEN CaseYear<2014 or CaseYear>YEAR(GETDATE()) THEN 'CaseYear|Error:Case Year is not in a valid range' ELSE '' END AS LoadNote_15
	        ,CASE WHEN COALESCE(ME_DOD,'')<>COALESCE(DODTab1,'') THEN 'ME_DOD,DOD_4_FD|Warning:Date of Death Mismatch in Decedent and Autopsy page' ELSE '' END AS LoadNote_16
	        ,CASE WHEN ISDATE(ME_DOD)=0 THEN 'ME_DOD|Error:Not a valid Date of Death' ELSE '' END AS LoadNote_17
	        ,CASE WHEN ME_DOD<'01/01/2014' AND ME_DOD>GETDATE() THEN 'ME_DOD|Error:Year of Death is not in valid range' ELSE '' END AS LoadNote_18
	        ,CASE WHEN ME_DOD IS NULL THEN 'ME_DOD|Error:No value for Death of Death' ELSE '' END AS LoadNote_19
	        ,CASE WHEN ME_DOD not like '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'ME_DOD|Error:Not a valid format for Date of Death' ELSE '' END AS LoadNote_20
	        ,CASE WHEN ME_TOD<>TOD THEN 'ME_TOD,TOD|Warning:Time of Death Mismatch in Decedent and Autopsy page ' ELSE '' END AS LoadNote_21
	        ,CASE WHEN ((TimeInd ='M' AND ISDATE(REPLACE(ME_TOD,'99','01')) = 0) OR (TimeInd IN( 'A', 'P') 
							AND ISDATE(ME_TOD + REPLACE(REPLACE(TimeInd,'A','AM'),'P','PM')) = 0)) THEN 'ME_TOD|Error:Time of death not in a valid  range' ELSE '' END AS LoadNote_22
	        ,CASE WHEN ME_TOD NOT LIKE '[0-9][0-9]:[0-9][0-9]' THEN 'ME_TOD|Error:Not a valid format for Time of Death' ELSE '' END AS LoadNote_23
	        ,CASE WHEN ME_TOD LIKE '12:00' AND TimeInd NOT IN ('N','D') THEN 'ME_TOD,ME_TOD_IN|Error:Time of Death not in align with Time Indicator' ELSE '' END AS LoadNote_24
	        ,CASE WHEN COALESCE(ME_PRO_DATE,'')<>COALESCE(ProDateTab5A,'') THEN 'ME_PRO_DATE,PRO_DATE|Warning:Pronounced Date of Death Mismatch in Pronouncement and Autopsy page' ELSE '' END AS LoadNote_25
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(ME_PRO_DATE,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'ME_PRO_DATE|Error:Not a valid Pronounced Date of Death' ELSE '' END AS LoadNote_26
	        ,CASE WHEN TRY_CAST (ME_PRO_DATE AS DateTime)<Try_Cast (ME_DOD AS DateTime) THEN 'ME_PRO_DATE,ME_DOD|Error:Pronounced Date of Death is before Date of Death' ELSE '' END AS LoadNote_27
	        ,CASE WHEN TRY_CAST(ME_PRO_DATE AS DATE)<'01/01/2014' AND TRY_CAST(ME_PRO_DATE AS DATE)>GETDATE() THEN 'ME_PRO_DATE|Error:Pronouncement date of Death is not in a valid range' ELSE '' END AS LoadNote_28
	        ,CASE WHEN ME_PRO_DATE not like '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'ME_PRO_DATE|Error:Not a valid format for Pronounced Date of Death' ELSE '' END AS LoadNote_29
	        ,CASE WHEN ME_PRO_TIME<>ProTimeTab5A THEN 'ME_PRO_TIME,PRO_TIME|Warning:Pronounced Time of Death in Pronouncement and Certfier Mismatch' ELSE '' END AS LoadNote_30
	        ,CASE WHEN ((PronouncedTimeInd ='M' AND ISDATE(REPLACE(ME_PRO_TIME,'99','01')) = 0) OR (PronouncedTimeInd IN( 'A', 'P') 
							AND ISDATE(ME_PRO_TIME + REPLACE(REPLACE(PronouncedTimeInd,'A','AM'),'P','PM')) = 0)) THEN 'ME_PRO_TIME|Error:Time of Pronouncement is not in a valid range' ELSE '' END AS LoadNote_31
	        ,CASE WHEN ME_PRO_TIME NOT LIKE '[0-9][0-9]:[0-9][0-9]' THEN 'ME_PRO_TIME|Error:Not a valid format for Pronounced Time of Death' ELSE '' END AS LoadNote_32
	        ,CASE WHEN ME_PRO_TIME LIKE '12:00' AND PronouncedTimeInd NOT IN ('N','D') THEN 'ME_PRO_TIME,PronouncedTimeInd|Warning:Pronounced Time of Death not in align with Pronounced Time Indicator' ELSE '' END AS LoadNote_33
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  FirstName_DC VARCHAR(128),MiddleName_DC VARCHAR(128),LastName_DC VARCHAR(128),Suffix_DC VARCHAR(128), FirstName_Flag BIT NOT NULL DEFAULT 0 ,MiddleName_Flag BIT NOT NULL DEFAULT 0 ,LastName_Flag BIT NOT NULL DEFAULT 0 ,Suffix_Flag BIT NOT NULL DEFAULT 0 ,DeathMedicalRecord_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '') +  IIF( LoadNote_7 <> '',  '||' + LoadNote_7, '') +  IIF( LoadNote_8 <> '',  '||' + LoadNote_8, '') +  IIF( LoadNote_9 <> '',  '||' + LoadNote_9, '') +  IIF( LoadNote_10 <> '',  '||' + LoadNote_10, '') +  IIF( LoadNote_11 <> '',  '||' + LoadNote_11, '') +  IIF( LoadNote_12 <> '',  '||' + LoadNote_12, '') +  IIF( LoadNote_13 <> '',  '||' + LoadNote_13, '') +  IIF( LoadNote_14 <> '',  '||' + LoadNote_14, '') +  IIF( LoadNote_15 <> '',  '||' + LoadNote_15, '') +  IIF( LoadNote_16 <> '',  '||' + LoadNote_16, '') +  IIF( LoadNote_17 <> '',  '||' + LoadNote_17, '') +  IIF( LoadNote_18 <> '',  '||' + LoadNote_18, '') +  IIF( LoadNote_19 <> '',  '||' + LoadNote_19, '') +  IIF( LoadNote_20 <> '',  '||' + LoadNote_20, '') +  IIF( LoadNote_21 <> '',  '||' + LoadNote_21, '') +  IIF( LoadNote_22 <> '',  '||' + LoadNote_22, '') +  IIF( LoadNote_23 <> '',  '||' + LoadNote_23, '') +  IIF( LoadNote_24 <> '',  '||' + LoadNote_24, '') +  IIF( LoadNote_25 <> '',  '||' + LoadNote_25, '') +  IIF( LoadNote_26 <> '',  '||' + LoadNote_26, '') +  IIF( LoadNote_27 <> '',  '||' + LoadNote_27, '') +  IIF( LoadNote_28 <> '',  '||' + LoadNote_28, '') +  IIF( LoadNote_29 <> '',  '||' + LoadNote_29, '') +  IIF( LoadNote_30 <> '',  '||' + LoadNote_30, '') +  IIF( LoadNote_31 <> '',  '||' + LoadNote_31, '') +  IIF( LoadNote_32 <> '',  '||' + LoadNote_32, '') +  IIF( LoadNote_33 <> '',  '||' + LoadNote_33, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathMedicalRecord_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathMedicalRecord_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE DeathMedicalRecord_FirstName WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Data_Conversion TABLE*/		
			
  			
			UPDATE MT
				SET 
				FirstName_DC= DC.Mapping_Current
				,MT.FirstName_Flag=1
				,MT.LoadNote='FirstName|Warning:DeathMedicalRecord_FirstName got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.FirstName
			WHERE  DC.TableName='Data_Conversion'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE DeathMedicalRecord_MiddleName WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Data_Conversion TABLE*/		
			
  			
			UPDATE MT
				SET 
				MiddleName_DC= DC.Mapping_Current
				,MT.MiddleName_Flag=1
				,MT.LoadNote='MiddleName|Warning:DeathMedicalRecord_MiddleName got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.MiddleName
			WHERE  DC.TableName='Data_Conversion'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '9' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE DeathMedicalRecord_LastName WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN Data_Conversion TABLE*/		
			
  			
			UPDATE MT
				SET 
				LastName_DC= DC.Mapping_Current
				,MT.LastName_Flag=1
				,MT.LoadNote='LastName|Warning:DeathMedicalRecord_LastName got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.LastName
			WHERE  DC.TableName='Data_Conversion'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '10' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimSuffixId INT
		
			UPDATE MT
			SET MT.DimSuffixId =DS.DimSuffixId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS WITH(NOLOCK) ON DS.SuffixDesc=MT.Suffix

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS_Staging].[RVRS].[Data_Conversion] TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimSuffixId=DC.Mapping_Current_ID,
				Suffix_DC= DC.Mapping_Current
				,MT.Suffix_Flag=1
				,MT.LoadNote='Suffix|Warning:DimSuffixId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_Staging].[RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.Suffix
			WHERE  DC.TableName='DimSuffix'
				AND MT.DimSuffixId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '11' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathMedicalRecord_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS_Staging].[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathMedicalRecord_Log_Flag=1
					   , LoadNote = 'Suffix|Pending Review:Not a valid Suffix' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimSuffixId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimSex TABLE AND UPDATE THE DimSexId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimSexId INT
		
			UPDATE MT
			SET MT.DimSexId =DS.DimSexId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSex] DS WITH(NOLOCK) ON DS.Abbr=MT.Sex

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathMedicalRecord_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS_Staging].[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathMedicalRecord_Log_Flag=1
					   , LoadNote = 'Sex|Pending Review:Not a valid Sex' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimSexId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimTimeInd TABLE AND UPDATE THE DimTimeIndId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimTimeIndId INT
		
			UPDATE MT
			SET MT.DimTimeIndId =DS.DimTimeIndId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] DS WITH(NOLOCK) ON DS.Abbr=MT.TimeInd

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathMedicalRecord_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS_Staging].[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathMedicalRecord_Log_Flag=1
					   , LoadNote = 'TimeInd|Pending Review:Not a valid TimeInd' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimTimeIndId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimTimeInd TABLE AND UPDATE THE DimPronouncedTimeIndId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimPronouncedTimeIndId INT
		
			UPDATE MT
			SET MT.DimPronouncedTimeIndId =DS.DimTimeIndId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] DS WITH(NOLOCK) ON DS.Abbr=MT.PronouncedTimeInd

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			

	       /*UPDATING THE DeathMedicalRecord_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS_Staging].[RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathMedicalRecord_Log_Flag=1
					   , LoadNote = 'PronouncedTimeInd|Pending Review:Not a valid PronouncedTimeInd' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimPronouncedTimeIndId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathMedicalRecord_Log_Flag=1
					,LoadNote= 'Person|ParentMissing:Validation Errors' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					WHERE PersonId IS NULL
					AND SrId IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log WITH(NOLOCK))

				SET @RecordCountDebug=@@ROWCOUNT 
				
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 5
				UPDATE #Tmp_HoldData_Final
					SET LoadNote='Person|ParentMissing:Not Processed' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					 WHERE PersonId IS NULL
					  AND SrId NOT IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log WITH(NOLOCK))
					  AND DeathMedicalRecord_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathMedicalRecord_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM [RVRS_Staging].RVRS.Person_Log)
                                 AND DeathMedicalRecord_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
 select * from #Tmp_HoldData_Final 
 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS WITH(NOLOCK) 
			 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSex] DS WITH(NOLOCK) 
			 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] DS WITH(NOLOCK) 
			 SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] DS WITH(NOLOCK) 
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_testdb].[RVRS].[DeathMedicalRecord]
			(
				 [PersonId],[RecordNumber],[CaseYear],[CaseNumber],[FirstName],[MiddleName],[LastName],[DimSuffixId],[DimSexId],[BirthYear],[BirthMonth],[BirthDay],[DeathYear],[DeathMonth],[DeathDay],[DeathHour],[DeathMinute],[DimTimeIndId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[RecordNumber],[CaseYear],[CaseNumber], ISNULL([FirstName_DC],[FirstName]), ISNULL([MiddleName_DC],[MiddleName]), ISNULL([LastName_DC],[LastName]),[DimSuffixId],[DimSexId],[BirthYear],[BirthMonth],[BirthDay],[DeathYear],[DeathMonth],[DeathDay],[DeathHour],[DeathMinute],[DimTimeIndId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathMedicalRecord_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathMedicalRecord]
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS_testdb].[RVRS].[DeathMedicalRecord_Log]
			(
				 SrId, FirstName_DC ,MiddleName_DC ,LastName_DC ,Suffix_DC 
				 , [PersonId],[RecordNumber],[CaseYear],[CaseNumber],[FirstName],[MiddleName],[LastName],[DimSuffixId],[DimSexId],[BirthYear],[BirthMonth],[BirthDay],[DeathYear],[DeathMonth],[DeathDay],[DeathHour],[DeathMinute],[DimTimeIndId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]	
				 , FirstNameTab1,MiddleNameTab1,LastNameTab1,Suffix,SuffixTab1,Sex,SexTab1,ME_DOB,DobTab1,ME_DOD,DodTab1,ME_TOD,TimeInd,ProDateTab5A,ME_PRO_DATE,ME_PRO_TIME,PronouncedTimeInd,ME_MNAME_NONE,TOD,ProTimeTab5A
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathMedicalRecord_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , FirstName_DC ,MiddleName_DC ,LastName_DC ,Suffix_DC 
				, [PersonId],[RecordNumber],[CaseYear],[CaseNumber],[FirstName],[MiddleName],[LastName],[DimSuffixId],[DimSexId],[BirthYear],[BirthMonth],[BirthDay],[DeathYear],[DeathMonth],[DeathDay],[DeathHour],[DeathMinute],[DimTimeIndId],[PronouncedYear],[PronouncedMonth],[PronouncedDay],[PronouncedHour],[PronouncedMinute],[DimPronouncedTimeIndId]
				, FirstNameTab1,MiddleNameTab1,LastNameTab1,Suffix,SuffixTab1,Sex,SexTab1,ME_DOB,DobTab1,ME_DOD,DodTab1,ME_TOD,TimeInd,ProDateTab5A,ME_PRO_DATE,ME_PRO_TIME,PronouncedTimeInd,ME_MNAME_NONE,TOD,ProTimeTab5A
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathMedicalRecord_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathMedicalRecord_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathMedicalRecord_Log] 
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DeathMedicalRecord_FirstName*/

			INSERT INTO [RVRS_testdb].[RVRS].[DeathOriginal]
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
				,'DeathMedicalRecord' AS Entity
				,'DeathMedicalRecordId' AS EntityColumnName
				,PA.DeathMedicalRecordId AS EntityId
				,'DeathMedicalRecord_FirstName' AS ConvertedColumn
				,MT.FirstName AS OriginalValue
				,MT.FirstName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[DeathMedicalRecord]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.FirstName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DeathMedicalRecord_MiddleName*/

			INSERT INTO [RVRS_testdb].[RVRS].[DeathOriginal]
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
				,'DeathMedicalRecord' AS Entity
				,'DeathMedicalRecordId' AS EntityColumnName
				,PA.DeathMedicalRecordId AS EntityId
				,'DeathMedicalRecord_MiddleName' AS ConvertedColumn
				,MT.MiddleName AS OriginalValue
				,MT.MiddleName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[DeathMedicalRecord]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.MiddleName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DeathMedicalRecord_LastName*/

			INSERT INTO [RVRS_testdb].[RVRS].[DeathOriginal]
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
				,'DeathMedicalRecord' AS Entity
				,'DeathMedicalRecordId' AS EntityColumnName
				,PA.DeathMedicalRecordId AS EntityId
				,'DeathMedicalRecord_LastName' AS ConvertedColumn
				,MT.LastName AS OriginalValue
				,MT.LastName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[DeathMedicalRecord]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.LastName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimSuffixId*/

			INSERT INTO [RVRS_testdb].[RVRS].[DeathOriginal]
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
				,'DeathMedicalRecord' AS Entity
				,'DeathMedicalRecordId' AS EntityColumnName
				,PA.DeathMedicalRecordId AS EntityId
				,'DimSuffixId' AS ConvertedColumn
				,MT.Suffix AS OriginalValue
				,MT.Suffix_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_testdb].[RVRS].[DeathMedicalRecord]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.Suffix_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
 select * from [RVRS_testdb].[RVRS].[DeathOriginal] WHERE Entity = 'DeathMedicalRecord'
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathMedicalRecord_Log_Flag=1
									AND LoadNote LIKE '%|Pending Review%')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'
								AND LoadNote LIKE '%|WARNING%')
	UPDATE [RVRS_testdb].[RVRS].[Execution]
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

		
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
 select * from [RVRS_testdb].[RVRS].[Execution] WHERE Entity= 'DeathMedicalRecord'
END TRY
 BEGIN CATCH
		PRINT 'CATCH'
		UPDATE [RVRS_testdb].[RVRS].[Execution]
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

/*
----------------------------------------------------------------------------------------------------------------------------------------------
														END END END
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	


