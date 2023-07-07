

IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('[RVRS].[Load_VIP_DeathFuneralDirectorPr]') AND [type]='P')
	DROP PROCEDURE [RVRS].[Load_VIP_DeathFuneralDirectorPr]
GO 

CREATE PROCEDURE [RVRS].[Load_VIP_DeathFuneralDirectorPr]

AS
 
 
/*
NAME	:[RVRS].[Load_VIP_DeathFuneralDirectorPr]
AUTHOR	:Sailendra Singh
CREATED	:Jul  6 2023  
PURPOSE	:TO LOAD DATA INTO FACT DeathFuneralDirector TABLE 

REVISION HISTORY
----------------------------------------------------------------------------------------------------------------------------------------------
DATE		         NAME						DESCRIPTION
Jul  6 2023 		Sailendra Singh						RVRS 174 : LOAD DECEDENT DeathFuneralDirector DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathOriginal] WHERE Entity = 'DeathFuneralDirector'
TRUNCATE TABLE [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]
DROP TABLE [RVRS].[DeathFuneralDirector_Log]
DELETE FROM [RVRS].[Execution] WHERE Entity = 'DeathFuneralDirector'

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC [RVRS].[Load_VIP_DeathFuneralDirectorPr]
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


IF OBJECT_ID('[RVRS].[DeathFuneralDirector_Log]') IS NULL 
	CREATE TABLE [RVRS].[DeathFuneralDirector_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64), FirstName_DC VARCHAR(128),MiddleName_DC VARCHAR(128),LastName_DC VARCHAR(128),LicenseNumber_DC VARCHAR(128),Suffix_DC VARCHAR(128),LastName_Suffix_DC VARCHAR(128), [PersonId] BIGINT,[FirstName] VARCHAR(128),[MiddleName] VARCHAR(128),[LastName] VARCHAR(128),[DimSuffixId] INT,[LicenseNumber] VARCHAR(32), LastName_Suffix VARCHAR(128),Suffix VARCHAR(128),SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),DeathFuneralDirector_Log_Flag BIT ,LoadNote VARCHAR(MAX))

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
		SELECT 'DeathFuneralDirector' AS Entity
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

	
SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM [RVRS].[Execution] WITH(NOLOCK) WHERE Entity='DeathFuneralDirector' AND ExecutionStatus='Completed')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = '01/01/1900'
PRINT '2'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			

		        SELECT    D.DEATH_REC_ID AS SrId
					  ,P.PersonId ,FDIR_FRST_NME FirstName,FDIR_MIDD_NME MiddleName,FDIR_LST_NME LastName,FDIR_LST_NME LastName_Suffix,COALESCE(FDIR_SUFFIX,'NULL') Suffix,FDIR_LIC_NUM LicenseNumber
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
			
	        ,CASE WHEN LEFT(FirstName,1) LIKE '[^a-zA-Z]' AND FirstName NOT LIKE '-%' THEN 'FirstName|Error:FirstName does not start with Alphabet' ELSE '' END AS LoadNote_1
	        ,CASE WHEN LEFT (Replace (MiddleName,'-',''),1) LIKE '[^a-zA-Z]' AND MiddleName NOT IN ('.') THEN 'MiddleName|Error:MiddleName does not start with Alphabet' ELSE '' END AS LoadNote_2
	        ,CASE WHEN LEFT(LastName,1) LIKE '[^a-zA-Z]' and LastName NOT LIKE '-%' THEN 'LastName|Error:LastName does not start with Alphabet' ELSE '' END AS LoadNote_3
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		
PRINT '7'  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
6 - Add/Update Flag on #Tmp_HoldData_Final
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
 
	ALTER TABLE #Tmp_HoldData_Final ADD  FirstName_DC VARCHAR(128),MiddleName_DC VARCHAR(128),LastName_DC VARCHAR(128),LicenseNumber_DC VARCHAR(128),Suffix_DC VARCHAR(128),LastName_Suffix_DC VARCHAR(128), FirstName_Flag BIT NOT NULL DEFAULT 0 ,MiddleName_Flag BIT NOT NULL DEFAULT 0 ,LastName_Flag BIT NOT NULL DEFAULT 0 ,LicenseNumber_Flag BIT NOT NULL DEFAULT 0 ,Suffix_Flag BIT NOT NULL DEFAULT 0 ,LastName_Suffix_Flag BIT NOT NULL DEFAULT 0 ,DeathFuneralDirector_Log_Flag BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote =  IIF( LoadNote_1 <> '',  '||' + LoadNote_1, '') +  IIF( LoadNote_2 <> '',  '||' + LoadNote_2, '') +  IIF( LoadNote_3 <> '',  '||' + LoadNote_3, '')
	
	UPDATE #Tmp_HoldData_Final SET DeathFuneralDirector_Log_Flag = 0

	UPDATE #Tmp_HoldData_Final SET DeathFuneralDirector_Log_Flag= 1
	WHERE LoadNote LIKE '%|Error:%'

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
7 - Data conversion  
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE FirstName WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathFuneralDirector_FirstName TABLE*/		
			
  			
			UPDATE MT
				SET 
				FirstName_DC= DC.Mapping_Current
				,MT.FirstName_Flag=1
				,MT.LoadNote='FirstName|Warning:FirstName got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.FirstName
			WHERE  DC.TableName='DeathFuneralDirector_FirstName'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '8' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE MiddleName WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathFuneralDirector_MiddleName TABLE*/		
			
  			
			UPDATE MT
				SET 
				MiddleName_DC= DC.Mapping_Current
				,MT.MiddleName_Flag=1
				,MT.LoadNote='MiddleName|Warning:MiddleName got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.MiddleName
			WHERE  DC.TableName='DeathFuneralDirector_MiddleName'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '9' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE LastName WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathFuneralDirector_LastName TABLE*/		
			
  			
			UPDATE MT
				SET 
				LastName_DC= DC.Mapping_Current
				,MT.LastName_Flag=1
				,MT.LoadNote='LastName|Warning:LastName got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.LastName
			WHERE  DC.TableName='DeathFuneralDirector_LastName'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '10' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE LicenseNumber WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DeathFuneralDirector_LicenseNumber TABLE*/		
			
  			
			UPDATE MT
				SET 
				LicenseNumber_DC= DC.Mapping_Current
				,MT.LicenseNumber_Flag=1
				,MT.LoadNote='LicenseNumber|Warning:LicenseNumber got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.LicenseNumber
			WHERE  DC.TableName='DeathFuneralDirector_LicenseNumber'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '11' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*THIS CODE IS TO GET MATCH FROM DimSuffix TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE*/
			
			ALTER TABLE #Tmp_HoldData_Final ADD DimSuffixId INT		

			UPDATE MT
			SET MT.DimSuffixId =DS.DimSuffixId  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimSuffix] DS WITH(NOLOCK) ON DS.SuffixDesc=MT.Suffix

			SET @RecordCountDebug=@@ROWCOUNT 

			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimSuffixId=DC.Mapping_Current_ID,
				Suffix_DC= DC.Mapping_Current
				,MT.Suffix_Flag=1
				,MT.LoadNote='Suffix|Warning:DimSuffixId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.Suffix
			WHERE  DC.TableName='DimSuffix'
				AND MT.DimSuffixId IS NULL
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '12' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					

	       /*UPDATING THE DeathFuneralDirector_Log_Flag FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN [RVRS].[Data_Conversion] TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET DeathFuneralDirector_Log_Flag=1
					   , LoadNote = 'Suffix|Pending Review:Not a valid Suffix' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END 
			WHERE DimSuffixId IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			
/*THIS CODE IS TO GET MATCH FROM [RVRS].[Data_Conversion] TABLE AND UPDATE THE DimSuffixId WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN DimSuffix_LastName TABLE*/		
			
  			
			UPDATE MT
				SET  MT.DimSuffixId=DC.Mapping_Current_ID,
				LastName_Suffix_DC= DC.Mapping_Current
				,MT.LastName_Suffix_Flag=1
				,MT.LoadNote='LastName_Suffix|Warning:DimSuffixId got value from data conversion' + CASE WHEN LoadNote !='' THEN '||' + LoadNote ELSE '' END  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS].[Data_Conversion] DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.LastName_Suffix
			WHERE  DC.TableName='DimSuffix_LastName'
				
			

			SET @RecordCountDebug=@@ROWCOUNT 
            PRINT '13' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					
/*
----------------------------------------------------------------------------------------------------------------------------------------------
9 - Parent Validations   
----------------------------------------------------------------------------------------------------------------------------------------------
*/
	
--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET DeathFuneralDirector_Log_Flag=1
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
					  AND DeathFuneralDirector_Log_Flag=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    
                PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET DeathFuneralDirector_Log_Flag = 1
                              ,LoadNote=CASE WHEN LoadNote!='' 
                                        THEN 'Person|ParentMissing:Not Processed' + ' || ' +  LoadNote  ELSE 'Person|ParentMissing:Not Processed' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM RVRS.Person_Log)
                                 AND DeathFuneralDirector_Log_Flag = 0

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

			INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]
			(
				 [PersonId],[FirstName],[MiddleName],[LastName],[DimSuffixId],[LicenseNumber]
				,CreatedDate
				,LoadNote
			)
			SELECT 
			     [PersonId], ISNULL([FirstName_DC],[FirstName]), ISNULL([MiddleName_DC],[MiddleName]), ISNULL([LastName_DC],[LastName]),[DimSuffixId], ISNULL([LicenseNumber_DC],[LicenseNumber])
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathFuneralDirector_Log_Flag=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		
PRINT ' Number of Record = ' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
11 - LOAD to Log    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
INSERT INTO [RVRS].[DeathFuneralDirector_Log]
			(
				 SrId, FirstName_DC ,MiddleName_DC ,LastName_DC ,LicenseNumber_DC ,Suffix_DC ,LastName_Suffix_DC 
				 , [PersonId],[FirstName],[MiddleName],[LastName],[DimSuffixId],[LicenseNumber]	
				 , LastName_Suffix,Suffix
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathFuneralDirector_Log_Flag
				,LoadNote
			)
			SELECT 
			    SrId , FirstName_DC ,MiddleName_DC ,LastName_DC ,LicenseNumber_DC ,Suffix_DC ,LastName_Suffix_DC 
				, [PersonId],[FirstName],[MiddleName],[LastName],[DimSuffixId],[LicenseNumber]
				, LastName_Suffix,Suffix
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,DeathFuneralDirector_Log_Flag
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE DeathFuneralDirector_Log_Flag=1

			SET @TotalErrorRecord = @@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
12 - LOAD to DeathOriginal    
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR FirstName*/

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
				,'DeathFuneralDirector' AS Entity
				,'DeathFuneralDirectorId' AS EntityColumnName
				,PA.DeathFuneralDirectorId AS EntityId
				,'FirstName' AS ConvertedColumn
				,MT.FirstName AS OriginalValue
				,MT.FirstName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.FirstName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR MiddleName*/

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
				,'DeathFuneralDirector' AS Entity
				,'DeathFuneralDirectorId' AS EntityColumnName
				,PA.DeathFuneralDirectorId AS EntityId
				,'MiddleName' AS ConvertedColumn
				,MT.MiddleName AS OriginalValue
				,MT.MiddleName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.MiddleName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR LastName*/

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
				,'DeathFuneralDirector' AS Entity
				,'DeathFuneralDirectorId' AS EntityColumnName
				,PA.DeathFuneralDirectorId AS EntityId
				,'LastName' AS ConvertedColumn
				,MT.LastName AS OriginalValue
				,MT.LastName_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.LastName_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR LicenseNumber*/

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
				,'DeathFuneralDirector' AS Entity
				,'DeathFuneralDirectorId' AS EntityColumnName
				,PA.DeathFuneralDirectorId AS EntityId
				,'LicenseNumber' AS ConvertedColumn
				,MT.LicenseNumber AS OriginalValue
				,MT.LicenseNumber_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.LicenseNumber_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
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
				,'DeathFuneralDirector' AS Entity
				,'DeathFuneralDirectorId' AS EntityColumnName
				,PA.DeathFuneralDirectorId AS EntityId
				,'DimSuffixId' AS ConvertedColumn
				,MT.Suffix AS OriginalValue
				,MT.Suffix_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.Suffix_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
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
				,'DeathFuneralDirector' AS Entity
				,'DeathFuneralDirectorId' AS EntityColumnName
				,PA.DeathFuneralDirectorId AS EntityId
				,'DimSuffixId' AS ConvertedColumn
				,MT.LastName_Suffix AS OriginalValue
				,MT.LastName_Suffix_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DeathFuneralDirector]  PA ON PA.PersonId=MT.PersonId 	
			WHERE MT.LastName_Suffix_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			
PRINT ' Number of Record = ' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	
/*
----------------------------------------------------------------------------------------------------------------------------------------------
13 - Update Execution  Status  
----------------------------------------------------------------------------------------------------------------------------------------------
*/

	
   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE DeathFuneralDirector_Log_Flag=1
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

	


