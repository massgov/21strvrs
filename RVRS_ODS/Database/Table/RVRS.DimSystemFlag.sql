--drop table [RVRS].[DimSystemFlag]
-- sp_help '[RVRS].[DimSystemFlag]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimSystemFlag]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimSystemFlag](
			[DimSystemFlagId] INT NOT NULL IDENTITY (1,1),	
			[BkSystemFlagId] INT NOT NULL,
			[SystemFlagDesc] VARCHAR(128) NOT NULL,  
			[GroupName] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimSystemFlagVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimSystemFlagId] PRIMARY KEY CLUSTERED 
		(
			[DimSystemFlagId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


