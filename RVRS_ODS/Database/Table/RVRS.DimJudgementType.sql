--drop table [RVRS].[DimJudgementType]
-- sp_help '[RVRS].[DimJudgementType]'
-- use rvrs_testdb
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimJudgementType]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimJudgementType](
			[DimJudgementTypeId] INT NOT NULL IDENTITY (1,1),	
			[BkJudgementTypeId] INT NOT NULL,
			[JudgementTypeDesc] VARCHAR(128) NOT NULL, 
			[Code] VARCHAR(8) NOT NULL, 
			[ValueSet] VARCHAR(512) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimJudgementTypeVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimJudgementTypeId] PRIMARY KEY CLUSTERED 
		(
			[DimJudgementTypeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


