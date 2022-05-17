--drop table [RVRS].[DimBurialAgent]
-- sp_help '[RVRS].[DimBurialAgent]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimBurialAgent]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimBurialAgent](
			[DimBurialAgentId] INT NOT NULL IDENTITY (1,1),	
			[BkBurialAgentId] INT NOT NULL,
			[Title] VARCHAR(64) NULL, --BURIAL_AGENT_TITLE
			[FirstName] VARCHAR(128), --BURIAL_AGENT_GNAME
			[MiddleName] VARCHAR(128), --BURIAL_AGENT_MNAME
			[LastName] VARCHAR(128), --BURIAL_AGENT_LNAME
			[DimSuffixId]INT NOT NULL CONSTRAINT [df_DimBurialAgentDimSuffixId] DEFAULT (0),--BURIAL_AGENT_SUFFIX
			[IsCurrent] VARCHAR(2) NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimBurialAgentId] PRIMARY KEY CLUSTERED 
		(
			[DimBurialAgentId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


