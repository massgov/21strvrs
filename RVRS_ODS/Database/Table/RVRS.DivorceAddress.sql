-- drop table [RVRS].[DivorceAddress]
-- sp_help '[RVRS].[DivorceAddress]'
-- select * from [RVRS].[DivorceAddress]
-- use RVRS_testdb
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DivorceAddress]') )
	BEGIN 
		CREATE TABLE [RVRS].[DivorceAddress] (  
		   [DivorceAddressId] BIGINT NOT NULL IDENTITY (1,1), 
		   [DivorceEventId] BIGINT NOT NULL,  --  FK of Event
		   [EventPersonId] BIGINT NOT NULL, 	 -- FK of EventPerson 	  
		   [DimAddressTypeInternalId] INT NOT NULL  CONSTRAINT [df_DivorceAddressDimAddressTypeInternalId]  DEFAULT ((0)) , --
		   [StreetNumber] VARCHAR(8) NULL,	--aparty_strnum,bparty_strnum   
		   [StreetName] VARCHAR(128) NULL,	--aparty_strname,bparty_strname
		   [DimCityId] INT NOT NULL CONSTRAINT [df_DivorceAddressDimCityId]  DEFAULT ((0)),	 --aparty_city, aparty_citycode_id,bparty_city,bparty_citycode_id		  
		   [DimCountryId] INT NOT NULL CONSTRAINT [df_DivorceAddressDimCountryId]  DEFAULT ((0)),
		   [DimStateId] INT NOT NULL CONSTRAINT [df_DivorceAddressDimStateId]  DEFAULT ((0)),  --her_residence_state,her_state_code_id,his_residence_state,his_state_code_id,aparty_state,aparty_statecode_id,bparty_state,bparty_statecode_id,mar_state,mar_state_code_id
		   [DimZipCodeId] INT NOT NULL CONSTRAINT [df_DivorceAddressDimZipCodeId]  DEFAULT ((0)), --aparty_zip, bparty_zip	
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DivorceAddressCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DivorceAddressId] PRIMARY KEY CLUSTERED 
		(
			[DivorceAddressID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 
GO











