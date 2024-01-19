--drop table [RVRS].[DimNioshIndustry]
--sp_help  '[RVRS].[DimNioshIndustry]'
--select * from [RVRS].[DimNioshIndustry]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimNNioshIndustry]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimNioshIndustry](
			[DimNioshIndustryId] INT NOT NULL IDENTITY (1,1),	
			[BkNioshIndustryId] INT NOT NULL,
		    [NioshIndustryDesc] VARCHAR(128) NOT NULL, --Census Occ Title
			[CensusTitle] VARCHAR(128) NOT NULL, --Census Occ Title
			[Code] VARCHAR(8) NULL, --Census Occ Title
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimNioshIndustryVoid] DEFAULT (0), 
		CONSTRAINT [pk_DimNioshIndustryId] PRIMARY KEY CLUSTERED 
		(
			[DimNioshIndustryId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

