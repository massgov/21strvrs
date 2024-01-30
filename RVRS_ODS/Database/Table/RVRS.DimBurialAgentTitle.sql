--drop table [RVRS].[DimBurialAgentTitle]
-- sp_help '[RVRS].[DimBurialAgentTitle]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimBurialAgentTitle]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimBurialAgentTitle](
			[DimBurialAgentTitleId] INT NOT NULL IDENTITY (1,1),	
			[BkBurialAgentTitleId] INT NOT NULL,
			[BurialAgentTitleDesc] [varchar](128) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimBurialAgentTitleId] PRIMARY KEY CLUSTERED 
		(
			[DimBurialAgentTitleId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


