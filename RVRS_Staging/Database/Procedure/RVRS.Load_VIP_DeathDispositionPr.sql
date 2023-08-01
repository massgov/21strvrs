IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathDispositionPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathDispositionPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathDispositionPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathDispositionPr]
AUTHOR	:Sailendra Singh
CREATED	:Jul 31 2023  
PURPOSE	:TO LOAD DATA INTO FACT DeathDisposition TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Jul 31 2023 		Sailendra Singh						RVRS 174 : LOAD DECEDENT DeathDisposition DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal] WHERE Entity = 'DeathDisposition'
TRUNCATE TABLE [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathDisposition]
DROP TABLE [RVRS].[DeathDisposition_Log]
DELETE FROM [RVRS].[Execution] WHERE Entity = 'DeathDisposition'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathDispositionPr]
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


IF OBJECT_ID('[RVRS].[DeathDisposition_Log]') IS NULL 
	CREATE TABLE [RVRS].[DeathDisposition_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), DispMethod_DC VARCHAR(128),OtherDispMethod_DC VARCHAR(128),DispPlace_DC VARCHAR(128), [PersonId] BIGINT,[DimDispMethodId] INT,[DimOtherDispMethodId] INT,[DispYear] VARCHAR(16),[DispMonth] VARCHAR(16),[DispDay] VARCHAR(16),[PermitStatus] VARCHAR(516),[DimDispPlaceId] INT, DispMethod VARCHAR(128),OtherDispMethod VARCHAR(128),DISP_DATE VARCHAR(128),DispPlace VARCHAR(128),CREM_CEM_UNLISTED VARCHAR(128),DOD_4_FD VARCHAR(128),CEM_NAME VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathDisposition_Log_Flag BIT ,LoadNote VARCHAR(MAX))

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
		SELECT 'DeathDisposition' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathDisposition' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,COALESCE(DISP,'NULL') DispMethod,COALESCE(DISPL,'NULL') OtherDispMethod,DISP_DATE DISP_DATE,RIGHT(DISP_DATE,4) DispYear,LEFT(DISP_DATE,2) DispMonth,SUBSTRING(DISP_DATE,4,2) DispDay,COALESCE(DISP_NME,'NULL') DispPlace,IND_PB_STATUS PermitStatus,CREM_CEM_UNLISTED CREM_CEM_UNLISTED,DOD_4_FD DOD_4_FD,CEM_NAME CEM_NAME
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate

		        INTO #Tmp_HoldData

		        FROM RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				LEFT JOIN (SELECT DISTINCT CEM_NAME FROM  [RVRS_STAGING].[RVRS].[VIP_VT_CEMETERIES_CD]  ) F ON D.DISP_NME = F.CEM_NAME	
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
			
	        ,CASE WHEN (DispMethod != 'O' AND OtherDispMethod != 'NULL') THEN 'DimDispMethodId,DimOtherDispMethodId|Error:Value in Disposition Method and Disposition Other Method is not aligned' ELSE '' END AS LoadNote_1
	        ,CASE WHEN ISDATE(REPLACE(REPLACE (COALESCE(DISP_DATE,'01/01/1900'),'/9999', '/1900'),'99/','01/'))=0 THEN 'DISP_DATE|Error:Not a valid Date of Disposition' ELSE '' END AS LoadNote_2
	        ,CASE WHEN TRY_CAST (DISP_DATE AS DateTime)<TRY_CAST(DOD_4_FD AS DateTime) THEN 'DISP_DATE,DOD_4_FD |Error:Date of Death is greater than Date of Disposition' ELSE '' END AS LoadNote_3
	        ,CASE WHEN TRY_CAST (DISP_DATE AS DateTime)<'01/01/2014' OR Try_Cast(DISP_DATE AS DateTime)>GETDATE() THEN 'DISP_DATE|Error:Date of Dispotition is not in valid range' ELSE '' END AS LoadNote_4
	        ,CASE WHEN DISP_DATE NOT LIKE '[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]' THEN 'DISP_DATE|Error:Date of Disposition is not in valid format' ELSE '' END AS LoadNote_5
	        ,CASE WHEN CREM_CEM_UNLISTED = 'N' AND DispPlace<>CEM_NAME THEN 'CREM_CEM_UNLISTED,DimDispPlaceId,VIP_VT_CEMETERIES_CD.CEM_NAME|Warning:The Name of the Cemetery does not match the Name from Code table' ELSE '' END AS LoadNote_6
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  DispMethod_DC VARCHAR(128),OtherDispMethod_DC VARCHAR(128),DispPlace_DC VARCHAR(128), DispMethod_Flag BIT NOT NULL DEFAULT 0 ,OtherDispMethod_Flag BIT NOT NULL DEFAULT 0 ,DispPlace_Flag BIT NOT NULL DEFAULT 0 ,DeathDisposition_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '') +  IIF( LoadNote_4 <> '',  '||' + LoadNote_4, '') +  IIF( LoadNote_5 <> '',  '||' + LoadNote_5, '') +  IIF( LoadNote_6 <> '',  '||' + LoadNote_6, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathDisposition_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathDisposition_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM DimDispMethod TABLE AND UPDATE THE DimDispMethodId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimDispMethodId INT
		
			UPDATE MT
			SET MT.DimDispMethodId =DS.DimDispMethodId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDispMethod] DS WITH(NOLOCK) ON DS.Abbr=MT.DispMethod

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimDispMethodId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimDispMethod TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimDispMethodId=DC.Mapping_Current_ID,
				DispMethod_DC= DC.Mapping_Current
				,MT.DispMethod_Flag=1
				,MT.LoadNote='DispMethod|Warning:DimDispMethodId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.DispMethod
			WHERE  DC.TableName='DimDispMethod'
				 AND MT.OtherDispMethod = DC.FilterValue AND DC.Mapping_Previous = 'O'

			SET @RecordCountDebug=@@ROWCOUNT 
			
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathDisposition_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathDisposition_Log_Flag=1
					   , LoadNote = 'DispMethod|Pending Review:Not a valid DispMethod' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimDispMethodId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimOtherDispMethod TABLE AND UPDATE THE DimOtherDispMethodId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimOtherDispMethodId INT
		
			UPDATE MT
			SET MT.DimOtherDispMethodId =DS.DimOtherDispMethodId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimOtherDispMethod] DS WITH(NOLOCK) ON DS.OtherDispMethodDesc=MT.OtherDispMethod

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimOtherDispMethodId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimOtherDispMethod TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimOtherDispMethodId=DC.Mapping_Current_ID,
				OtherDispMethod_DC= DC.Mapping_Current
				,MT.OtherDispMethod_Flag=1
				,MT.LoadNote='OtherDispMethod|Warning:DimOtherDispMethodId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.OtherDispMethod
			WHERE  DC.TableName='DimOtherDispMethod'
				AND MT.DimOtherDispMethodId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '9' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathDisposition_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathDisposition_Log_Flag=1
					   , LoadNote = 'OtherDispMethod|Pending Review:Not a valid OtherDispMethod' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimOtherDispMethodId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM DimDispPlace TABLE AND UPDATE THE DimDispPlaceId WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD DimDispPlaceId INT
		
			UPDATE MT
			SET MT.DimDispPlaceId =DS.DimDispPlaceId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimDispPlace] DS WITH(NOLOCK) ON DS.DispPlaceDesc=MT.DispPlace

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimDispPlaceId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimDispPlace TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimDispPlaceId=DC.Mapping_Current_ID,
				DispPlace_DC= DC.Mapping_Current
				,MT.DispPlace_Flag=1
				,MT.LoadNote='DispPlace|Warning:DimDispPlaceId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.DispPlace
			WHERE  DC.TableName='DimDispPlace'
				AND MT.DimDispPlaceId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '10' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathDisposition_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathDisposition_Log_Flag=1
					   , LoadNote = 'DispPlace|Pending Review:Not a valid DispPlace' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimDispPlaceId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathDisposition_Log_Flag=1
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
					  AND DeathDisposition_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathDisposition_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
                                 AND DeathDisposition_Log_Flag = 0

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

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathDisposition]
			(
				 [PersonId],[DimDispMethodId],[DimOtherDispMethodId],[DispYear],[DispMonth],[DispDay],[PermitStatus],[DimDispPlaceId]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId],[DimDispMethodId],[DimOtherDispMethodId],[DispYear],[DispMonth],[DispDay],[PermitStatus],[DimDispPlaceId]
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathDisposition_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS].[DeathDisposition_Log]
			(
				 SrId, DispMethod_DC ,OtherDispMethod_DC ,DispPlace_DC 
				 , [PersonId],[DimDispMethodId],[DimOtherDispMethodId],[DispYear],[DispMonth],[DispDay],[PermitStatus],[DimDispPlaceId]	
				 , DispMethod,OtherDispMethod,DISP_DATE,DispPlace,CREM_CEM_UNLISTED,DOD_4_FD,CEM_NAME
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathDisposition_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , DispMethod_DC ,OtherDispMethod_DC ,DispPlace_DC 
				, [PersonId],[DimDispMethodId],[DimOtherDispMethodId],[DispYear],[DispMonth],[DispDay],[PermitStatus],[DimDispPlaceId]
				, DispMethod,OtherDispMethod,DISP_DATE,DispPlace,CREM_CEM_UNLISTED,DOD_4_FD,CEM_NAME
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathDisposition_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathDisposition_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimDispMethodId*/

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
				,'DeathDisposition' AS Entity
				,'DeathDispositionId' AS EntityColumnName
				,PA.DeathDispositionId AS EntityId
				,'DimDispMethodId' AS ConvertedColumn
				,MT.DispMethod AS OriginalValue
				,MT.DispMethod_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathDisposition]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.DispMethod_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimOtherDispMethodId*/

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
				,'DeathDisposition' AS Entity
				,'DeathDispositionId' AS EntityColumnName
				,PA.DeathDispositionId AS EntityId
				,'DimOtherDispMethodId' AS ConvertedColumn
				,MT.OtherDispMethod AS OriginalValue
				,MT.OtherDispMethod_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathDisposition]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.OtherDispMethod_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR DimDispPlaceId*/

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
				,'DeathDisposition' AS Entity
				,'DeathDispositionId' AS EntityColumnName
				,PA.DeathDispositionId AS EntityId
				,'DimDispPlaceId' AS ConvertedColumn
				,MT.DispPlace AS OriginalValue
				,MT.DispPlace_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathDisposition]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.DispPlace_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathDisposition_Log_Flag=1
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

	


