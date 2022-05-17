select * from INFORMATION_SCHEMA.COLUMNS s where s.column_name = 'Abbr' --[Abbr]
alter table rvrs.DimYesNo alter column Abbr varchar(16) null 
alter table rvrs.DimTimeInd alter column Abbr varchar(16) null 
alter table rvrs.DimSex alter column Abbr varchar(16) null 
alter table rvrs.DimMaritalStatus alter column Abbr varchar(16) null 
alter table rvrs.DimDeathManner alter column Abbr varchar(16) null 
alter table rvrs.DimAutoPysPerformed alter column Abbr varchar(16) null 
