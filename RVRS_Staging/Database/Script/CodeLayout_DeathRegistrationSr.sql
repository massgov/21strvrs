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

DECLARE @TargetTable VARCHAR(128) = 'DeathRegistration',  -- replace this 
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
		@TypeColumn VARCHAR(128) = 'DimRegistrarTypeInternalId', --Order -- replace this as needed otherwise leave it blank  
        @currentDate VARCHAR(12) = convert (VARCHAR(16),getdate()), 
        @jiraID VARCHAR(16) = '174', @author VARCHAR(128) = 'Sailendra Singh', -- replace author name and jira #
        @printflag bit = 1 , 
		@seq INT = 0 ,
	    @SectionBreak VARCHAR(MAX) = '----------------------------------------------------------------------------------------------------------------------------------------------',
	    @print VARCHAR(8) = 'PRINT ', 
	    @UnionCount INT, 	    
	    @recordNumberPrint VARCHAR(128) = ' Number of Record = ',
		@cfc int,@mfc int,
		@top VARCHAR(128) =  '  ',  -- For PROD leave this blank , FOR TEST PUT TOP 100
		@stagingdb VARChar(128) = '' , --For PROD leave this blank else keep [RVRS_Staging].
        @LoadNotes VARCHAR(MAX) = ' + CASE WHEN LoadNote !='''' THEN ''||'' + LoadNote ELSE '''' END '
  DECLARE     @Workdb VARCHAR(128) = ' ',  -- For PROD leave this blank or set to @stagingdb else keep [RVRS_testdb].
		@rc INT = 0,
	    @TargetCreate VARCHAR(MAX),@TargetColumns VARCHAR(MAX), @TargetColumnsMod VARCHAR(MAX),@TargetCreateReplaceDatetime VARCHAR(MAX),
        @SourceCreate VARCHAR(MAX), @SourceColumns VARCHAR(MAX) , 
	    @DcFlagCreate VARCHAR(MAX), @FlagColumns VARCHAR(MAX), 
		@DcCreate VARCHAR(MAX), @DcColumns VARCHAR(MAX),
		@DimCreate VARCHAR(MAX), @DimColumns VARCHAR(MAX),
		--@MoveCreate VARCHAR(MAX), @MoveColumns VARCHAR(MAX),
		@testflag bit = 0 -- set this to 0 for production 

    DECLARE	@targetloc varchar(128) ='[RVRS_PROD].[RVRS_ODS].' -- For PROD replace this by [RVRS_PROD].[RVRS_ODS] or else keep @workdb. 
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


--('1',1,'','','DimRegistrarTypeInternalId', 'VARCHAR(128)', 1,NULL),
('1000000 + OCCUR_REGIS_NAME',1,'','','RegistrarId', 'VARCHAR(128)', 1,'''0'''),
('OCCUR_REGIS_NAMEL',1,'','','RegistrarName', 'VARCHAR(128)', 1,'''NULL'''),
('OCCUR_REGIS_NUM',1,'','','RegistrationNumber', 'VARCHAR(128)', 1,NULL),
('OCCUR_REGIS_DATE',1,'','','RegistrationDate', 'VARCHAR(128)', 1,NULL),
('OCCUR_REGIS_VOLUME',1,'','','RegVolume', 'VARCHAR(128)', 1,NULL),
('OCCUR_REGIS_PAGE',1,'','','RegPage', 'VARCHAR(128)', 1,NULL),
('OCCUR_DEPOSITION_NUM',1,'','','DepositionNumber', 'VARCHAR(128)', 1,NULL),
('OCCUR_AMENDMENT_DATE',1,'','','AmendmentDate', 'VARCHAR(128)', 1,NULL),
('ARCHIVAL_COPY_PRINTED_DATE',1,'','','ArchivalPrintedDate', 'VARCHAR(128)', 1,NULL),
('FL_OCCUR_ARCHIVED',1,'','','FlArchived', 'VARCHAR(128)', 1,NULL),
('OCCUR_REGISTERED_FL',1,'','','FlRegistered', 'VARCHAR(128)', 1,NULL),
('FL_SEARCHABLE',1,'','','FlSearchable', 'VARCHAR(128)', 1,NULL),
('REGISTERER_ID',1,'','','SrcRegistererUserId', 'VARCHAR(128)', 1,NULL),
('NULL',1,'','','FlAcknowledge', 'VARCHAR(128)', 1,NULL),
('NULL',1,'','','PreviousVolumePage', 'VARCHAR(128)', 1,NULL),
('NULL',1,'','','PageEntryType', 'VARCHAR(128)', 1,'''NULL'''),
('NULL',1,'','','RecordAccess', 'VARCHAR(128)', 1,'''NULL'''),
('OCCUR_REGIS_DATE',1,'','','OCCUR_REGIS_DATE', 'VARCHAR(128)',1,NULL),
('RESIDE_REGIS_DATE',1,'','','RESIDE_REGIS_DATE', 'VARCHAR(128)',1,NULL),
('ST_REGIS_DATE',1,'','','ST_REGIS_DATE', 'VARCHAR(128)',1,NULL),
('DOD',1,'','','DOD', 'VARCHAR(128)', 1,NULL),
('VRV_REC_REPLACE_NBR',1,'','','VRV_REC_REPLACE_NBR', 'VARCHAR(128)', 1,NULL),
('FL_OCCUR_IS_RESIDE',1,'','','FL_OCCUR_IS_RESIDE', 'VARCHAR(128)', 1,NULL),

--('2',2,'','','', 'VARCHAR(128)', 2,NULL),CAST(RESIDE_REGIS_NAME AS VARCHAR(50))
('1000000 + RESIDE_REGIS_NAME',2,'','','', 'VARCHAR(128)', 2,'''0'''),
('RESIDE_REGIS_NAMEL',2,'','','', 'VARCHAR(128)', 2,'''NULL'''),
('RESIDE_REGIS_NUM',2,'','','', 'VARCHAR(128)', 2,NULL),
('RESIDE_REGIS_DATE',2,'','','', 'VARCHAR(128)', 2,NULL),
('RESIDE_REGIS_VOLUME',2,'','','', 'VARCHAR(128)', 2,NULL),
('RESIDE_REGIS_PAGE',2,'','','', 'VARCHAR(128)', 2,NULL),
('RESIDE_DEPOSITION_NUM',2,'','','', 'VARCHAR(128)', 2,NULL),
('NULL',2,'','','', 'VARCHAR(128)', 2,NULL),
('ARCHIVL_COPY_PRINT_RESIDE_DATE',2,'','','', 'VARCHAR(128)', 2,NULL),
('FL_RES_ARCHIVED',2,'','','', 'VARCHAR(128)', 2,NULL),
('RESIDE_REGISTERED_FL',2,'','','', 'VARCHAR(128)', 2,NULL),
('FL_SEARCHABLE_RESIDE',2,'','','', 'VARCHAR(128)', 2,NULL),
('REGISTERER_ID_RE',2,'','','', 'VARCHAR(128)', 2,NULL),
('RESIDE_AMEND_ACKNOWLEDGE_FL',2,'','','', 'VARCHAR(128)', 2,NULL),
('NULL',2,'','','', 'VARCHAR(128)', 2,NULL),
('NULL',2,'','','', 'VARCHAR(128)', 2,'''NULL'''),
('NULL',2,'','','', 'VARCHAR(128)', 2,'''NULL'''),
('OCCUR_REGIS_DATE',2,'','','', 'VARCHAR(128)',2,NULL),
('RESIDE_REGIS_DATE',2,'','','', 'VARCHAR(128)',2,NULL),
('ST_REGIS_DATE',2,'','','', 'VARCHAR(128)',2,NULL),
('DOD',2,'','','', 'VARCHAR(128)',2,NULL),
('VRV_REC_REPLACE_NBR',2,'','','', 'VARCHAR(128)', 2,NULL),
('NULL',2,'','','', 'VARCHAR(128)', 2,NULL),

--('3',3,'','','', 'VARCHAR(128)', 3,NULL),
('2000000 + ST_REGIS_NAME',3,'','','', 'VARCHAR(128)', 3,'''0'''),
('NULL',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_REGIS_NUM',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_REGIS_DATE',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_VOLUME',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_PAGE',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_DEPOSITION_NUM',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_AMENDMENT_DATE',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_ARCHVL_COPY_PRINTED_DATE',3,'','','', 'VARCHAR(128)', 3,NULL),
('FL_RVRS_ARCHIVED',3,'','','', 'VARCHAR(128)', 3,NULL),
('STATE_REGISTERED_FL',3,'','','', 'VARCHAR(128)', 3,NULL),
('FL_SEARCHABLE_RVRS',3,'','','', 'VARCHAR(128)', 3,NULL),
('REGISTERER_ID_ST',3,'','','', 'VARCHAR(128)', 3,NULL),
('NULL',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_PREVIOUS_VOL_PAGE',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_VOL_PAGE_ENTRY_TYPE',3,'','','', 'VARCHAR(128)', 3,'''NULL'''),
('ST_VOLUME_TYPE',3,'','','', 'VARCHAR(128)', 3,'''NULL'''),
('OCCUR_REGIS_DATE',3,'','','', 'VARCHAR(128)', 3,NULL),
('RESIDE_REGIS_DATE',3,'','','', 'VARCHAR(128)', 3,NULL),
('ST_REGIS_DATE',3,'','','', 'VARCHAR(128)', 3,NULL),
('DOD',3,'','','', 'VARCHAR(128)',3,NULL),
('VRV_REC_REPLACE_NBR',3,'','','', 'VARCHAR(128)', 3,NULL),
('NULL',3,'','','', 'VARCHAR(128)', 3,NULL)




--('DOI',1,'','','DOI', 'VARCHAR(128)', NULL,NULL),
--('RIGHT(DOI,4)',1,'','','InjuryYear', 'VARCHAR(128)',NULL,NULL ),
--('LEFT(DOI,2)',1,'','','InjuryMonth', 'VARCHAR(128)', NULL,NULL ),
--('SUBSTRING(DOI,4,2)',1,'','','InjuryDay', 'VARCHAR(128)', NULL,NULL ),
--('TOI',1,'','','TOI', 'VARCHAR(128)', NULL,NULL),
--('LEFT(TOI,2)',1,'','','InjuryHour', 'VARCHAR(128)', NULL,NULL ),

--('RIGHT(TOI,2)',1,'','','InjuryMinute', 'VARCHAR(128)', NULL,NULL ),
--('TOI_IND',1,'','','InjuryTimeInd', 'VARCHAR(128)', NULL,'''NULL'''),
--('INJRY_WORK',1,'','','InjuryAtWork', 'VARCHAR(128)', NULL,'''NULL'''),
--('INJRY_L',1,'','','InjuryNature', 'VARCHAR(128)', NULL,NULL),
--('INJRY_PLACEL',1,'','','InjuryPlace', 'VARCHAR(128)', NULL,'''NULL'''),
--('INJRY_PLACEL',1,'','','InjuryPlaceOther', 'VARCHAR(128)', NULL,'''NULL'''),
--('INJRY_TRANSPRT',1,'','','InjuryTransport', 'VARCHAR(128)', NULL,'''NULL'''),
--('INJRY_TRANSPRT_OTHER',1,'','','InjuryTransportOther', 'VARCHAR(128)', NULL,'''NULL'''),
--('CERT_DESIG',1,'','','Certifier', 'VARCHAR(128)', NULL,'''NULL'''),
--('MANNER_L',1,'','','MannerOfDeath', 'VARCHAR(128)', NULL,NULL)


IF OBJECT_ID('tempdb..#validation') IS NOT NULL 
    drop table #validation

CREATE TABLE #validation (id INT identity(1,1), columnname  VARCHAR(128), condition VARCHAR(MAX), errormessage VARCHAR(MAX),errortype VARCHAR(64) )  -- errortype = 'Error', 'Warning' , 'Pending', 'ParentMissing', 'ChildMissing'

INSERT INTO #validation (columnname , condition , errormessage,errortype) values 
						
						('RegistrationDate','ISDATE(REPLACE(REPLACE (COALESCE(RegistrationDate,''01/01/1900''),''/9999'', ''/1900''),''99/'',''01/''))=0','Not a valid Date of Registration',  'Error'),
						('RegistrationDate','Try_Cast(RegistrationDate AS DateTime)<Try_Cast(DOD AS DateTime)','Date of Registration is before Date of Death','Error'), 
						('RegistrationDate,OCCUR_REGIS_DATE,','OCCUR_REGIS_DATE IS NULL','Date of Occurance cannot be blank for registered records','Error'), 
						('OCCUR_REGIS_DATE,RESIDE_REGIS_DATE,ST_REGIS_DATE,VRV_REC_REPLACE_NBR','(Try_Cast(OCCUR_REGIS_DATE AS DateTime)>Try_Cast(RESIDE_REGIS_DATE AS DateTime) 
						OR Try_Cast(OCCUR_REGIS_DATE AS DateTime)>Try_Cast(ST_REGIS_DATE AS DateTime)) AND (VRV_REC_REPLACE_NBR = 0)','Date of Occurance must be first for Version 0','Error'), 
						('FL_OCCUR_IS_RESIDE,RESIDE_REGIS_DATE','FL_OCCUR_IS_RESIDE = ''Y'' AND RESIDE_REGIS_DATE IS NOT NULL','When Death occurred in residence the Residence Registration information should be blank',  'Error'),

						('AmendmentDate','ISDATE(REPLACE(REPLACE (COALESCE(AmendmentDate,''01/01/1900''),''/9999'', ''/1900''),''99/'',''01/''))=0','Not a valid Date of Amendment',  'Error'),
						('AmendmentDate,RegistrationDate','Try_Cast(AmendmentDate AS DateTime)<Try_Cast(RegistrationDate AS DateTime)','Date of Amendment is before Date of Registration','Error'),
						('AmendmentDate,VRV_REC_REPLACE_NBR','AmendmentDate IS NOT NULL AND VRV_REC_REPLACE_NBR = 0','The version of Record should not be 0 if Date of Amendment is not blank','Error'),
						

						('ArchivalPrintedDate','ISDATE(REPLACE(REPLACE (COALESCE(ArchivalPrintedDate,''01/01/1900''),''/9999'', ''/1900''),''99/'',''01/''))=0','Not a valid Archival Printed Date',  'Error'),
						('ArchivalPrintedDate,RegistrationDate','Try_Cast(ArchivalPrintedDate AS DateTime)<Try_Cast(RegistrationDate AS DateTime)','Archival Printed Date is before Date of Registration ','Error'), 

						('FlAcknowledge','ISNULL(FlAcknowledge,''Y'') NOT IN (''N'',''Y'')','Not a valid value for FlAcknowledge','Error'), 

						('FlArchived','ISNULL(FlArchived,''Y'') NOT IN (''N'',''Y'')','Not a valid value for FlArchived','Error'), 
						('FlArchived,ArchivalPrintedDate','ArchivalPrintedDate IS NOT NULL AND FlArchived<>''Y'' ','If Archival Printed Date is not blank then the value for FlArchived must be Y','Error'), 

						('FlRegistered,OCCUR_REGIS_DATE','FlRegistered = ''Y'' AND OCCUR_REGIS_DATE IS NULL','If FlRegistered value is Yes then there must be Occurance Registered Date','Error'),
						('FlRegistered','ISNULL(FlRegistered,''Y'') NOT IN (''N'',''Y'')','Not a valid value for FlRegistered','Error'),

						('FlSearchable','ISNULL(FlSearchable,''Y'') NOT IN (''N'',''Y'')','Not a valid value for FlSearchable','Error')
						 
			            
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

CREATE TABLE #dc (id INT identity(1,1), SourceColumn VARCHAR(128), TableName VARCHAR(128),  ColumName VARCHAR(128),DimColumn VARCHAR(128),Flag Bit, ObjectType VARCHAR(8) default 'Dim', DataType VARCHAR(128), DC Bit, OtherFilter VARCHAR(MAX), DCType VARCHAR(16), DCTableName VARCHAR(128), DimFilter VARCHAR(512) )

insert into  #dc  (SourceColumn,TableName,ColumName,DimColumn, ObjectType,DataType, DC, OtherFilter, DCType,DCTableName,DimFilter) values --DCType = OtherOnly, StandardOnly, Standard&Other

	('RegistrarId','DimRegistrar', 'DimRegistrarId','BkRegistrarId', 'Dim', 'INT',0,NULL,NULL,NULL,NULL),
	('RegistrationNumber','DeathRegistration_RegistrationNumber', 'RegistrationNumber','', 'Fact', 'VARCHAR(128)',1, NULL, NULL,'[RVRS].[Data_Conversion]',NULL),
	('DepositionNumber','DeathRegistration_DepositionNumber', 'DepositionNumber','', 'Fact', 'VARCHAR(128)',1, NULL, NULL,'[RVRS].[Data_Conversion]',NULL),
	('RegVolume','DeathRegistration_Volume', 'Volume','', 'Fact', 'VARCHAR(128)',1, NULL, NULL,'[RVRS].[Data_Conversion]',NULL),
	('RegPage','DeathRegistration_Volume', 'Page','', 'Fact', 'VARCHAR(128)',1, NULL, NULL,'[RVRS].[Data_Conversion]',NULL),
	('PageEntryType','DimPageEntryType', 'DimPageEntryTypeId','Abbr', 'Dim', 'INT',0, NULL, NULL,NULL,NULL),
	('RecordAccess','DimRecordAccess', 'DimRecordAccessId','Abbr', 'Dim', 'INT',0, NULL, NULL,NULL,NULL)

	--Volume
	--('InjuryTimeInd','DimTimeInd', 'DimInjuryTimeIndId','Abbr', 'Dim', 'INT',0, NULL, NULL,NULL,NULL),
	--('InjuryAtWork','DimYesNo', 'DimInjuryAtWorkId','Abbr', 'Dim', 'INT',0, NULL, NULL,NULL,NULL),
	--('InjuryNature','DeathInjury_InjuryNature' ,'InjuryNature','','Fact', 'VARCHAR(128)',1, NULL, NULL,'[RVRS].[Data_Conversion]',NULL),  
	--('InjuryPlace','DimInjuryPlace', 'DimInjuryPlaceId','InjuryPlaceDesc', 'Dim', 'INT',1, NULL, NULL,'[RVRS].[DeathInjury_InjuryPlace_Data_Conversion]',NULL), --THIS SECTION
	--('InjuryPlaceOther','DimOtherInjuryPlace', 'DimOtherInjuryPlaceId','OtherInjuryPlaceDesc', 'Dim', 'INT',1,NULL,NULL,'[RVRS].[Data_Conversion]','AND MT.DimInjuryPlaceId = 9 OR MT.InjuryPlaceOther = ''NULL'''),
	--('InjuryTransport','DimInjuryTransport', 'DimInjuryTransportId','InjuryTransportDesc', 'Dim','INT',0, NULL, NULL,NULL,NULL),
	--('InjuryTransportOther','DimInjuryTransportOther', 'DimInjuryTransportOtherId','InjuryTransportOtherDesc', 'Dim', 'INT',1, NULL, NULL,'[RVRS].[Data_Conversion]',NULL)

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
	DECLARE @cid INT = 1 , @SourceColumn VARCHAR(128), @ColumnName VARCHAR(128), @TableName VARCHAR(128), @ObjectType VARCHAR(128), @DataType VARCHAR(128), @DC BIT, @OtherFilter VARCHAR(MAX) = '' , @DCType VARCHAR(16) ,@DimColumn VARCHAR(128), @DimFilter VARCHAR (512)
	WHILE (@cid <=  @cfc) 
	BEGIN 
			SELECT @SourceColumn = SourceColumn, @TableName = TableName, @ColumnName = ColumName, @ObjectType = ObjectType, @DataType = DataType,@DC= DC,  @OtherFilter = OtherFilter, @DCType = DCTYPE, @DimColumn=DimColumn, @dcTable = DCTableName, @DimFilter = DimFilter  FROM #dc WHERE Id = @cid


	    DECLARE @DimSelectSQL VARCHAR(MAX) 
		IF (@ObjectType = 'Dim')
			BEGIN 

			PRINT '/*THIS CODE IS TO GET MATCH FROM ' + @TableName +' TABLE AND UPDATE THE '+ @ColumnName+' WITH CORRECT VALUE*/

			ALTER TABLE #Tmp_HoldData_Final ADD ' + @ColumnName + ' ' + @DataType  + '
		
			UPDATE MT
			SET MT.'+ @ColumnName+' =DS.'+ @TableName +'Id  
			FROM #Tmp_HoldData_Final MT
			JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[' + @TableName +'] DS WITH(NOLOCK) ON DS.' +trim(@DimColumn) + '=MT.' +@SourceColumn + IIF(@DimFilter IS NOT NULL,' ' + @DimFilter, '') + '

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
			JOIN ' +@stagingdb+ @dcTable + ' DC WITH(NOLOCK) ON DC.Mapping_Previous=MT.' + @SourceColumn+ '
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
	       /*UPDATING THE ' + @TableFlag + ' FOR ALL THE RECORDS FOR WHICH WE WILL NOT HAVE A MATCH IN '+ISNULL(@dcTable,'')+' TABLE*/

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