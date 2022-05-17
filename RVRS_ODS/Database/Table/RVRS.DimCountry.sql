--drop table [RVRS].[DimCountry]
--sp_help '[RVRS].[DimCountry]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimCountry]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimCountry](
			[DimCountryId] INT NOT NULL IDENTITY (1,1),
			[BkCountryId] INT NOT NULL,
			[Code] VARCHAR(2),
			[FipsCode] VARCHAR(3) NULL,	
			[NchsCode] TINYINT NULL,
			[CountryDesc] VARCHAR(128) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, -- Set it by source  CONSTRAINT [df_DimCountrySrcVoid]  DEFAULT ((0))
		CONSTRAINT [pk_DimCountryId] PRIMARY KEY CLUSTERED 
		(
			[DimCountryId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


