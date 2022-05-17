--drop table [RVRS_SECURITY].[DimLocation]
-- sp_help '[RVRS_SECURITY].[DimLocation]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS_SECURITY].[DimLocation]') )
	BEGIN 
		CREATE TABLE [RVRS_SECURITY].[DimLocation](
			[DimLocationId] INT NOT NULL IDENTITY (1,1),	
			[BkLocationId] INT NOT NULL,			
			[DimLevelId] INT NOT NULL CONSTRAINT [df_DimLocationDimLevelId] DEFAULT (0),					
			[DimParentLocationDimId] INT NULL,  
			[ExternalLocationId] INT NULL, 
			[LocationDesc] VARCHAR(128) NOT NULL,  		
			[Label] VARCHAR(128) NOT NULL,  	
			[Comment] VARCHAR(256) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,				
		CONSTRAINT [pk_DimLocationId] PRIMARY KEY CLUSTERED 
		(
			[DimLocationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


