--drop table [RVRS].[DimIndustry]
--sp_help  '[RVRS].[DimIndustry]'
--select * from [RVRS].[DimIndustry]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimIndustry]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimIndustry](
			[DimIndustryId] INT NOT NULL IDENTITY (1,1),	
			[BkTimeIndId] INT NOT NULL,
		    [IndustryDesc] VARCHAR(128) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimIndustryVoid] DEFAULT (0), 
		CONSTRAINT [pk_DimIndustryId] PRIMARY KEY CLUSTERED 
		(
			[DimIndustryId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

