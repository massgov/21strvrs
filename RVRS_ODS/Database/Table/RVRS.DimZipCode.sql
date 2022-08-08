--drop table [RVRS].[DimZipCode]
-- sp_help '[RVRS].[DimZipCode]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimZipCode]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimZipCode](
			[DimZipCodeId] INT NOT NULL IDENTITY (1,1),	
			[BkZipCodeId] INT NOT NULL,
			[DimCityId] INT NOT NULL CONSTRAINT [df_DimZipCodeDimCityId] DEFAULT ((0)),		
			[ZipCodeDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimZipCodeId] PRIMARY KEY CLUSTERED 
		(
			[DimZipCodeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


