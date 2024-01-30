--drop table [RVRS].[DimSourceInternal]
-- sp_help '[RVRS].[DimSourceInternal]'
-- sp_rename column 'SourceDesc', 'SourceInternalDesc'
---sp_rename 'rvrs.DimSourceInternal.SourceDesc', 'SourceInternalDesc', 'Column'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimSourceInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimSourceInternal](
			[DimSourceInternalId] INT NOT NULL IDENTITY (1,1),			
			[SourceInternalDesc] VARCHAR(128) NOT NULL,  --GENERAL,OCCURRENCE,RESIDENCE,STATE 
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimSourceInternalVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimSourceInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimSourceInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


