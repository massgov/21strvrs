--drop table [RVRS].[DimHcProviderTypeInternal]
-- sp_help '[RVRS].[DimHcProviderTypeInternal]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimHcProviderTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimHcProviderTypeInternal](
			[DimHcProviderTypeInternalId] INT NOT NULL IDENTITY (1,1),
			[HcProviderTypeInternalDesc] VARCHAR(128) NOT NULL,  
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimHcProviderTypeInternalVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimHcProviderTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimHcProviderTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


