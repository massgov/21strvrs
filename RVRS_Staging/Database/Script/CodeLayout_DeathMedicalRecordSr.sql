/*
  Autor : Sailendra Singh
  Date : 10/13/2022
  Description: This script will be use to generate code layout 
  error type = 'ERROR', 'PENDING FOR REViEW'
  Updated : BY BEZAWIT at 10-17-2022:1:50 (Note: Switched to production version)
  Updated : By Sailendra aT 10-17-2022 2:44 PM (NOTE: Changed Date Entered and Date Discharged to Varchar from Datetime)
*/

SET NOCOUNT ON
USE RVRS_STAGING

DECLARE @TargetTable VARCHAR(128) = 'DeathMedicalRecord',  -- replace this 
        @StandardFilter VARCHAR(1024)= '
		              CAST(VRV_DATE_CHANGED AS DATE) > @LastLoadedDate
					  AND CAST(VRV_DATE_CHANGED AS DATE) != CAST(@CurentTime AS DATE)				  
					  AND D.VRV_RECORD_TYPE_ID = ''040''
					  AND D.VRV_REGISTERED_FLAG = 1 
					  AND D.Fl_CURRENT = 1 
					  AND D.FL_VOIDED  = 0 
					  ',
	@TestFilter VARCHAR (MAX) = ''    

	  SET @StandardFilter = @StandardFilter + '
	       ' + @TestFilter 
DECLARE        
		@TypeColumn VARCHAR(128) = '', --Order -- replace this as needed otherwise leave it blank  
        @currentDate VARCHAR(12) = convert (VARCHAR(16),getdate()), 
        @jiraID VARCHAR(16) = '170', @author VARCHAR(128) = 'Sailendra Singh', -- replace author name and jira #
        @printflag bit = 1 , 
		@seq INT = 0 ,
	    @SectionBreak VARCHAR(MAX) = '----------------------------------------------------------------------------------------------------------------------------------------------',
	    @print VARCHAR(8) = 'PRINT ', 
	    @UnionCount INT, 	    
	    @recordNumberPrint VARCHAR(128) = ' Number of Record = ',
		@cfc int,@mfc int,
		@top VARCHAR(128) =  ' ',  -- For PROD leave this blank 
		@stagingdb VARChar(128) = '' , --For PROD leave this blank else keep [RVRS_Staging].
        @LoadNotes VARCHAR(MAX) = ' + CASE WHEN LoadNote !='''' THEN ''||'' + LoadNote ELSE '''' END '
  DECLARE     @Workdb VARCHAR(128) = '',  -- For PROD leave this blank or set to @stagingdb else keep [RVRS_testdb].
		@rc INT = 0,
	    @TargetCreate VARCHAR(MAX),@TargetColumns VARCHAR(MAX), @TargetColumnsMod VARCHAR(MAX),@TargetCreateReplaceDatetime VARCHAR(MAX),
        @SourceCreate VARCHAR(MAX), @SourceColumns VARCHAR(MAX) , 
	    @DcFlagCreate VARCHAR(MAX), @FlagColumns VARCHAR(MAX), 
		@DcCreate VARCHAR(MAX), @DcColumns VARCHAR(MAX),
		@DimCreate VARCHAR(MAX), @DimColumns VARCHAR(MAX),
		--@MoveCreate VARCHAR(MAX), @MoveColumns VARCHAR(MAX),
		@testflag bit = 0 -- set this to 0 for production 

    DECLARE	@targetloc varchar(128) ='[RVRS_PROD].[RVRS_ODS].' --'[RVRS_PROD].[RVRS_ODS].' For PROD replace this by [RVRS_PROD].[RVRS_ODS] or else keep @workdb. 
	DECLARE  @AddFilterOriginal VARCHAR(512) = ''       
   IF @TypeColumn != ''
       SET   @AddFilterOriginal  = ' AND PA.'+@TypeColumn+'=MT.'+@TypeColumn -- replace this as needed otherwise leave it blank 

	DECLARE
		@Target VARCHAR(128) = @targetloc+'[RVRS].[' + @TargetTable + ']',
        @TargetOriginal VARCHAR(128)=  @targetloc+'[RVRS].[DeathOriginal]',
		@dcTable VARCHAR(128) = @stagingdb+'[RVRS].[Data_Conversion]',
		@TableFlag VARCHAR(128) =  @TargetTable + '_Log_Flag',
		@proc VARCHAR(128) = '[RVRS].[Load_VIP_' + @TargetTable+'Pr]'

 IF OBJECT_ID('tempdb..#sourcecolumn') IS NOT NULL 
    drop table #sourcecolumn
CREATE TABLE #sourcecolumn (id INT identity(1,1), srccolumn VARCHAR(MAX), columngroup int,filtercondition Varchar(MAX),filterconditionOpr VARCHAR(5), alias VARCHAR(128), datatype VARCHAR(128),typeid int, defaultValue VARCHAR(128))

insert into #sourcecolumn (srccolumn, columngroup,filtercondition,filterconditionOpr,alias, datatype, typeid, defaultValue) values   -- will be automated using mapping doc 

('MED_REC_NUM', 1,'','','RecordNumber','VARCHAR(128)', NULL,NULL),
('ME_CASE_YEAR',1,'','','CaseYear', 'INT',NULL, NULL),
('ME_CASE_NUM',1,'','','CaseNumber', 'VARCHAR(128)',NULL, NULL),
('ME_GNAME',1,'','','FirstName', 'VARCHAR(128)', NULL, NULL),
('GNAME',1,'','','FirstNameTab1', 'VARCHAR(128)', NULL, NULL),
('ME_MNAME',1,'','','MiddleName', 'VARCHAR(128)', NULL,NULL ),
('MNAME',1,'','','MiddleNameTab1', 'VARCHAR(128)', NULL,NULL ),
('ME_LNAME',1,'','','LastName', 'VARCHAR(128)', NULL,NULL ),
('LNAME',1,'','','LastNameTab1', 'VARCHAR(128)', NULL,NULL ),
('ME_SUFF',1,'','','Suffix', 'VARCHAR(128)', NULL,'''NULL'''),
('SUFF',1,'','','SuffixTab1', 'VARCHAR(128)', NULL,'''NULL'''),
('ME_SEX',1,'','','Sex', 'VARCHAR(128)', NULL,'''NULL'''),
('SEX',1,'','','SexTab1', 'VARCHAR(128)', NULL,'''NULL'''),
('ME_DOB',1,'','','ME_DOB', 'VARCHAR(128)', NULL,NULL),
('DOB',1,'','','DobTab1', 'VARCHAR(128)', NULL,NULL),
('RIGHT(ME_DOB,4)',1,'','','BirthYear', 'VARCHAR(128)',NULL,NULL ),
('LEFT(ME_DOB,2)',1,'','','BirthMonth', 'VARCHAR(128)', NULL,NULL ),
('SUBSTRING(ME_DOB,4,2)',1,'','','BirthDay', 'VARCHAR(128)', NULL,NULL ),
('DOD',1,'','','ME_DOD', 'VARCHAR(128)', NULL,NULL),
('DOD_4_FD',1,'','','DodTab1', 'VARCHAR(128)', NULL,NULL),
('RIGHT(DOD,4)',1,'','','DeathYear', 'VARCHAR(128)', NULL,NULL ),
('LEFT(DOD,2)',1,'','','DeathMonth', 'VARCHAR(128)', NULL,NULL ),
('SUBSTRING(DOD,4,2)',1,'','','DeathDay', 'VARCHAR(128)', NULL,NULL ),
('TOD_ME',1,'','','ME_TOD', 'VARCHAR(128)', NULL,NULL),
('LEFT(TOD_ME,2)',1,'','','DeathHour', 'VARCHAR(128)', NULL,NULL ),
('RIGHT(TOD_ME,2)',1,'','','DeathMinute', 'VARCHAR(128)', NULL,NULL ),
('TOD_IN_ME',1,'','','TimeInd', 'VARCHAR(128)', NULL,'''NULL'''),
('PRO_DATE',1,'','','ProDateTab5A', 'VARCHAR(128)', NULL,NULL),
('PRO_DATE_ME',1,'','','ME_PRO_DATE', 'VARCHAR(128)', NULL,NULL),
('RIGHT(PRO_DATE_ME,4)',1,'','','PronouncedYear', 'VARCHAR(128)', NULL,NULL ),
('LEFT(PRO_DATE_ME,2)',1,'','','PronouncedMonth', 'VARCHAR(128)', NULL,NULL ),
('SUBSTRING(PRO_DATE_ME,4,2)',1,'','','PronouncedDay', 'VARCHAR(128)', NULL,NULL ),
('PRO_TIME_ME',1,'','','ME_PRO_TIME', 'VARCHAR(128)', NULL,NULL ),
('LEFT(PRO_TIME_ME,2)',1,'','','PronouncedHour', 'VARCHAR(128)', NULL,NULL ),
('RIGHT(PRO_TIME_ME,2)',1,'','','PronouncedMinute', 'VARCHAR(128)', NULL,NULL ),
('PRO_TIME_IND_M',1,'','','PronouncedTimeInd', 'VARCHAR(128)', NULL,'''NULL'''),
('ME_MNAME_NONE',1,'','','ME_MNAME_NONE', 'VARCHAR(128)', NULL,NULL),
('TOD',1,'','','TOD', 'VARCHAR(128)', NULL,NULL),
('PRO_TIME',1,'','','ProTimeTab5A', 'VARCHAR(128)', NULL,NULL)




IF OBJECT_ID('tempdb..#validation') IS NOT NULL 
    drop table #validation

CREATE TABLE #validation (id INT identity(1,1), columnname  VARCHAR(128), condition VARCHAR(MAX), errormessage VARCHAR(MAX),errortype VARCHAR(64) )  -- errortype = 'Error', 'Warning' , 'Pending', 'ParentMissing', 'ChildMissing'

INSERT INTO #validation (columnname , condition , errormessage,errortype) values 
						
						('FirstName,Person.FirstName','COALESCE(FirstName,'''')<>COALESCE(FirstNameTab1,'''')','FirstName Mismatch in Decedent and Autopsy page','Warning'),
						('FirstName','LEFT(FirstName,1) LIKE ''[^a-zA-Z]'' AND FirstName NOT LIKE ''-%''','FirstName does not start with Alphabet','Error'),
						('MiddleName,Person.MiddleNameTab1','COALESCE(MiddleName,'''')<>COALESCE(MiddleNameTab1,'''')','MiddleName Mismatch in Decedent and Autopsy','Warning'),
						('MiddleName','LEFT(MiddleName,1) LIKE ''[^a-zA-Z]'' and MiddleName NOT LIKE ''-%''','MiddleName does not start with Alphabet','Error'),
						('LastName,Person.LastNameTab1','COALESCE(LastName,'''')<>COALESCE(LastNameTab1,'''')','LastName Mismatch in Tab Decedent and Autopsy Mismatch','Warning'),
						('LastName','LEFT(LastName,1) LIKE ''[^a-zA-Z]'' and LastName NOT LIKE ''-%''','LastName does not start with Alphabet','Error'),
						('MiddleName,ME_MNAME_NONE','(ME_MNAME_NONE = ''Y'' AND MiddleName IS NOT NULL) OR (ME_MNAME_NONE = ''N'' AND MiddleName IS NULL)','Mismatch between MiddleName and NoMiddleName fields','Warning'),
						
						('Suffix,Person.Suffix','COALESCE(Suffix,'''')<>COALESCE(SuffixTab1,'''')','Suffix Mismatch in Decedent and Autopsy page ','Warning'),
						
						('Sex,Person.Sex','COALESCE(Sex,'''')<>COALESCE(SexTab1,'''')','Sex Mismatch in Decedent and Autopsy page','Warning'),

						('ME_DOB,DOB','COALESCE(ME_DOB,'''')<>COALESCE(DobTab1,'''')','Date of Birth Mismatch in Decedent and Autopsy page','Warning'),
						('ME_DOB','ISDATE(REPLACE(REPLACE (COALESCE(ME_DOB,''01/01/1900''),''/9999'', ''/1900''),''99/'',''01/''))=0','Not a valid Date of Birth',  'Error'),
						('ME_DOB,ME_DOD','TRY_CAST (ME_DOD AS DateTime)<TRY_CAST(ME_DOB AS DateTime)','Date of Birth is greater than Date of Death','Error'),
						('ME_DOB','TRY_CAST (ME_DOB AS DateTime)<''01/01/1885'' AND Try_Cast(ME_DOB AS DateTime)>GETDATE()','Date of Birth is not in valid range','Error'),
						('ME_DOB','ME_DOB NOT LIKE ''[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]''','Date of Birth is not in valid format','Error'),

						('CaseYear','CaseYear<2014 or CaseYear>YEAR(GETDATE())','Case Year is not in a valid range','Error'),

						('ME_DOD,DOD_4_FD','COALESCE(ME_DOD,'''')<>COALESCE(DODTab1,'''')','Date of Death Mismatch in Decedent and Autopsy page','Warning'),
						('ME_DOD','ISDATE(ME_DOD)=0','Not a valid Date of Death',  'Error'),
						('ME_DOD','ME_DOD<''01/01/2014'' AND ME_DOD>GETDATE()','Year of Death is not in valid range','Error'),
						('ME_DOD','ME_DOD IS NULL','No value for Death of Death','Error'),
						('ME_DOD','ME_DOD not like ''[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]''','Not a valid format for Date of Death','Error'),

						('ME_TOD,TOD','COALESCE(ME_TOD,'''')<>COALESCE(TOD,'''')','Time of Death Mismatch in Decedent and Autopsy page ','Warning'),
						('ME_TOD,TimeInd','((TimeInd =''M'' AND ISDATE(REPLACE(ME_TOD,''99'',''01'')) = 0) OR (TimeInd IN( ''A'', ''P'') 
							AND ISDATE(ME_TOD + REPLACE(REPLACE(TimeInd,''A'',''AM''),''P'',''PM'')) = 0))','Time of death not in a valid  range','Error'),
						('ME_TOD','ME_TOD NOT LIKE ''[0-9][0-9]:[0-9][0-9]''','Not a valid format for Time of Death','Error'),
						
						('ME_TOD,TimeInd','ME_TOD LIKE ''12:00'' AND TimeInd NOT IN (''N'',''D'')', 'Time of Death not in align with Time Indicator', 'Error'),

						('ME_PRO_DATE,PRO_DATE','COALESCE(ME_PRO_DATE,'''')<>COALESCE(ProDateTab5A,'''')','Pronounced Date of Death Mismatch in Pronouncement and Autopsy page','Warning'),
						('ME_PRO_DATE','ISDATE(REPLACE(REPLACE (COALESCE(ME_PRO_DATE,''01/01/1900''),''/9999'', ''/1900''),''99/'',''01/''))=0','Not a valid Pronounced Date of Death',  'Error'),
						('ME_PRO_DATE,ME_DOD','TRY_CAST (ME_PRO_DATE AS DateTime)<Try_Cast (ME_DOD AS DateTime)','Pronounced Date of Death is before Date of Death','Error'),
						('ME_PRO_DATE','TRY_CAST(ME_PRO_DATE AS DATE)<''01/01/2014'' AND TRY_CAST(ME_PRO_DATE AS DATE)>GETDATE()','Pronouncement date of Death is not in a valid range','Error'),
						('ME_PRO_DATE','ME_PRO_DATE not like ''[0-9][0-9]/[0-9][0-9]/[0-9][0-9][0-9][0-9]''','Not a valid format for Pronounced Date of Death','Error'),

						('ME_PRO_TIME,PRO_TIME','COALESCE(ME_PRO_TIME,'''')<>COALESCE(ProTimeTab5A,'''')','Pronounced Time of Death in Pronouncement and Certfier Mismatch','Warning'),
						('ME_PRO_TIME,PronouncedTimeInd','((PronouncedTimeInd =''M'' AND ISDATE(REPLACE(ME_PRO_TIME,''99'',''01'')) = 0) OR (PronouncedTimeInd IN( ''A'', ''P'') 
							AND ISDATE(ME_PRO_TIME + REPLACE(REPLACE(PronouncedTimeInd,''A'',''AM''),''P'',''PM'')) = 0))','Time of Pronouncement is not in a valid range','Error'),
						('ME_PRO_TIME','ME_PRO_TIME NOT LIKE ''[0-9][0-9]:[0-9][0-9]''','Not a valid format for Pronounced Time of Death','Error'),

						('ME_PRO_TIME,PronouncedTimeInd','ME_PRO_TIME LIKE ''12:00'' AND PronouncedTimeInd NOT IN (''N'',''D'')', 'Pronounced Time of Death not in align with Pronounced Time Indicator', 'Error')
						 
			            
SET @rc = @@Rowcount 

IF OBJECT_ID('tempdb..#dc') IS NOT NULL 
    drop table #dc
--CREATE TABLE #dc (id INT identity(1,1), SourceColumn VARCHAR(128), TableName VARCHAR(128),  ColumName VARCHAR(128),Flag Bit, ObjectType VARCHAR(8) default 'Dim', DataType VARCHAR(128), DC Bit)

--insert into  #dc  (SourceColumn,TableName,ColumName, ObjectType,DataType, DC) values
--  ('Suffix','DimSuffix', 'DimSuffixId', 'Dim', 'INT',1),
--  ('InformantRelation','DimInformantRelation', 'DimInformantRelationId', 'Dim', 'INT',0),
--  ('OtherInformantRelation','DimOtherInformantRelation', 'DimOtherInformantRelationId', 'Dim', 'INT',1),
--  ('FirstName','Informant_FirstName' ,'FirstName','Fact', 'VARCHAR(128)',1),  
--  ('LastName','Informant_LastName','LastName', 'Fact', 'VARCHAR(128)',1), 
--  ('MiddleName','Informant_MiddleName', 'MiddleName', 'Fact', 'VARCHAR(128)',1) 


--  SET @cfc =  @@Rowcount

CREATE TABLE #dc (id INT identity(1,1), SourceColumn VARCHAR(128), TableName VARCHAR(128),  ColumName VARCHAR(128),DimColumn VARCHAR(128),Flag Bit, ObjectType VARCHAR(8) default 'Dim', DataType VARCHAR(128), DC Bit, OtherFilter VARCHAR(MAX), DCType VARCHAR(16))

insert into  #dc  (SourceColumn,TableName,ColumName,DimColumn, ObjectType,DataType, DC, OtherFilter, DCType) values --DCType = OtherOnly, StandardOnly, Standard&Other
    --('Armed','DimYesNo', 'DimArmedId','Abbr', 'Dim', 'INT',0, NULL, NULL)
	('FirstName','DeathMedicalRecord_FirstName','FirstName' ,'','Fact', 'VARCHAR(128)',1, NULL, NULL),
	('MiddleName','DeathMedicalRecord_MiddleName','MiddleName' ,'','Fact', 'VARCHAR(128)',1, NULL, NULL),
	('LastName','DeathMedicalRecord_LastName','LastName' ,'','Fact', 'VARCHAR(128)',1, NULL, NULL),
	('RecordNumber','DeathMedicalRecord_RecordNumber','RecordNumber' ,'','Fact', 'VARCHAR(128)',1, NULL, NULL),
	('CaseNumber','DeathMedicalRecord_CaseNumber','CaseNumber' ,'','Fact', 'VARCHAR(128)',1, NULL, NULL),
	('Suffix','DimSuffix', 'DimSuffixId','SuffixDesc', 'Dim', 'INT',1, NULL, NULL),
	('Sex','DimSex', 'DimSexId','Abbr', 'Dim', 'INT',0, NULL, NULL),
	('TimeInd','DimTimeInd', 'DimTimeIndId','Abbr', 'Dim', 'INT',0, NULL, NULL),
	('PronouncedTimeInd','DimTimeInd', 'DimPronouncedTimeIndId','Abbr', 'Dim', 'INT',0, NULL, NULL)
SET @cfc =  @@Rowcount

--IF OBJECT_ID('tempdb..#move') IS NOT NULL 
--    drop table #move
--CREATE TABLE #move (id INT identity(1,1), SourceColumn VARCHAR(128), TargetColumn VARCHAR(128), DimValueColumn VARCHAR(128), TableName VARCHAR(128), FilterCondition VARCHAR(MAX),ObjectType VARCHAR(8) )

----insert into  #move  (SourceColumn,TableName,TargetColumn,DimValueColumn, FilterCondition, ObjectType ) values
----  ('OtherInformantRelation', 'DimInformantRelation','DimInformantRelationId','InformantRelationDesc', ' WHERE f.InformantRelation = ''OTHER''', 'Dim') 
----SET @mfc =  @@Rowcount

 SELECT  @SourceCreate = Coalesce (@SourceCreate + ',', ' ') +  alias + ' '  + datatype,
         @SourceColumns = Coalesce (@SourceColumns + ',', ' ') +  alias 
 FROM  #sourcecolumn s1 WHERE alias !=''
 AND NOT EXISTS (SELECT 1 FROM  [RVRS_PROD].[RVRS_ODS].[INFORMATION_SCHEMA].[COLUMNS] s2 WHERE TABLE_NAME = @TargetTable and COLUMN_NAME != @TargetTable + 'Id' AND s2.COLUMN_NAME = s1.alias)

 --print @SourceCreate
 --print @sourcecolumns
 --print '
  
 SELECT  @DcFlagCreate = Coalesce (@DcFlagCreate + ',', ' ') +  SourceColumn + '_Flag BIT NOT NULL DEFAULT 0 '  ,
         @FlagColumns = Coalesce (@FlagColumns + ',', ' ') +  SourceColumn + '_Flag ' , 
		 @DcCreate = Coalesce (@DcCreate + ',', ' ') +  SourceColumn + '_DC '  + iif( objecttype = 'dim',  'VARCHAR(128)', datatype),
         @DcColumns = Coalesce (@DcColumns + ',', ' ') + SourceColumn + '_DC ' 		
 FROM  #dc
 WHERE DC = 1
 
SELECT  @DimColumns =Coalesce (@DimColumns + ',', ' ') +  SourceColumn,
        @DimCreate =Coalesce (@DimCreate + ',', ' ') +  SourceColumn +   ' VARCHAR(128) '
FROM #dc WHERE objecttype = 'Dim'
 --print @DcFlagCreate
 --print @FlagColumns
 --print @DcCreate
--print @DcColumns
--print @DimCreate
--print @DimColumns
 
 --SELECT  @MoveCreate = Coalesce (@MoveCreate + ',', ' ') +  SourceColumn + '_Mv VARCHAR(128) '  ,
 --        @MoveColumns = Coalesce (@MoveColumns + ',', ' ') +  SourceColumn + '_Mv'  			
 --FROM  #move
 --WHERE ObjectType != 'Dim'
 ----print @MoveCreate
 ----print @MoveColumns
 ---- return 

 SELECT @TargetCreate =  Coalesce (@TargetCreate + ',', ' ') + '[' + COLUMN_NAME + ']' + ' '  +UPPER(DATA_TYPE)+ IIF (CHARACTER_MAXIMUM_LENGTH is null, '', '(' + IIF (CHARACTER_MAXIMUM_LENGTH = -1, 'MAX', Convert(VARCHAR,CHARACTER_MAXIMUM_LENGTH)) + ')'),
       @TargetColumns = Coalesce (@TargetColumns + ',', ' ') +  '[' + COLUMN_NAME + ']'         
 FROM [RVRS_PROD].[RVRS_ODS].[INFORMATION_SCHEMA].[COLUMNS] WHERE TABLE_NAME = @TargetTable and COLUMN_NAME != @TargetTable + 'Id' and  COLUMN_NAME NOT IN ('LoadNote', 'CreatedDate')

 --print @TargetCreate
 --print @TargetColumns

 set @TargetColumnsMod  = @TargetColumns
 SET @TargetCreateReplaceDatetime = Replace(Replace(@TargetCreate,'DATETIME','VARCHAR(16)'),'Decimal','VARCHAR(16)')

--------------------------------------Metadata ENDED-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------Creating code layout started-----------------------------------------------------------------------------------------------------------------

--------------------------------------Metadata ENDED-----------------------------------------------------------------------------------------------------------------------------
--------------------------------------Creating code layout started-----------------------------------------------------------------------------------------------------------------

IF  @workdb !='' PRINT ' USE ' +LEFT(@workdb, len(@workdb) - 1)

PRINT '

IF EXISTS(SELECT 1 FROM sys.Objects WHERE [OBJECT_ID]=OBJECT_ID('''+ @proc + ''') AND [type]=''P'')
	DROP PROCEDURE ' + @proc + '
GO 

CREATE PROCEDURE '+ @proc +'

AS
 
 ' 
PRINT 
'/*
NAME	:' + @proc  + '
AUTHOR	:' + @author  + '
CREATED	:'  +  @currentDate  +' 
PURPOSE	:TO LOAD DATA INTO FACT ' +  @TargetTable +  ' TABLE 

REVISION HISTORY'
print @SectionBreak 
print 
'DATE		         NAME						DESCRIPTION
' + @currentDate + '		'  + @author	 +'						RVRS ' + @jiraID  + ' : LOAD DECEDENT ' + @TargetTable +  ' DATA FROM STAGING TO ODS

*****************************************************************************************
 For testing diff senarios you start using fresh data
*****************************************************************************************
DELETE FROM '+@targetloc+'[RVRS].[DeathOriginal] WHERE Entity = '''+ @TargetTable+'''
TRUNCATE TABLE '+@targetloc+'[RVRS].[' +@TargetTable +']
DROP TABLE '+@Workdb+'[RVRS].[' +@TargetTable +'_Log]
DELETE FROM '+@Workdb+'[RVRS].[Execution] WHERE Entity = '''+ @TargetTable+'''

*****************************************************************************************
 After execute the procedure you can run procedure 
*****************************************************************************************
EXEC ' + @proc + '
*/

' 


print 

	' 
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
		,@ExecutionStatus VARCHAR(100)=''Completed''
		,@Note VARCHAR(500)
		,@RecordCountDebug INT  
		,@TotalParentMissingRecords INT = 0
		
	'

print '/*'
print @SectionBreak 
print '1 - Create temp table '
print @SectionBreak
print '*/

'
PRINT '
IF OBJECT_ID(''tempdb..#Tmp_HoldData'') IS NOT NULL 
			DROP TABLE #Tmp_HoldData
IF OBJECT_ID(''tempdb..#Tmp_HoldData_Final'') IS NOT NULL 
			DROP TABLE #Tmp_HoldData_Final

'

print '/*'
print @SectionBreak 
print '2 - Create log table '
print @SectionBreak
print '*/

'

PRINT 
'
IF OBJECT_ID(''' + @Workdb+ '[RVRS].['+ @TargetTable +'_Log]'') IS NULL 
	CREATE TABLE ' + @Workdb+ '[RVRS].['+ @TargetTable +'_Log] (Id BIGINT IDENTITY (1,1), SrId VARCHAR(64),' +IIF(@DcCreate IS NOT NULL,@DcCreate +',','')
					 + @TargetCreateReplaceDatetime + ','  + @SourceCreate + ',' + 
	                           'SrCreatedDate DATETIME,SrUpdatedDate DATETIME,CreatedDate DATETIME NOT NULL DEFAULT GetDate(),' + @TableFlag + ' BIT ,LoadNote VARCHAR(MAX))

'


PRINT 
'BEGIN TRY

	'
	print '/*'
	print @SectionBreak 
	print '2 - Set Execution intial status'
	print @SectionBreak
	print '*/

	'


	if @printflag = 1 
		BEGIN 
			SET @seq = @seq + 1
			print @print + '''' + convert(VARCHAR, @seq)   + '''  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			'
		END 


	PRINT 

		'INSERT INTO ' + @Workdb  + '[RVRS].[Execution] 
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
		SELECT ''' + @TargetTable + ''' AS Entity
			,''In Progress'' AS ExecutionStatus
			,NULL AS LastLoadDate			
			,@CurentTime AS StartTime
			,NULL AS EndTime
			,0 AS TotalProcessedRecords
			,0 AS TotalLoadedRecord
			,0 AS TotalErrorRecord
			,0 AS TotalPendingReviewRecord
			,0 AS TotalWarningRecord

		SET @ExecutionId = (SELECT IDENT_CURRENT(''RVRS.Execution''))
	
		'
			

	print '/*'
	print @SectionBreak 
	print '3 - Collect data from Staging'
	print @SectionBreak
	print '*/

	'
    PRINT 	'SET @LastLoadedDate=(SELECT MAX(LastLoadDate) FROM ' + @Workdb  + '[RVRS].[Execution] WITH(NOLOCK) WHERE Entity=''' + @TargetTable+ ''' AND ExecutionStatus=''Completed'')
	        IF @LastLoadedDate IS NULL SET @LastLoadedDate = ''01/01/1900'''

	if @printflag = 1 
		BEGIN 
			SET @seq = @seq + 1
			print @print + '''' + convert(VARCHAR, @seq)   + '''  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
			'
		END 
		
	declare @g INT = 1 ,@j INT = 1 ,  @columns VARCHAR(MAX) = ''  , @filter VARCHAR(MAX) = '', @column VARCHAR(MAX) = '', @Fields VARCHAR(MAX) = ''
	, @filtercondition VARCHAR(MAX) , @alias VARCHAR(128) = '', @Aliases VARCHAR(MAX) = '', @typeid int, @filterconditionOpr Varchar(8), @filterconditionOprTrim varchar(5) = '', @defaultValue VARCHAR(128),@datatype1 varchar(24)
	select  @unioncount = MAX (columngroup) from #sourcecolumn
	WHILE (@g <= @unioncount )
	BEGIN
		SET @Fields  = ''
		SET @filter  = ''		
	    WHILE (1=1)
			BEGIN 
		       SELECT @column = srccolumn,  @filtercondition=  filtercondition, @alias = alias , @typeid= typeid, @filterconditionOpr = filterconditionOpr, @defaultValue =defaultValue, @datatype1 = datatype from #sourcecolumn where id = @j and columngroup= @g
			   if (@@ROWCOUNT = 0) break
			   SET @Fields =  @Fields +',' +  IIF (@defaultValue is null,isnull(@column , ''), 'COALESCE(' + isnull(@column,'') + ',' + @defaultValue+ ')')  + isnull(' '+@alias ,'')
			   if isnull(@alias, '') != '' SET @Aliases = @Aliases +',' +  @alias 
			   if (@filtercondition  !=  '') SET @filter =  @filter +' ' + @filterconditionOpr + ' '  +  isnull(@column , '') + ' ' + @filtercondition
			   if @filterconditionOprTrim = '' and len(@filterconditionOpr) > 0   set @filterconditionOprTrim = @filterconditionOpr 
			   SET @j = @j + 1 			   
		    END 
			  IF @typeid is not null  SET @Fields  = @Fields + ',' + CONVERT (varchar, @typeid ) + ' ' + @TypeColumn 

			 if (@filtercondition  !=  '') SET @filter = 'AND (' + RIGHT (@filter, LEN(@filter) - (Len(@filterconditionOprTrim) + 2)) + ')'
			
		if (@g != 1) 
		   PRINT '    
		          UNION ALL    
				 '
		PRINT 	'
		        SELECT '+ @top + ' D.DEATH_REC_ID AS SrId
					  ,P.PersonId ' +
					  @Fields + '
					  ,@CurentTime AS CreatedDate 
					  ,VRV_REC_DATE_CREATED AS SrCreatedDate
					  ,VRV_DATE_CHANGED AS SrUpdatedDate'
		if (@g = 1) PRINT'
		        INTO #Tmp_HoldData'
		PRINT   '
		        FROM '+@stagingdb+'RVRS.VIP_VRV_Death_Tbl D WITH(NOLOCK)
				LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.SrId=D.DEATH_REC_ID
				WHERE ' +@StandardFilter  
		if( @unioncount > 1 ) PRINT '                      '  + @filter  

		

			SET @g = @g + 1
	END 
	print ' 
	
	       SET @TotalProcessedRecords = @@ROWCOUNT'
	if @printflag = 1 
		BEGIN 
			SET @seq = @seq + 1
			print '
		   ' + 	@print + ' @TotalProcessedRecords
			'
		END 

		if @testflag = 1
			print ' select * from #Tmp_HoldData ' 

	if @printflag = 1 
		BEGIN 
			SET @seq = @seq + 1
			print @print + '''' + convert(VARCHAR, @seq)   + '''  + CONVERT (VARCHAR(50),GETDATE(),109)
			'
		END 


	 PRINT '
	 IF @TotalProcessedRecords=0
			BEGIN '
	
			if @printflag = 1 
				BEGIN 
					SET @seq = @seq + 1
							print '                ' + @print + '''' + convert(VARCHAR, @seq)   + '''  + CONVERT (VARCHAR(50),GETDATE(),109)	
						'
				END 
		
		PRINT		'				UPDATE ' + @Workdb  + '[RVRS].[Execution]
						SET ExecutionStatus=''Completed''
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
			
				'
			

	print '/*'
	print @SectionBreak 
	print '4 - Check if there is parent  '
	print @SectionBreak
	print '*/

	'
	PRINT 'IF (SElECT count(1) from #Tmp_HoldData where PersonId is not null ) = 0
			BEGIN
					UPDATE ' + @Workdb  + '[RVRS].[Execution]
					SET ExecutionStatus=@ExecutionStatus
						,LastLoadDate=@LastLoadedDate					
						,EndTime=@CurentTime
						,TotalProcessedRecords=@TotalProcessedRecords
						,TotalLoadedRecord=@TotalLoadedRecord
						,TotalErrorRecord=@TotalErrorRecord
						,TotalPendingReviewRecord=@TotalPendingReviewRecord
						,TotalWarningRecord=@TotalWarningRecord
					WHERE ExecutionId=@ExecutionId
					SET @Err_Message =''We do not have data for ''+ CONVERT(VARCHAR(50),@MAXDateinData,106) +''in Person Table''
					RAISERROR (@Err_Message,10,1)			
			END
		
			' 

	PRINT 'SET @MAXDateinData = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)'
	PRINT  @print + ' @MAXDateinData' 
	PRINT 'SET @LastLoadedDate = @MAXDateinData

	'

	print '/*'
	print @SectionBreak 
	print '5 - Validation checking  '
	print @SectionBreak
	print '*/

	'
		if @printflag = 1 
				BEGIN 
					SET @seq = @seq + 1
					print @print + '''' + convert(VARCHAR, @seq)   + '''  + CONVERT (VARCHAR(50),GETDATE(),109)	
					'
				END 

    DECLARE @ri INT = 1, @validationrules VARCHAR(MAX) = '', @columnname1 VARCHAR(MAX), @condition VARCHAR(MAX), @errormessage VARCHAR(MAX), @errortype VARCHAR(64), @VloadNote VARCHAR(MAX) = ''

	WHILE (@ri <= @rc)
	  BEGIN
	   SELECT @columnname1 = columnname,@condition = condition,  @errormessage = errormessage,@errortype =errortype  FROM #Validation WHERE id = @ri
	   SET @validationrules = @validationrules + '
	        ,CASE WHEN ' + @condition + ' THEN ''' +@columnname1+ '|' + @errortype + ':' + @errormessage + ''' ELSE ' + ''''' END AS LoadNote_' + convert(VARCHAR, @ri) 
            SET @VloadNote =@VloadNote +  ' IIF( LoadNote_' + convert(VARCHAR, @ri) + ' <> '''',  ''||'' + LoadNote_' + convert(VARCHAR, @ri) + ', '''') + ' 		
			
	   SET @ri = @ri + 1
	  END 

    SET @VloadNote = LEFT(@VloadNote, LEN(@VloadNote)-2)
	
	PRINT 
	'   
		SELECT *
			' +@validationrules + '
					
		INTO #Tmp_HoldData_Final				
		FROM #Tmp_HoldData HD

		'
		if @printflag = 1 
				BEGIN 
					SET @seq = @seq + 1
					print @print + '''' + convert(VARCHAR, @seq)   + '''  + CONVERT (VARCHAR(50),GETDATE(),109)
	
	
					'
				END 


	
	print '/*'
	print @SectionBreak 
	print '6 - Add/Update Flag on #Tmp_HoldData_Final'
	print @SectionBreak
	print '*/
	'

    PRINT ' 
	ALTER TABLE #Tmp_HoldData_Final ADD ' + IIF (@DcCreate IS NOT NULL , @DcCreate + ',', '') + IIF (@DcFlagCreate IS NOT NULL, @DcFlagCreate +',','')+  @TableFlag +' BIT NOT NULL DEFAULT 0,LoadNote VARCHAR(MAX) 

	UPDATE #Tmp_HoldData_Final SET LoadNote = '+ @VloadNote +'
	
	UPDATE #Tmp_HoldData_Final SET ' + @TableFlag + ' = 0

	UPDATE #Tmp_HoldData_Final SET ' + @TableFlag+ '= 1
	WHERE LoadNote LIKE ''%|Error:%''

	'

	print '/*'
	print @SectionBreak 
	print '7 - Data conversion  '
	print @SectionBreak
	print '*/
	'

	--DECLARE @cid INT = 1 , @SourceColumn VARCHAR(128), @ColumnName VARCHAR(128), @TableName VARCHAR(128), @ObjectType VARCHAR(128), @DataType VARCHAR(128), @DC BIT
	--WHILE (@cid <=  @cfc) 
	--BEGIN 
	DECLARE @cid INT = 1 , @SourceColumn VARCHAR(128), @ColumnName VARCHAR(128), @TableName VARCHAR(128), @ObjectType VARCHAR(128), @DataType VARCHAR(128), @DC BIT, @OtherFilter VARCHAR(MAX) = '' , @DCType VARCHAR(16) ,@DimColumn VARCHAR(128)
	WHILE (@cid <=  @cfc) 
	BEGIN 
			SELECT @SourceColumn = SourceColumn, @TableName = TableName, @ColumnName = ColumName, @ObjectType = ObjectType, @DataType = DataType,@DC= DC,  @OtherFilter = OtherFilter, @DCType = DCTYPE, @DimColumn=DimColumn FROM #dc WHERE Id = @cid


	    DECLARE @DimSelectSQL VARCHAR(MAX) 
		IF (@ObjectType = 'Dim')
			BEGIN 

			PRINT '/*THIS CODE IS TO GET MATCH FROM ' + @TableName +' TABLE AND UPDATE THE '+ @ColumnName+' WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD ' + @ColumnName + ' ' + @DataType  + '
		
			UPDATE MT
			SET MT.'+ @ColumnName+' =DS.'+ @TableName +'Id  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[' + @TableName +'] DS WITH(NOLOCK) ON DS.' +trim(@DimColumn) + '=MT.' +@SourceColumn +'

			SET @RecordCountDebug=@@ROWCOUNT 

			' + @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10))
			
			'
			if @testflag = 1
			SET @DimSelectSQL = ISNULL(@DimSelectSQL, '') + ' SELECT * FROM [RVRS_PROD].[RVRS_ODS].[RVRS].[' + @TableName +'] DS WITH(NOLOCK) 
			' 
			END 
		ELSE 
		SET @TargetColumnsMod = REPLACE (@TargetColumnsMod ,'['+ @SourceColumn+']', ' ISNULL(['+@SourceColumn+'_DC],['+@SourceColumn+'])')
			
      IF @DC = 1
		BEGIN 
		PRINT 
			'/*THIS CODE IS TO GET MATCH FROM ' + @dcTable + ' TABLE AND UPDATE THE ' +  @ColumnName  + ' WITH CORRECT VALUE,
						FOR THE RECORDS WHICH COULD NOT GET A MATCH IN ' + @TableName + ' TABLE*/		
			'
		IF @DCType  LIKE '%Standard%' OR @DCType IS NULL
			PRINT  '  			
			UPDATE MT
				SET ' + IIF (@ObjectType = 'Dim' , ' MT.' + @ColumnName +'=DC.Mapping_Current_ID,', '') + '
				'+@SourceColumn+'_DC= DC.Mapping_Current
				,MT.' + @SourceColumn +'_Flag=1
				,MT.LoadNote='''+  @SourceColumn  + '|Warning:'+@ColumnName+' got value from data conversion''' + @LoadNotes +' 
			FROM #Tmp_HoldData_Final MT
			JOIN ' + @dcTable + ' DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.' + @SourceColumn+ '
			WHERE  DC.TableName=''' + @TableName + '''
				' + IIF (@ObjectType = 'Dim' , 'AND MT.' + @ColumnName +' IS NULL', '') + '
			

			SET @RecordCountDebug=@@ROWCOUNT '

		IF @DCType  LIKE '%Other%' PRINT  '  			
			UPDATE MT
				SET ' + IIF (@ObjectType = 'Dim' , ' MT.' + @ColumnName +'=DC.Mapping_Current_ID,', '') + '
				'+@SourceColumn+'_DC= DC.Mapping_Current
				,MT.' + @SourceColumn +'_Flag=1
				,MT.LoadNote='''+  @SourceColumn  + '|Warning:'+@ColumnName+' got value from data conversion''' + @LoadNotes +' 
			FROM #Tmp_HoldData_Final MT
			JOIN ' + @dcTable + ' DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.' + @SourceColumn+ '
			WHERE  DC.TableName=''' + @TableName + '''
				' + ISNULL(@OtherFilter,'')  +  '

			SET @RecordCountDebug=@@ROWCOUNT 
			'

			if @printflag = 1 
				BEGIN 
					 SET @seq = @seq + 1
			  print '            '  + @print + '''' + convert(VARCHAR, @seq)   + ''' +   CONVERT (VARCHAR(50),GETDATE(),109) 
			' + @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10))
	
					'
				END 

		END -- DC 
	  IF (@ObjectType = 'Dim') --DIM 
		 PRINT '
	       /*UPDATING THE ' + @TableFlag + ' FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN '+@dcTable+' TABLE*/

			UPDATE #Tmp_HoldData_Final 
					SET ' + @TableFlag +'=1
					   , LoadNote = '''+ @SourceColumn + '|Pending Review:Not a valid ' +  @SourceColumn +'''' + @LoadNotes +'
			WHERE ' + @ColumnName + ' IS NULL 

			SET @RecordCountDebug=@@ROWCOUNT 

              '	+ @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) 
			
			'

			SET @cid  =  @cid + 1
	END 

	--print '/*'
	--print @SectionBreak 
	--print '8 - Move column-x data to column-y   '
	--print @SectionBreak
	--print '*/
	--'

	--DECLARE @cim INT = 1 , @SourceColumnmv VARCHAR(128), @TargetColumnmv VARCHAR(128), @TableNamemv VARCHAR(128), @FilterConditionmv VARCHAR(MAX), @DimValueColumnmv VARCHAR(128), @ObjectTypemv VARCHAR(8)
	--WHILE (@cim <=  @mfc) 
	--BEGIN 
	--    SELECT @SourceColumnmv = SourceColumn, @TableNamemv = TableName, @TargetColumnmv= TargetColumn, @FilterConditionmv = FilterCondition, @DimValueColumnmv = DimValueColumn,@ObjectTypemv = ObjectType  FROM #move WHERE Id = @cim
	--	PRINT 
	--		'/*THIS CODE IS TO GET MATCH FOR ' +@SourceColumnmv + ' FROM ' + @TableNamemv + '.' +@DimValueColumnmv +' STANDARD LOOKUP AND UPDATE THE STANDARD ' +  @TargetColumnmv  + '
	--		AND MOVE ' + @SourceColumnmv +' TO '+ @SourceColumnmv + '_mv  AND REPLACE ' + @SourceColumnmv +' BY '+ @DimValueColumnmv +' */ 

	--		UPDATE f
	--				SET f.' + @TargetColumnmv +'=ds.'+@TargetColumnmv+',
	--				    '+IIF (@ObjectTypemv = 'Dim','f.Dim' + @SourceColumnmv +'Id= 0','f.' + @SourceColumnmv )+ ','
	--		IF (@ObjectTypemv != 'Dim') PRINT 'f.' + @SourceColumnmv + '_mv = '+ @SourceColumnmv +','
	--		PRINT '	                    f.LoadNote = '''+ @SourceColumnmv +',' + @TargetColumnmv + '|Warning:Moved data From ' +  @SourceColumnmv +' To ' + @TargetColumnmv +'''' + @LoadNotes +'
	--		FROM #Tmp_HoldData_Final f WITH(NOLOCK)
	--		INNER JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[' + @TableNamemv +'] ds WITH(NOLOCK) ON f.'+@SourceColumnmv+ ' = ds.' +@DimValueColumnmv + '
	--		' + @FilterConditionmv  + '
	--		'
	--	  SET @cim  = @cim + 1

	--END 

	print '/*'
	print @SectionBreak 
	print '9 - Parent Validations   '
	print @SectionBreak
	print '*/
	'
   		
	--PRINT 
	--			'--scenario 1
	--			UPDATE P
	--			SET P.LoadNote= '''+@TargetTable+ '|MissingChild:ChildMissing '+@TargetTable+ '''' + REPLACE(@LoadNotes, 'LoadNote' ,'P.LoadNote') +'
	--			FROM #Tmp_HoldData_Final HF
	--			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[Person] P WITH(NOLOCK) ON P.PersonId=HF.PersonId
	--			WHERE HF.'+ @TableFlag +'=1
	--				AND HF.PersonId IS NOT NULL

 --          		SET @RecordCountDebug=@@ROWCOUNT 
	--			'
	--PRINT	'                '	+ @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	--' 

	PRINT 		'--scenario 2 & 3
				UPDATE #Tmp_HoldData_Final
				SET '+ @TableFlag +'=1
					,LoadNote= ''Person|ParentMissing:Validation Errors'''  + @LoadNotes +'
					WHERE PersonId IS NULL
					AND SrId IN (SELECT SRID FROM '+@stagingdb +'RVRS.Person_Log WITH(NOLOCK))

				SET @RecordCountDebug=@@ROWCOUNT 
				'
   PRINT	'                '	+ @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	' 	

	--PRINT 
	--			'--scenario 4
	--			IF EXISTS(SELECT 1 FROM #Tmp_HoldData_Final WHERE PersonId IS NULL 
	--				        AND SrId NOT IN (SELECT SRID FROM '+@stagingdb +'RVRS.Person_Log WITH(NOLOCK))
	--				        AND '+ @TableFlag +'=0
	--					 )
	--				BEGIN
	--					SET @ExecutionStatus=''Failed''
	--					SET @Note = ''Parent table has not been processed yet''     
	--					RAISERROR (@Err_Message,16,1)
	--				END

	--			SET @RecordCountDebug=@@ROWCOUNT
	--			'
 -- PRINT	'                '	+ @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	--' 	

    
	PRINT
			'--scenario 5
				UPDATE #Tmp_HoldData_Final
					SET LoadNote=''Person|ParentMissing:Not Processed''' +@LoadNotes +'
					 WHERE PersonId IS NULL
					  AND SrId NOT IN (SELECT SRID FROM '+@stagingdb +'RVRS.Person_Log WITH(NOLOCK))
					  AND '+ @TableFlag +'=1

			    SET @RecordCountDebug=@@ROWCOUNT 
			    '
  PRINT	'                '	+ @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	' 	
		
	PRINT  '--scenario 4
                           UPDATE #Tmp_HoldData_Final                                               
                                 SET '+ @TableFlag +' = 1
                              ,LoadNote=CASE WHEN LoadNote!='''' 
                                        THEN ''Person|ParentMissing:Not Processed'' + '' || '' +  LoadNote  ELSE ''Person|ParentMissing:Not Processed'' END
                                 WHERE PersonId IS NULL 
                                 AND SrId NOT IN (SELECT SRID FROM '+@stagingdb +'RVRS.Person_Log)
                                 AND '+ @TableFlag +' = 0

                    SET @TotalParentMissingRecords=@@rowcount

                    IF @TotalParentMissingRecords>0 
                           BEGIN
                                 SET @ExecutionStatus=''Failed''
                                 set @Note = ''Parent table has not been processed yet''
                           END

					SET @RecordCountDebug=@@ROWCOUNT
'

  PRINT	'                '	+ @print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10))  '

  if @testflag = 1
		BEGIN 
			print ' select * from #Tmp_HoldData_Final ' 
			Print @DimSelectSQL
		END 

	print '/*'
	print @SectionBreak 
	print '10 - LOAD to Target    '
	print @SectionBreak
	print '*/

	'

	PRINT 'SET @LastLoadDate = (SELECT MAX(SrUpdatedDate) FROM #Tmp_HoldData)

			INSERT INTO '  +@Target + '
			(
				' + @TargetColumns +'
				,CreatedDate
				,LoadNote
			)
			SELECT 
			    ' + @TargetColumnsMod +'
				,CreatedDate
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE '+ @TableFlag +'=0
			AND PersonId IS NOT NULL

			SET @TotalLoadedRecord = @@ROWCOUNT 		
		'
	PRINT		@print + ''''  +   @recordNumberPrint + ''' +  CAST(@TotalLoadedRecord AS VARCHAR(10)) 

	'
	if @testflag = 1
			print ' select * from '  +@Target  

	print '/*'
	print @SectionBreak 
	print '11 - LOAD to Log    '
	print @SectionBreak
	print '*/

	'

	PRINT 
	'INSERT INTO ' + @Workdb+ '[RVRS].['+ @TargetTable +'_Log]
			(
				 SrId' + 
				IIF (@DcColumns IS NOT NULL ,',' + @DcColumns,'') + '
				 ,' + @TargetColumns + '	
				 ,' + @SourceColumns + '
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,' + @TableFlag + '
				,LoadNote
			)
			SELECT 
			    SrId ' +
				IIF (@DcColumns IS NOT NULL ,',' + @DcColumns,'') + '
				,' + @TargetColumns + '
				,' + @SourceColumns +'
				,SrCreatedDate
				,SrUpdatedDate
				,CreatedDate
				,' + @TableFlag + '
				,LoadNote
			FROM #Tmp_HoldData_Final
			WHERE ' + @TableFlag + '=1

			SET @TotalErrorRecord = @@ROWCOUNT
			'
	PRINT		@print + ''''  +   @recordNumberPrint + ''' +  CAST(@TotalErrorRecord AS VARCHAR(10)) 

	'
	if @testflag = 1
			print ' select * from '  + @Workdb+ '[RVRS].['+ @TargetTable +'_Log] ' 
	
	print '/*'
	print @SectionBreak 
	print '12 - LOAD to DeathOriginal    '
	print @SectionBreak
	print '*/

	'
	SET @cid = 1

	WHILE (@cid <=  @cfc) 
	BEGIN 
			SELECT @SourceColumn = SourceColumn, @TableName = TableName, @ColumnName = ColumName, @ObjectType = ObjectType, @DC = DC  FROM #dc WHERE Id = @cid
	   SET @cid  =  @cid + 1
    IF @DC  = 0
		BEGiN 
			
			 CONTINUE 

		END 

	PRINT '/*INSERTING DATA INTO RVRS.DeathOriginal FOR THE RECORDS WHERE WE HAVE A CONVERSION FOR ' +@ColumnName +'*/

			INSERT INTO '+ @TargetOriginal +'
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
				,''' + @TargetTable + ''' AS Entity
				,'''+ @TargetTable + 'Id'' AS EntityColumnName
				,PA.'+ @TargetTable + 'Id AS EntityId
				,'''+ @ColumnName + ''' AS ConvertedColumn
				,MT.' + @SourceColumn + ' AS OriginalValue
				,MT.' + @SourceColumn + '_DC AS ConvertedValue
			FROM #Tmp_HoldData_Final MT
			JOIN '+@Target +'  PA ON PA.PersonId=MT.PersonId ' +
			@AddFilterOriginal + '	
			WHERE MT.' +@SourceColumn+'_Flag=1

			SET @RecordCountDebug=@@ROWCOUNT
			'
	
	PRINT		@print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) 

	'

	END 

	if @testflag = 1 
			print ' select * from '  + @TargetOriginal + ' WHERE Entity = '''  + @TargetTable + ''''

	print '/*'
	print @SectionBreak 
	print '13 - Update Execution  Status  '
	print @SectionBreak
	print '*/

	'

	PRINT 

	'   SET @TotalPendingReviewRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE '+@TableFlag+ '=1
									AND LoadNote LIKE ''%|Pending Review%'')
	SET @TotalWarningRecord=(SELECT COUNT(1) FROM #Tmp_HoldData_Final WHERE LoadNote NOT LIKE ''%|Pending Review%''
								AND LoadNote LIKE ''%|WARNING%'')
	UPDATE ' + @Workdb  + '[RVRS].[Execution]
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

		'
PRINT		@print + ''''  +   @recordNumberPrint + ''' +  CAST(@RecordCountDebug AS VARCHAR(10)) '

if @testflag = 1 
			print ' select * from '  + @Workdb  + '[RVRS].[Execution] WHERE Entity= ''' + @TargetTable + '''' 

PRINT 	
'END TRY
 BEGIN CATCH
		PRINT ''CATCH''
		UPDATE ' + @Workdb  + '[RVRS].[Execution]
		SET ExecutionStatus=''Failed''
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

'

	print '/*'
	print @SectionBreak 
	print '														END END END'
	print @SectionBreak
	print '*/

	'