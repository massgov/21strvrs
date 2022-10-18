--drop table [RVRS].[DimHcProviderContact]
-- sp_help '[RVRS].[DimHcProviderContact]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimHcProviderContact]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimHcProviderContact](
			[DimHcProviderContactId] INT NOT NULL IDENTITY (1,1),
			[BkHcProviderContactId] INT NOT NULL,
			[DimHcProviderId] TINYINT NOT NULL CONSTRAINT [df_DimHcProviderContactDimHcProviderId] DEFAULT (0),			
			[HcProviderContactDesc] VARCHAR(128) NOT NULL, --PH_WAY_2_CONTACT,PH_CONTACT_INFO
			[ContactType] VARCHAR(128) NOT NULL, --FAX, PHONE 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimHcProviderContactVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimHcProviderContactId] PRIMARY KEY CLUSTERED 
		(
			[DimHcProviderContactId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


