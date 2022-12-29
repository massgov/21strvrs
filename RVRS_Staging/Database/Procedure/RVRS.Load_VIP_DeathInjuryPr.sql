

IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathInjuryPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathInjuryPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathInjuryPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathInjuryPr]
AUTHOR	:Sailendra Singh
CREATED	:Dec 28 2022  
PURPOSE	:TO LOAD DATA INTO FACT DeathInjury TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Dec 28 2022 		Sailendra Singh						RVRS 170 : LOAD DECEDENT DeathInjury DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal] WHERE Entity = 'DeathInjury'
TRUNCATE TABLE [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathInjury]
DROP TABLE [RVRS].[DeathInjury_Log]
DELETE FROM [RVRS].[Execution] WHERE Entity = 'DeathInjury'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathInjuryPr]
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


IF OBJECT_ID('[RVRS].[DeathInjury_Log]') IS NULL 
	CREATE TABLE [RVRS].[DeathInjury_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), InjuryNature_DC VARCHAR(128),InjuryPlace_DC VARCHAR(128),InjuryPlaceOther_DC VARCHAR(128),InjuryTransportOther_DC VARCHAR(128), [PersonId] BIGINT,[InjuryYear] VARCHAR(16),[InjuryMonth] VARCHAR(16),[InjuryDay] VARCHAR(16),[InjuryHour] VARCHAR(16),[InjuryMinute] VARCHAR(16),[DimInjuryTimeIndId] INT,[DimInjuryAtWorkId] INT,[InjuryNature] VARCHAR(512),[DimInjuryPlaceId] INT,[DimOtherInjuryPlaceId] INT,[DimInjuryTransportId] INT,[DimInjuryTransportOtherId] INT, DOD VARCHAR(128),DOI VARCHAR(128),TOI VARCHAR(128),InjuryTimeInd VARCHAR(128),InjuryAtWork VARCHAR(128),InjuryPlace VARCHAR(128),InjuryPlaceOther VARCHAR(128),InjuryTransport VARCHAR(128),InjuryTransportOther VARCHAR(128),Certifier VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathInjury_Log_Flag BIT ,LoadNote VARCHAR(MAX))

BEGIN TRY

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
2 - Set Execution intial status
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
PRINT '1'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			
INSERT INTO [RVRS].[Execution] 
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
		SELECT 'DeathInjury' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathInjury' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT   D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,DOD DOD,DOI DOI,RIGHT(DOI,4) InjuryYear,LEFT(DOI,2) InjuryMonth,SUBSTRING(DOI,4,2) InjuryDay,TOI TOI,LEFT(TOI,2) InjuryHour,RIGHT(TOI,2) InjuryMinute,COALESCE(TOI_IND,'NULL') InjuryTimeInd,COALESCE(INJRY_WORK,'NULL') InjuryAtWork,INJRY_L InjuryNature,COALESCE(INJRY_PLACEL,'NULL') InjuryPlace,COALESCE(INJRY_PLACEL,'NULL') InjuryPlaceOther,COALESCE(INJRY_TRANSPRT,'NULL') InjuryTransport,COALESCE(INJRY_TRANSPRT_OTHER,'NULL') InjuryTransportOther,COALESCE(CERT_DESIG,'NULL') Certifier
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
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
			
PRINT '4'  + CONVERT (VARCHAR(50),GETDATE(),109)
			

	 IF @TotalProcessedRecords=0
			BEGIN 
                PRINT '5'  + CONVERT (VARCHAR(50),GETDATE(),109)	
						
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
			
					RETURN 
			END
			
				
/*
----------------------------------------------------------------------------------------------------------------------------------------------
4 - Check if there is parent  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
IF (SElECT count(1) from #Tmp_HoldData where PersonId is not null ) = 0
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
			
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(DOI,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'DOI|Error:Not a valid Date of Injury' ELSE '' END AS LoadNote_1
	        ,CASE WHEN Try_Cast(DOI AS DateTime)>GETDATE() THEN 'DOI|Error:Date of Injury is greater than Current Date' ELSE '' END AS LoadNote_2
	        ,CASE WHEN DOI NOT LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'DOI|Error:Date of Injury is not in valid format' ELSE '' END AS LoadNote_3
	        ,CASE WHEN TRY_CAST (DOD AS DateTime)<TRY_CAST(DOI AS DateTime) THEN 'DOI,DOD|Error:Date of Injury is greater than Date of Death' ELSE '' END AS LoadNote_4
	        ,CASE WHEN DOI IS NOT NULL AND Certifier <>'MEDICAL EXAMINER' AND DOI<>'99/99/9999' THEN 'DOI,Death.DimCertifierDesignId|Error:When Date of Injury is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_5
	        ,CASE WHEN ((InjuryTimeInd ='M' AND ISDATE(REPLACE(TOI,'99','01')) = 0) OR (InjuryTimeInd IN( 'A', 'P') 
							AND ISDATE(TOI + REPLACE(REPLACE(InjuryTimeInd,'A','AM'),'P','PM')) = 0)) THEN 'TOI,DimInjuryTimeIndId|Error:Time of Injury not in a valid  range' ELSE '' END AS LoadNote_6
	        ,CASE WHEN TOI NOT LIKE '[0-9][0-9]:[0-9][0-9]' THEN 'TOI|Error:Not a valid format for Time of Injury' ELSE '' END AS LoadNote_7
	        ,CASE WHEN TOI IS NOT NULL AND Certifier <>'MEDICAL EXAMINER' AND TOI<>'99:99' THEN 'TOI,Death.DimCertifierDesignId|Error:When Time of Injury is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_8
	        ,CASE WHEN TOI LIKE '12:00' AND InjuryTimeInd NOT IN ('N','D') THEN 'TOI,InjuryTimeInd|Error:Time of Injury not in align with Time Indicator' ELSE '' END AS LoadNote_9
	        ,CASE WHEN InjuryTimeInd  <> 'NULL'  AND Certifier <>'MEDICAL EXAMINER' THEN 'DimInjuryTimeIndId,Death.DimCertifierDesignId|Error:When Time Indicator of Injury is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_10
	        ,CASE WHEN InjuryAtWork= 'Y' AND (InjuryNature IS NULL OR InjuryPlace IS NULL OR InjuryTransport IS NULL) THEN 'DimInjuryAtWorkId,InjuryNature,DimInjuryPlaceID,DimInjuryTransportID|Error:Injury occurred at work but InjuryNature Or InjuryPlace is missing' ELSE '' END AS LoadNote_11
	        ,CASE WHEN InjuryAtWork= 'Y' AND Certifier <>'MEDICAL EXAMINER' THEN 'Death.DimCertifierDesignId,DimInjuryAtWorkId|Error:When Injury at Work is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_12
	        ,CASE WHEN InjuryNature IS NOT NULL AND Certifier <>'MEDICAL EXAMINER' THEN 'InjuryNature,Death.DimCertifierDesignId|Error:When Injury Nature is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_13
	        ,CASE WHEN InjuryPlace  <> 'NULL'  AND InjuryAtWork= 'Y' AND Certifier <>'MEDICAL EXAMINER'  THEN 'DimInjuryPlaceId,Death.DimCertifierDesignId|Error:Injury occurred at work but InjuryAtWork is missing' ELSE '' END AS LoadNote_14
	        ,CASE WHEN InjuryTransport  <> 'NULL'AND Certifier <>'MEDICAL EXAMINER' THEN 'DimInjuryTransportId,Death.DimCertifierDesignId|Error:When Injury Transport is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_15
	        ,CASE WHEN InjuryTransportOther <> 'NULL' AND Certifier <>'MEDICAL EXAMINER' THEN 'DimInjuryTransportOtherId,Death.DimCertifierDesignId|Error:When Injury Transport Other is populated Certifier should be Medical Examiner' ELSE '' END AS LoadNote_16
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  InjuryNature_DC VARCHAR(128),InjuryPlace_DC VARCHAR(128),InjuryPlaceOther_DC VARCHAR(128),InjuryTransportOther_DC VARCHAR(128), InjuryNature_Flag BIT NOT NULL DEFAULT 0 ,InjuryPlace_Flag BIT NOT NULL DEFAULT 0 ,InjuryPlaceOther_Flag BIT NOT NULL DEFAULT 0 ,InjuryTransportOther_Flag BIT NOT NULL DEFAULT 0 ,DeathInjury_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '') +  IIF( LoadNote_7 <> '',  '||' + LoadNote_7, '') +  IIF( LoadNote_8 <> '',  '||' + LoadNote_8, '') +  IIF( LoadNote_9 <> '',  '||' + LoadNote_9, '') +  IIF( LoadNote_10 <> '',  '||' + LoadNote_10, '') +  IIF( LoadNote_11 <> '',  '||' + LoadNote_11, '') +  IIF( LoadNote_12 <> '',  '||' + LoadNote_12, '') +  IIF( LoadNote_13 <> '',  '||' + LoadNote_13, '') +  IIF( LoadNote_14 <> '',  '||' + LoadNote_14, '') +  IIF( LoadNote_15 <> '',  '||' + LoadNote_15, '') +  IIF( LoadNote_16 <> '',  '||' + LoadNote_16, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathInjury_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathInjury_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM DimTimeInd TABLE AND UPDATE THE DimInjuryTimeIndId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimInjuryTimeIndId INT
		
			UPDATE MT
			SET MT.DimInjuryTimeIndId =DS.DimTimeIndId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimTimeInd] DS WITH(NOLOCK) ON DS.Abbr=MT.InjuryTimeInd

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
 
/*THIS CODE IS TO GET MATCH FROM DimYesNo TABLE AND UPDATE THE DimInjuryAtWorkId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimInjuryAtWorkId INT
		
			UPDATE MT
			SET MT.DimInjuryAtWorkId =DS.DimYesNoId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimYesNo] DS WITH(NOLOCK) ON DS.Abbr=MT.InjuryAtWork

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
 
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE InjuryNature WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathInjury_InjuryNature TABLE*/		
			
  			
			UPDATE MT
				SET 
				InjuryNature_DC= DC.Mapping_Current
				,MT.InjuryNature_Flag=1
				,MT.LoadNote='InjuryNature|Warning:InjuryNature got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.InjuryNature
			WHERE  DC.TableName='DeathInjury_InjuryNature'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM DimInjuryPlace TABLE AND UPDATE THE DimInjuryPlaceId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimInjuryPlaceId INT
		
			UPDATE MT
			SET MT.DimInjuryPlaceId =DS.DimInjuryPlaceId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimInjuryPlace] DS WITH(NOLOCK) ON DS.InjuryPlaceDesc=MT.InjuryPlace

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[DeathInjury_InjuryPlace_Data_Conversion] TABLE AND UPDATE THE DimInjuryPlaceId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimInjuryPlace TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimInjuryPlaceId=DC.Mapping_Current_ID,
				InjuryPlace_DC= DC.Mapping_Current
				,MT.InjuryPlace_Flag=1
				,MT.LoadNote='InjuryPlace|Warning:DimInjuryPlaceId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[DeathInjury_InjuryPlace_Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.InjuryPlace
			WHERE  DC.TableName='DimInjuryPlace'
				AND MT.DimInjuryPlaceId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '9' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathInjury_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[DeathInjury_InjuryPlace_Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathInjury_Log_Flag=1
					   , LoadNote = 'InjuryPlace|Pending Review:Not a valid InjuryPlace' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimInjuryPlaceId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimOtherInjuryPlace TABLE AND UPDATE THE DimOtherInjuryPlaceId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimOtherInjuryPlaceId INT

			/*ONLY THIS SECTION MODIFIED SINCE WE COULD NOT ADJUST IN CODE LAYOUT */

			UPDATE MT
			SET MT.DimOtherInjuryPlaceId = 0
			FROM #Tmp_HoldData_Final MT
			WHERE MT.DimInjuryPlaceId <> 9

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))

		/***********************************************************************/
		
			UPDATE MT
			SET MT.DimOtherInjuryPlaceId =DS.DimOtherInjuryPlaceId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimOtherInjuryPlace] DS WITH(NOLOCK) ON DS.OtherInjuryPlaceDesc=MT.InjuryPlaceOther AND MT.DimInjuryPlaceId = 9 OR MT.InjuryPlaceOther = 'NULL'

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimOtherInjuryPlaceId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimOtherInjuryPlace TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimOtherInjuryPlaceId=DC.Mapping_Current_ID,
				InjuryPlaceOther_DC= DC.Mapping_Current
				,MT.InjuryPlaceOther_Flag=1
				,MT.LoadNote='InjuryPlaceOther|Warning:DimOtherInjuryPlaceId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.InjuryPlaceOther
			WHERE  DC.TableName='DimOtherInjuryPlace'
				AND MT.DimOtherInjuryPlaceId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '10' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathInjury_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathInjury_Log_Flag=1
					   , LoadNote = 'InjuryPlaceOther|Pending Review:Not a valid InjuryPlaceOther' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimOtherInjuryPlaceId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimInjuryTransport TABLE AND UPDATE THE DimInjuryTransportId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimInjuryTransportId INT
		
			UPDATE MT
			SET MT.DimInjuryTransportId =DS.DimInjuryTransportId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimInjuryTransport] DS WITH(NOLOCK) ON DS.InjuryTransportDesc=MT.InjuryTransport

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
 
/*THIS CODE IS TO GET MATCH FROM DimInjuryTransportOther TABLE AND UPDATE THE DimInjuryTransportOtherId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimInjuryTransportOtherId INT
		
			UPDATE MT
			SET MT.DimInjuryTransportOtherId =DS.DimInjuryTransportOtherId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimInjuryTransportOther] DS WITH(NOLOCK) ON DS.InjuryTransportOtherDesc=MT.InjuryTransportOther

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimInjuryTransportOtherId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimInjuryTransportOther TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimInjuryTransportOtherId=DC.Mapping_Current_ID,
				InjuryTransportOther_DC= DC.Mapping_Current
				,MT.InjuryTransportOther_Flag=1
				,MT.LoadNote='InjuryTransportOther|Warning:DimInjuryTransportOtherId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.InjuryTransportOther
			WHERE  DC.TableName='DimInjuryTransportOther'
				AND MT.DimInjuryTransportOtherId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '11' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathInjury_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathInjury_Log_Flag=1
					   , LoadNote = 'InjuryTransportOther|Pending Review:Not a valid InjuryTransportOther' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimInjuryTransportOtherId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathInjury_Log_Flag=1
					,LoadNote= 'Person|ParentMissing:Validation Errors' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					WHERE PersonId IS NULL
					AND SrId IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))

				SET @RecordCountDebug=@@ROWCOUNT 
				
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 5
				UPDATE #Tmp_HoldData_Final
					SET LoadNote='Person|ParentMissing:Not Processed' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
					 WHERE PersonId IS NULL
					  AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log WITH(NOLOCK))
					  AND DeathInjury_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathInjury_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
                                 AND DeathInjury_Log_Flag = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus='Failed'
                                 set @Note = 'Parent table has not been processed yet'
                           END

					SET @RecordCountDebug=@@ROWCOUNT
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))  
/*
----------------------------------------------------------------------------------------------------------------------------------------------
10 - LOAD to Target    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathInjury]
			(
				 [PersonId],[InjuryYear],[InjuryMonth],[InjuryDay],[InjuryHour],[InjuryMinute],[DimInjuryTimeIndId],[DimInjuryAtWorkId],[InjuryNature],[DimInjuryPlaceId],[DimOtherInjuryPlaceId],[DimInjuryTransportId],[DimInjuryTransportOtherId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[InjuryYear],[InjuryMonth],[InjuryDay],[InjuryHour],[InjuryMinute],[DimInjuryTimeIndId],[DimInjuryAtWorkId], ISNULL([InjuryNature_DC],[InjuryNature]),[DimInjuryPlaceId],[DimOtherInjuryPlaceId],[DimInjuryTransportId],[DimInjuryTransportOtherId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathInjury_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS].[DeathInjury_Log]
			(
				 SrId, InjuryNature_DC ,InjuryPlace_DC ,InjuryPlaceOther_DC ,InjuryTransportOther_DC 
				 , [PersonId],[InjuryYear],[InjuryMonth],[InjuryDay],[InjuryHour],[InjuryMinute],[DimInjuryTimeIndId],[DimInjuryAtWorkId],[InjuryNature],[DimInjuryPlaceId],[DimOtherInjuryPlaceId],[DimInjuryTransportId],[DimInjuryTransportOtherId]	
				 , DOD,DOI,TOI,InjuryTimeInd,InjuryAtWork,InjuryPlace,InjuryPlaceOther,InjuryTransport,InjuryTransportOther,Certifier
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathInjury_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , InjuryNature_DC ,InjuryPlace_DC ,InjuryPlaceOther_DC ,InjuryTransportOther_DC 
				, [PersonId],[InjuryYear],[InjuryMonth],[InjuryDay],[InjuryHour],[InjuryMinute],[DimInjuryTimeIndId],[DimInjuryAtWorkId],[InjuryNature],[DimInjuryPlaceId],[DimOtherInjuryPlaceId],[DimInjuryTransportId],[DimInjuryTransportOtherId]
				, DOD,DOI,TOI,InjuryTimeInd,InjuryAtWork,InjuryPlace,InjuryPlaceOther,InjuryTransport,InjuryTransportOther,Certifier
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathInjury_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathInjury_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR InjuryNature*/

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
				,'DeathInjury' AS Entity
				,'DeathInjuryId' AS EntityColumnName
				,PA.DeathInjuryId AS EntityId
				,'InjuryNature' AS ConvertedColumn
				,MT.InjuryNature AS OriginalValue
				,MT.InjuryNature_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathInjury]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.InjuryNature_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimInjuryPlaceId*/

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
				,'DeathInjury' AS Entity
				,'DeathInjuryId' AS EntityColumnName
				,PA.DeathInjuryId AS EntityId
				,'DimInjuryPlaceId' AS ConvertedColumn
				,MT.InjuryPlace AS OriginalValue
				,MT.InjuryPlace_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathInjury]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.InjuryPlace_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimOtherInjuryPlaceId*/

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
				,'DeathInjury' AS Entity
				,'DeathInjuryId' AS EntityColumnName
				,PA.DeathInjuryId AS EntityId
				,'DimOtherInjuryPlaceId' AS ConvertedColumn
				,MT.InjuryPlaceOther AS OriginalValue
				,MT.InjuryPlaceOther_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathInjury]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.InjuryPlaceOther_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimInjuryTransportOtherId*/

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
				,'DeathInjury' AS Entity
				,'DeathInjuryId' AS EntityColumnName
				,PA.DeathInjuryId AS EntityId
				,'DimInjuryTransportOtherId' AS ConvertedColumn
				,MT.InjuryTransportOther AS OriginalValue
				,MT.InjuryTransportOther_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathInjury]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.InjuryTransportOther_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathInjury_Log_Flag=1
									AND LoadNote LIKE '%|Pending Review%')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE '%|Pending Review%'
								AND LoadNote LIKE '%|WARNING%')
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

		
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
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

/*
----------------------------------------------------------------------------------------------------------------------------------------------
														END END END
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	


