--drop table [RVRS].[DimLevel]
-- sp_help '[RVRS].[DimLevel]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimLevel]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimLevel](
			[DimLevelId] INT NOT NULL IDENTITY (1,1),	
			[BkLevelId] INT NOT NULL,
			[DimParentLevelDimId] INT NULL,  			
			[LevelDesc] VARCHAR(128) NOT NULL,
			[Position] INT NOT NULL, 
			[Comment] VARCHAR(256) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,				
		CONSTRAINT [pk_DimLevelId] PRIMARY KEY CLUSTERED 
		(
			[DimLevelId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


