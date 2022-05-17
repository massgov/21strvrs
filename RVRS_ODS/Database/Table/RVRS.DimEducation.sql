--drop table [RVRS].[DimEducation]
--sp_help  '[RVRS].[DimEducation]'
--select * from [RVRS].[DimEducation]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimEducation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimEducation](
			[DimEducationId] INT NOT NULL IDENTITY (1,1),	
			[BkEducationId] INT NOT NULL,
		    [EducationDesc] VARCHAR(128) NOT NULL,
			[Code] TINYINT NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimEducationId] PRIMARY KEY CLUSTERED 
		(
			[DimEducationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

