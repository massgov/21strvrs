/*
	Author : Bezawit 
	Date : 10/12/2021'

    1.0		Created		10/21/2021   RVRS-168		To store FK script for RVRS ODS database 
	

**/

--1) Address 
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[Address]') and name ='fk_AddressDimCountry')
	ALTER TABLE [RVRS].[Address] ADD CONSTRAINT [fk_AddressDimCountry] FOREIGN KEY ([DimCountryId]) REFERENCES [RVRS].[DimCountry] ([DimCountryId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[Address]') and name ='fk_AddressDimAddressType')
	ALTER TABLE [RVRS].[Address] ADD CONSTRAINT [fk_AddressDimAddressType] FOREIGN KEY ([DimAddressTypeId]) REFERENCES [RVRS].[DimAddressType] ([DimAddressTypeId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[Address]') and name ='fk_AddressDimCounty')
	ALTER TABLE [RVRS].[Address] ADD CONSTRAINT [fk_AddressDimCounty] FOREIGN KEY ([DimCountryId]) REFERENCES [RVRS].[DimCounty] ([DimCountyID])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[Address]') and name ='fk_AddressDimState')
	ALTER TABLE [RVRS].[Address] ADD CONSTRAINT [fk_AddressDimState] FOREIGN KEY ([DimStateId]) REFERENCES [RVRS].[DimState] ([DimStateID])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[Address]') and name ='fk_AddressDimCity')
	ALTER TABLE [RVRS].[Address] ADD CONSTRAINT [fk_AddressDimCity] FOREIGN KEY ([DimCityId]) REFERENCES [RVRS].[DimCity] ([DimCityId])
GO
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[Address]') and name ='fk_AddressDimStreetDesig')
	ALTER TABLE [RVRS].[Address] ADD CONSTRAINT [fk_AddressDimStreetDesig] FOREIGN KEY ([DimStreetDesigId]) REFERENCES [RVRS].[DimStreetDesig] ([DimStreetDesigID])

	-- DimState 

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[DimState]') and name ='fk_DimStateDimCountry')
	ALTER TABLE [RVRS].[DimState] ADD CONSTRAINT [fk_DimStateDimCountry] FOREIGN KEY ([DimCountryId]) REFERENCES [RVRS].[DimCountry] ([DimCountryId])


	-- DimCounty 
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[DimCounty]') and name ='fk_DimCountyDimCountry')
	ALTER TABLE [RVRS].[DimCounty] ADD CONSTRAINT [fk_DimCountyDimCountry] FOREIGN KEY ([DimCountryId]) REFERENCES [RVRS].[DimCountry] ([DimCountryId])
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[DimCounty]') and name ='fk_DimCountyDimState')
	ALTER TABLE [RVRS].[DimCounty] ADD CONSTRAINT [fk_DimCountyDimState] FOREIGN KEY ([DimStateId]) REFERENCES [RVRS].[DimState] ([DimStateID])

	-- DimCity 
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[DimCity]') and name ='fk_DimCityDimCountry')
	ALTER TABLE [RVRS].[DimCity] ADD CONSTRAINT [fk_DimCityDimCountry] FOREIGN KEY ([DimCountryId]) REFERENCES [RVRS].[DimCountry] ([DimCountryId])
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[DimCity]') and name ='fk_DimCityDimState')
	ALTER TABLE [RVRS].[DimCity] ADD CONSTRAINT [fk_DimCityDimState] FOREIGN KEY ([DimStateId]) REFERENCES [RVRS].[DimState] ([DimStateID])

	IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys  
                WHERE parent_object_id = OBJECT_ID('[RVRS].[DimCity]') and name ='fk_DimCityDimCounty')
	ALTER TABLE [RVRS].[DimCity] ADD CONSTRAINT [fk_DimCityDimCounty] FOREIGN KEY ([DimCountryId]) REFERENCES [RVRS].[DimCounty] ([DimCountyID])
GO
