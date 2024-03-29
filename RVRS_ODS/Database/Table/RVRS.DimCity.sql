--drop table [RVRS].[DimCity]
-- sp_help '[RVRS].[DimCity]'
-- select * from [RVRS].[DimCity]
--alter table [RVRS].[DimCity] ADD ValueSet VARCHAR(512)  
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimCity]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimCity](
			[DimCityId] INT NOT NULL IDENTITY (1,1),	
			[BkCityId] INT NOT NULL,
			[DimCountyId] INT NOT NULL CONSTRAINT [df_DimStateDimCountyId]  DEFAULT ((0)),
			[Code] VARCHAR(8) NULL,
			[FipsCode] VARCHAR(8) NULL,
			[CityDesc] VARCHAR(128) NOT NULL,  
			ValueSet VARCHAR(512),
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimCityId] PRIMARY KEY CLUSTERED 
		(
			[DimCityId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


