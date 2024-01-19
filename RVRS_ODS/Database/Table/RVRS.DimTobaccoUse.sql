--drop table [RVRS].[DimTobaccoUse]
-- sp_help '[RVRS].[DimTobaccoUse]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimTobaccoUse]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimTobaccoUse](
			[DimTobaccoUseId] INT NOT NULL IDENTITY (1,1),	
			[BkTobaccoUseId] INT NOT NULL,
			[TobaccoUseDesc] VARCHAR(128) NOT NULL,  
			[Code] VARCHAR(8) NOT NULL,  
			[Abbr] VARCHAR(8) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimTobaccoUseId] PRIMARY KEY CLUSTERED 
		(
			[DimTobaccoUseId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


