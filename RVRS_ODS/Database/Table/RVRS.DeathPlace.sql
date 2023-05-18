--drop table [RVRS].[DeathPlace]
--sp_help '[RVRS].[DeathPlace]'
--select * from [RVRS].[DeathPlace]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathPlace]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathPlace] (  
		   [DeathPlaceId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column 		
		   [DimDeathPlaceId] INT NOT NULL CONSTRAINT [df_DeathPlaceDimDeathPlaceId] DEFAULT (0), --DPLACE,		   [
		   [DimDeathFacilityId] INT NOT NULL CONSTRAINT [df_DeathPlaceDimDeathFacilityId] DEFAULT (0), --DHOSPITALL
		   [DimOtherDeathPlaceId] INT NOT NULL CONSTRAINT [df_DeathPlaceDimOtherDeathPlaceId] DEFAULT (0), --DPLACE_OTHR	
		   [DeathFacilityCode] VARCHAR(16) NULL, --DFACILITYL
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathPlaceCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathPlaceId] PRIMARY KEY CLUSTERED 
		(
			[DeathPlaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 