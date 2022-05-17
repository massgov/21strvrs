--drop table [RVRS].[DimSourceInternal]
--sp_help '[RVRS].[DimSource]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimSourceInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimSourceInternal](
			[DimSourceInternalId] INT NOT NULL,		
		    [SourceDesc] VARCHAR(128) NOT NULL,		
			[SourceGuidCode] CHAR(2) NOT NULL,	
			[Void] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimSourceInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimSourceInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

