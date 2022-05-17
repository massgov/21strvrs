--drop table [RVRS].[DimDeathFacility]
-- sp_help '[RVRS].[DimDeathFacility]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDeathFacility]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDeathFacility](
			[DimDeathFacilityId] INT NOT NULL IDENTITY (1,1),	
			[BkDeathFacilityId] INT NOT NULL,
			[DeathFacilityDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimDeathFacilityVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimDeathFacilityId] PRIMARY KEY CLUSTERED 
		(
			[DimDeathFacilityId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


