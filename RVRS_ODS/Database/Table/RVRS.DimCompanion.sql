--drop table [RVRS].[DimCompanion]
-- sp_help '[RVRS].[DimCompanion]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimCompanion]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimCompanion](
			[DimCompanionId] INT NOT NULL IDENTITY (1,1),	
			[BkCompanionId] INT NOT NULL,
			[CompanionDesc] VARCHAR(128) NOT NULL,  
			[Abbr] VARCHAR(16) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimCompanionId] PRIMARY KEY CLUSTERED 
		(
			[DimCompanionId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


