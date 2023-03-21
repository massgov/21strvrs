--drop table [RVRS].[DimEventDateTypeInternal]
-- sp_help '[RVRS].[DimEventDateTypeInternal]'
-- use rvrs_testdb
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimEventDateTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimEventDateTypeInternal](
			[DimEventDateTypeInternalId] INT NOT NULL IDENTITY (1,1),			
			[EventDateTypeInternalDesc] VARCHAR(128) NOT NULL,  
			[Void] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimEventDateTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimEventDateTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


