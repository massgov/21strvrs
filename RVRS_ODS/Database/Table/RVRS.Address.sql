-- drop table [RVRS].[Address]
-- sp_help '[RVRS].[Address]'
-- select * from [RVRS].[Address]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Address]') )
	BEGIN 
		CREATE TABLE [RVRS].[Address] (  
		   [AddressId] BIGINT NOT NULL IDENTITY (1,1), 
		   [PersonId] BIGINT NULL, 		  
		   [DimAddressTypeId] INT NOT NULL  CONSTRAINT [df_AddressDimAddressTypeId]  DEFAULT ((0)) , --seed
		   [DimPrefixId] INT NOT NULL CONSTRAINT [df_AddressDimPrefixId]  DEFAULT ((0)),
		   [StreetNumber] INT NULL,		   
		   [StreetName] VARCHAR(128) NULL,	
		   [DimStreetDesigId] INT NOT NULL CONSTRAINT [df_AddressDimStreetDesigId]  DEFAULT ((0)), ---StreetDesignator	
		   [DimSuffixId] INT NOT NULL CONSTRAINT [df_AddressDimSuffixId]  DEFAULT ((0)),
		   [AptOrUnitNumber] VARCHAR(16) NULL, --e.g RES_ADDR2
		   [DimCityId] INT NOT NULL CONSTRAINT [df_AddressDimCityId]  DEFAULT ((0)),			  
		   [DimCountyId] INT NOT NULL CONSTRAINT [df_AddressDimCountyId]  DEFAULT ((0)),
		   [DimStateId] INT NOT NULL CONSTRAINT [df_AddressDimStateId]  DEFAULT ((0)), 
		   [DimZipCodeId] INT NOT NULL CONSTRAINT [df_AddressDimZipCodeId]  DEFAULT ((0)),   
		   [DimCountryId] INT NOT NULL CONSTRAINT [df_AddressDimCountryId]  DEFAULT ((0)),  --cd 		   
		   [IsInSideCityLimits] INT NOT NULL CONSTRAINT [df_AddressIsInSideCityLimits]  DEFAULT ((0)),	   
		   [PoBox] VARCHAR(128) NULL,
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_AddressCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_AddressId] PRIMARY KEY CLUSTERED 
		(
			[AddressID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 
GO











