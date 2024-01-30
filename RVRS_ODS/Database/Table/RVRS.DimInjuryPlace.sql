--drop table [RVRS].[DimInjuryPlace]
-- sp_help '[RVRS].[DimInjuryPlace]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimInjuryPlace]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimInjuryPlace](
			[DimInjuryPlaceId] INT NOT NULL IDENTITY (1,1),	
			[BkInjuryPlaceId] INT NOT NULL,
			[InjuryPlaceDesc] VARCHAR(128) NOT NULL,  
			[Code] VARCHAR(8) NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimInjuryPlaceVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimInjuryPlaceId] PRIMARY KEY CLUSTERED 
		(
			[DimInjuryPlaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


