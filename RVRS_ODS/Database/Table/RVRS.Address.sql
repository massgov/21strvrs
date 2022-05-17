-- drop table [RVRS].[Address]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID([RVRS].[Address]) )
	BEGIN 
		CREATE TABLE [RVRS].[Address] (  
		   [AddressId] BIGINT NOT NULL IDENTITY (1,1), 
		   [PersonId] BIGINT NULL, 		  
		   [DimAddressTypeId] INT NOT NULL  CONSTRAINT [df_AddressDimAddressTypeId]  DEFAULT ((0)) , --seed
		   [DimCountryId] INT NOT NULL CONSTRAINT [df_AddressDimCountryId]  DEFAULT ((0)),  --cd 
		   [DimStateId] INT NOT NULL CONSTRAINT [df_AddressDimStateId]  DEFAULT ((0)),  
		   [DimCountyId] INT NOT NULL CONSTRAINT [df_AddressDimCountyId]  DEFAULT ((0)),
		   [DimCityId] INT NOT NULL CONSTRAINT [df_AddressDimCityId]  DEFAULT ((0)),		   
		   [DimStreetDesigId] INT NOT NULL CONSTRAINT [df_AddressDimStreetDesigId]  DEFAULT ((0)), ---StreetDesignator		 
		   [ZipCode] VARCHAR (10) NULL , 
		   [PoBox] VARCHAR(128) NULL,	
		   [StreetNumber] INT NULL,
		   [StreetName] VARCHAR(128) NULL,		  
		   [StreetDirection] VARCHAR(2) NULL,	
		   [StreetDirectionType] VARCHAR(16) NULL, -- value should be Suffix and Prefix 
		   [AptOrUnitNumber] INT NULL,
		   [IsInSideCityLimits] CHAR (1) CONSTRAINT [df_AddressIsInSideCityLimits]  DEFAULT ((Y))
		   --[Latitude] NUMERIC (17, 0) NULL,   
		   --[Longitude] NUMERIC (17, 0) NULL  -- RES_LONGITUDE  
		CONSTRAINT [pk_AddressId] PRIMARY KEY CLUSTERED 
		(
			[AddressID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 
GO











