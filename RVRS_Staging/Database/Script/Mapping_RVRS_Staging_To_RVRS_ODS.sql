begin 
use RVRS_testdb
--drop table TempMapping
--drop table tempMappingAddress
IF Object_ID ('tempdb..#TempMapping') is not null drop table  #TempMapping
	CREATE table #TempMapping (Source varchar(128), SourceTable varchar(128),TargetTable varchar(128), SourceCol varchar(128), TargetCol varchar(128), AddType varchar(64), [Desc] Varchar(1024))

INSERT INTO  #TempMapping  (SourceCol , TargetCol  ) values
('RES_ADDR_NUM', 'StreetNumber'),
('RES_CITY', 'DimCityId'),
('RES_CITY_LOC_ID','TBD'),
('RES_ADDR1', 'StreetName'),
('RES_ADDR2', 'AptOrUnitNumber'),
('RES_COUNTRY_FIPS_CD', 'DimCountryId'),
('RES_STREET_DESIG', 'DimStreetDesigId'),
('RES_STATE_NCHS_CD', 'DimStateId'),
('RES_STATE_FIPS_CD', 'DimStateId'),
('RES_COUNTY_FIPS_CD','DimCountyId'),
('RES_COUNTY_NCHS_CD','DimCountyId'),
('RES_CITY_FIPS_CD','DimCityId'),
('RES_ZIP', 'ZipCode'),
('RES_STREET_PREFIX','StreetDirection'),
('RES_STREET_SUFFIX','StreetDirection'),
('RES_STREET_PREFIX','StreetDirectionType'), --Set Prefix
('RES_STREET_SUFFIX','StreetDirectionType') --Set Suffix 
--('RES_LATITUDE', 'Latitude'),    --No data 
--('RES_LONGITUDE', 'Longitude')  -- No data 

update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = 'Decedent''s Residence'
from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section = 'Decedent''s Residence'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'
 
--2)  Place of Death Address
 insert into #TempMapping  (SourceCol , TargetCol ) values
('DNAME_FIPS_CD','DimCityId')
,('DCOUNTY_FIPS_CD','DimCountyId')
,('DCOUNTY_NCHS_CD','DimCountyId')
,('DFACILITYL', 'TBD')
,('BA_USER_TOWN_LOCATION_ID','TBD')
,('DFAC_LOC_ID', 'TBD')
,('DCITY_LOC_ID','TBD')
,('DNAME_CITY_CD', 'DimCityId')
,('DSTATEL_FIPS_CD','DimStateId')
,('DSTATEL_NCHS_CD','DimStateId')
,('RES_SAME_PLACE', 'TBD')
,('DFACILITY_UNLISTED','TBD')
,('DCOUNTRY', 'DimCountryId')
,('DSTATEL','DimStateId')
,('DSTREET_DESIG', 'DimStreetDesigId')
,('DSTREET_PREFIX' , 'StreetDirection')
,('DSTREET_SUFFIX','StreetDirectionType')
,('DSTREET_PREFIX' , 'StreetDirectionType')
,('DSTREET_SUFFIX','StreetDirection')
,('DADDR_NUM', 'StreetNumber')
,('DADDR2','AptOrUnitNumber')
,('DNAME_CITY', 'DimCityId')
,('DCOUNTY', 'DimCountyId')
,('DHOSPITALL', 'TBD')
,('DADDR1', 'StreetName')
,('DZIP9', 'ZipCode')



update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = 'Place of Death Address'
 from [dbo].[DDVIP] s inner join #TempMapping t  on s.COL = t.SourceCol
where section = 'Place of Death Address'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'
 
---3) Location Injury Occurred
 
 insert into #TempMapping  (SourceCol , TargetCol ) values
('INJRY_ADDR_UNK','TBD'),
('INJRY_STREET_PREFIX','StreetDirection'),
('INJRY_STREET_SUFFIX','StreetDirection'),
('INJRY_STREET_PREFIX','StreetDirectionType'),
('INJRY_STREET_SUFFIX','StreetDirectionType'),
('INJRY_ADDR_NUM','StreetNumber'),
('INJRY_ADDR1','StreetName'),
('INJRY_STREET_DESIG','DimStreetDesigId'),
('INJRY_ADDR2','AptOrUnitNumber'),
('INJRY_COUNTRY','DimCountryId'),
('INJRY_STATE','DimStateId'),
('INJRY_CITY','DimCityId'),
('INJRY_ZIP9','ZipCode')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = 'Location Injury Occurred'
 from [dbo].[DDVIP] s inner join #TempMapping t  on s.COL = t.SourceCol
where section = 'Location Injury Occurred'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'

  --4) Certifier Address

    
 insert into #TempMapping  (SourceCol , TargetCol ) values
('CERT_STREET_PREFIX','StreetDirection'),
('CERT_STREET_SUFFIX','StreetDirection'),
('CERT_STREET_PREFIX','StreetDirectionType'),
('CERT_STREET_SUFFIX','StreetDirectionType'),
('CERT_ADDR_NUM','StreetNumber'),
('CERT_ADDR1','StreetName'),
('CERT_STREET_DESIG','DimStreetDesigId'),
('CERT_ADDR2','AptOrUnitNumber'),
('CERT_CNTRY','DimCountryId'),
('CERT_STATE','DimStateId'),
('CERT_CITY','DimCityId'),
('CERT_ZIPCD','ZipCode')

update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Certifier Address'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'


/*
5) Informant Mailing Address
select *
from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Informant Mailing Address'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'
  */ 
 insert into #TempMapping  (SourceCol , TargetCol ) values
('INF_SAME_RES','TBD'),
('INFO_PO_BOX','TBD'),
('INFO_STREET_PREFIX','StreetDirection'),
('INFO_STREET_SUFFIX','StreetDirection'),
('INFO_STREET_PREFIX','StreetDirectionType'),
('INFO_STREET_SUFFIX','StreetDirectionType'),
('INFO_ADDR_NUM','StreetNumber'),
('INFO_ADDR1','StreetName'),
('INFO_STREET_DESIG','DimStreetDesigId'),
('INFO_ADDR2','AptOrUnitNumber'),
('INFO_COUNTRY','DimCountryId'),
('INFO_STATE','DimStateId'),
('INFO_CITY','DimCityId'),
('INFO_ZIP','ZipCode')

update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
 from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Informant Mailing Address'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'
/*
6)Funeral Home/Designee
select *
from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Funeral Home/Designee'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'
*/
 
 insert into #TempMapping  (SourceCol , TargetCol ) values
('FL_FUNERAL_HOME_UNLISTED','TBD'),
('FH_RESPONSIBLE_NAME','TBD'),
('FNRL_SERVICE_OOS','TBD'),
('TRADE_FH_UNLISTED','TBD'),
('FNRL_NME','TBD'),
('VRV_FUNERAL_HOME_LOC_ID','TBD'),
('FNRL_STREET_PREFIX','StreetDirection'),
('FNRL_STREET_SUFFIX','StreetDirection'),
('FNRL_STREET_PREFIX','StreetDirectionType'),
('FNRL_STREET_SUFFIX','StreetDirectionType'),
('FNRL_ADDR_NUM','StreetNumber'),
('FNRL_ADDR1','StreetName'),
('FNRL_STREET_DESIG','DimStreetDesigId'),
('FNRL_ADDR2','AptOrUnitNumber'),
('FNRL_CNTRY','DimCountryId'),
('FNRL_STATE','DimStateId'),
('FNRL_CITY','DimCityId'),
('FNRL_ZIPCD','ZipCode')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Funeral Home/Designee'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'

 /*
 --7)Place of Disposition
 select *
from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Place of Disposition'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'
 */
  insert into #TempMapping  (SourceCol , TargetCol ) values
('DISP_DATE','TBD'),
('CREM_CEM_UNLISTED','TBD'),
('DISP_NME','TBD'),
('DISP_STREET_PREFIX','StreetDirection'),
('DISP_STREET_SUFFIX','StreetDirection'),
('DISP_STREET_PREFIX','StreetDirectionType'),
('DISP_STREET_SUFFIX','StreetDirectionType'),
('DISP_ADDR_NUM','StreetNumber'),
('DISP_ADDR1','StreetName'),
('DISP_STREET_DESIG','DimStreetDesigId'),
('DISP_ADDR2','AptOrUnitNumber'),
('DISP_CNTRY','DimCountryId'),
('DISP_ST','DimStateId'),
('DISP_CTY','DimCityId'),
('DISP_ZIP','ZipCode')

update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Place of Disposition'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'
/*
8)Physician/ME Notified of Death

select '''' + col + '''' from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Physician/ME Notified of Death'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'
*/

Insert into #TempMapping  (SourceCol , TargetCol ) values
('MC_NOTIFIED_UNLISTED','TBD'),
('MC_NOTIFIED_TITLE','TBD'),
('MC_NOTIFIED_GNAME','TBD'),
('MC_NOTIFIED_MNAME','TBD'),
('MC_NOTIFIED_LNAME','TBD'),
('MC_NOTIFIED_SUFFIX','TBD'),
('MC_NOTIFIED_PHONE','TBD'),
('MC_NOTIFIED_STREET_PREFIX','StreetDirection'),
('MC_NOTIFIED_STREET_SUFFIX','StreetDirection'),
('MC_NOTIFIED_STREET_PREFIX','StreetDirectionType'),
('MC_NOTIFIED_STREET_SUFFIX','StreetDirectionType'),
('MC_NOTIFIED_ADDR_NUM','StreetNumber'),
('MC_NOTIFIED_STREET_NAME','StreetName'),
('MC_NOTIFIED_STREET_DESIG','DimStreetDesigId'),
('MC_NOTIFIED_ADDR2','AptOrUnitNumber'),
('MC_NOTIFIED_COUNTRY','DimCountryId'),
('MC_NOTIFIED_STATE','DimStateId'),
('MC_NOTIFIED_CITY','DimCityId'),
('MC_NOTIFIED_ZIP','ZipCode')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Physician/ME Notified of Death'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'

 /*
9)Pronouncer Info
   
select '''' + col + '''' from [dbo].[DDVIP] s 
-inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Pronouncer Info'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'
*/
 insert into #TempMapping  (SourceCol , TargetCol ) values
('PRO_TITLE', 'TBD'),
('PRO_GNAME', 'TBD'),
('PRO_MNAME','TBD'),
('PRO_LNAME','TBD'),
('PRO_SUFFIX','TBD'),
('PRO_MNAME_NONE', 'TBD'),
('PRO_LIC_NUM','TBD'),
('PRO_EMPLOYER','TBD'),
('PRO_EMP_ADDR_NUM', 'StreetNumber'),
('PRO_EMP_STREET_PREFIX', 'StreetDirection'),
('PRO_EMP_ADDR1','StreetName'),
('PRO_EMP_STREET_DESIG','DimStreetDesigId'),
('PRO_EMP_STREET_SUFFIX','StreetDirection'),
('PRO_EMP_ADDR2','AptOrUnitNumber'),
('PRO_EMP_COUNTRY','DimCountryId'),
('PRO_EMP_STATE','DimStateId'),
('PRO_EMP_CITY','DimCityId'),
('PRO_EMP_ZIP','ZipCode')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Pronouncer Info'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'





  /*
10)Father Birth Place 
   
 select '''' + col + '''' from 
 [dbo].[DDVIP] d 
 where 1=1   
    and SECTION = 'Father/Parent Info' 
 and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'


*/
 insert into #TempMapping  (SourceCol , TargetCol ) values
('FATHER_NME_UNK','TBD'),
('FATHER_GNAME', 'TBD'),
('FATHER_MNAME', 'TBD'),
('FATHER_LNAME', 'TBD'),
('FATHER_SUFF', 'TBD'),
('FATHER_LNAME_PRIOR', 'TBD'),
('FATHER_BCOUNTRY','DimCountryId'),
('FATHER_BCOUNTRY','DimStateId')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Father/Parent Info'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'

 /*
11)Mother Birth Place 
   
 select '''' + col + '''' from 
 [dbo].[DDVIP] d 
 where 1=1   
 and SECTION = 'Mother/Parent Info' 
 and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
 and SECTION !='System Flags'


*/
 insert into #TempMapping  (SourceCol , TargetCol ) values
('MOTHER_NME_UNK','TBD'),
('MOTHER_GNAME', 'TBD'),
('MOTHER_MNAME', 'TBD'),
('MOTHER_LNAME', 'TBD'),
('MOTHER_SUFF', 'TBD'),
('MOTHER_LNAME_PRIOR', 'TBD'),
('MOTHER_BCOUNTRY','DimCountryId'),
('MOTHER_BCOUNTRY','DimStateId')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Mother/Parent Info'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where section =  'Mother/Parent Info'
and EVENT_TABLE_NAME = 'VRV_DEATH_TBL' 
and SECTION !='System Flags'


  update #TempMapping set source  = 'VIP', SourceTable = 'VRV_DEATH_TBL', TargetTable=IIF(TargetCol LIKE '%TBD%','TBD', 'RVRS.Address') 


 /*
                        END VIP 

 */
 end 

 /*
     Basic information 
*/


--- PERSON 

 insert into #TempMapping  (SourceCol , TargetCol ) values

('DEATH_REC_ID','SrId'), 
('DEATH_REC_ID','Guid'),
('VRV_BASELINE_RECORD_ID','GuidBaseLine'),
('VRV_ORIGINATING_REC_ID', 'GuidOriginate'), 
('FL_CURRENT', 'Current'),
('FL_ABANDONED','Abandoned'),
('FL_VOIDED','SrVoided'),
('GNAME','FirstName'), 
('MNAME','MiddleName'), 
('LNAME','LastName'), 
('LNAME_MAIDEN','LastNameMaiden'),
('SEX','DimSexId'),
('AGE1_CALC','AgeCalcYear'),
('AGE1','Age1'),
('AGE2','Age1'),
('AGE3', 'Age2'),
('AGE4','Age1'),
 ('AGE5','Age2'),
('AGETYPE','DimAgeTypeId'),
('DOB','DateOfBirth'),
('AGETYPE','DimAgeTypeId'),
('MARITAL', 'DimMaritalStatusId'),
('VRV_REC_DATE_CREATED', 'SrCreatedDate'),
('LAST_UPDATED_DATE', 'SrUpdatedDate'),
('VRV_REC_INIT_USER_ID', 'SrCreatedUserId'),
('LAST_UPDATED_USER_ID', 'SrCreatedUserId')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
, TargetTable = 'RVRS.Person'
,SourceTable = 'VRV_DEATH_TBL'
,Source  = 'VIP'
--select *  
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol
where
 EVENT_TABLE_NAME = 'VRV_DEATH_TBL'
and  SECTION !='System Flags'
and s.COL in (
'DEATH_REC_ID',
'DEATH_REC_ID',
'VRV_BASELINE_RECORD_ID',
'VRV_ORIGINATING_REC_ID', 
'FL_CURRENT',
'FL_ABANDONED',
'SrVoided',
'GNAME',
'MNAME',
'LNAME',
'LNAME_MAIDEN',
'SEX',
'AGE1_CALC',
'AGE1',
'AGE2',
'AGETYPE',
'DOB',
'AGETYPE',
'MARITAL', 
'VRV_REC_DATE_CREATED',
'LAST_UPDATED_DATE',
'VRV_REC_INIT_USER_ID', 
'LAST_UPDATED_USER_ID','FL_VOIDED', 'AGE3','AGE4','AGE5')   and TargetTable is null



--AKA
 insert into #TempMapping  (SourceCol , TargetCol ) values
('AKA1_FNAME', 'FirstName'),
('AKA1_MNAME', 'MiddleName'),
('AKA1_LNAME', 'LastName'),
('AKA2_FNAME', 'FirstName'),
('AKA2_MNAME', 'MiddleName'),
('AKA2_LNAME', 'LastName'),
('AKA3_FNAME', 'FirstName'),
('AKA3_MNAME', 'MiddleName'),
('AKA3_LNAME', 'LastName'),
('AKA4_FNAME', 'FirstName'),
('AKA4_MNAME', 'MiddleName'),
('AKA4_LNAME', 'LastName')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
, TargetTable = 'RVRS.PersonOtherName'
,SourceTable = 'VRV_DEATH_TBL'
,Source  = 'VIP'
--select *  
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol

where
 EVENT_TABLE_NAME = 'VRV_DEATH_TBL'
and  SECTION !='System Flags'
and s.COL in (
'AKA1_FNAME',
'AKA1_MNAME',
'AKA1_LNAME',
'AKA2_FNAME',
'AKA2_MNAME',
'AKA2_LNAME',
'AKA3_FNAME',
'AKA3_MNAME',
'AKA3_LNAME',
'AKA4_FNAME',
'AKA4_MNAME',
'AKA4_LNAME'

)   and TargetTable is null





 --DEATH

  insert into #TempMapping  (SourceCol , TargetCol ) values
('INTERNAL_CASE_NUMBER', 'InternalCaseNumber'),
('SFN_TYPE_ID', 'SfnTypeId'),
('SFN_NUM', 'Sfn'),
('SFN_NUM_OOS', 'SfnOutOfState'),
('SFN_YEAR', 'SfnYear'),
('VRV_RECORD_TYPE_ID', 'RecordTypeId'),
('BIRTH_INTERNAL_CASE_NUMBER', 'InternalCaseNumberBirth'),
('BIRTH_SFN_NUM', 'SfnBirth'),
('BIRTH_YEAR', 'BirthYear'),
('ME_CASE_NUM', 'MeCaseNumber'),
('ME_CASE_YEAR', 'MeCaseYear'),
('DOD', 'DateOfDeath'),
('DOD_4_FD', 'DateOfDeathFd')


update t  SET [Desc] =  s.SCREEN  + '||' +  SECTION + '||' +  s.[TYPE] + '||' + s.COLTYPE  + '||' + convert(varchar,s.[LENGTH]) + '||' + s.FIELD
, AddType = section
, TargetTable = 'RVRS.Death'
,SourceTable = 'VRV_DEATH_TBL'
,Source  = 'VIP'
--select *  
   from [dbo].[DDVIP] s 
inner join #TempMapping t  on s.COL = t.SourceCol

where
 EVENT_TABLE_NAME = 'VRV_DEATH_TBL'
and  SECTION !='System Flags'
and s.COL in (
'INTERNAL_CASE_NUMBER',
'SFN_TYPE_ID',
'SFN_NUM',
'SFN_NUM_OOS',
'SFN_YEAR',
'VRV_RECORD_TYPE_ID',
'BIRTH_INTERNAL_CASE_NUMBER',
'BIRTH_SFN_NUM',
'ME_CASE_NUM',
'ME_CASE_YEAR',
'DOD',
'DOD_4_FD',
'BIRTH_YEAR'

)   and TargetTable is null



 select * from #TempMapping where TargetCol != 'TBD' -- 121 --600
