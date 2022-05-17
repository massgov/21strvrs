--drop table [RVRS].[DimPhysicianLocation]
-- sp_help '[RVRS].[DimPhysicianLocation]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimPhysicianLocation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimPhysicianLocation](
			[DimPhysicianLocationId] INT NOT NULL IDENTITY (1,1),
			[DimPhysicianId] TINYINT NOT NULL CONSTRAINT [df_DimPhysicianLocationDimPhysicianId] DEFAULT (0),
			[DimLocationId] TINYINT NOT NULL CONSTRAINT [df_DimPhysicianLocationDimLocationId] DEFAULT (0),--PH_LOCATION
			[DimFacilityLocationId] TINYINT NOT NULL CONSTRAINT [df_DimPhysicianLocationDimFacilityLocationId] DEFAULT (0),--PH_FAC_LOCATION_ID
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimPhysicianLocationVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimPhysicianLocationId] PRIMARY KEY CLUSTERED 
		(
			[DimPhysicianLocationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


