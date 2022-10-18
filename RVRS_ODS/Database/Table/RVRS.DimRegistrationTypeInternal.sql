--drop table [RVRS].[DimRegistrarTypeInternal]
-- sp_help '[RVRS].[DimRegistrarTypeInternal]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimRegistrarTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimRegistrarTypeInternal](
			[DimRegistrarTypeInternalId] INT NOT NULL IDENTITY (1,1),			
			[RegistrarTypeInternalDesc] VARCHAR(128) NOT NULL,  --GENERAL,OCCURRENCE,RESIDENCE,STATE 
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimRegistrarTypeInternalVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimRegistrarTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimRegistrarTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


