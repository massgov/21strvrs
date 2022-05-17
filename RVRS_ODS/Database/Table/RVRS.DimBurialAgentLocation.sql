--drop table [RVRS].[DimBurialAgentLocation]
-- sp_help '[RVRS].[DimBurialAgentLocation]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimBurialAgentLocation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimBurialAgentLocation](
			[DimBurialAgentLocationId] INT NOT NULL IDENTITY (1,1),	
			[DimBurialAgentId]INT NOT NULL CONSTRAINT [df_DimBurialAgentLocationDimBurialAgentId] DEFAULT (0),
			[DimLocationId]INT NOT NULL CONSTRAINT [df_DimBurialAgentLocationDimLocationId] DEFAULT (0),--AGENT_SEC_LOC_ID
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimBurialAgentLocationVoid] DEFAULT (0),
		CONSTRAINT [pk_DimBurialAgentLocationId] PRIMARY KEY CLUSTERED 
		(
			[DimBurialAgentLocationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


