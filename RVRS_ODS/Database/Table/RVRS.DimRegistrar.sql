--drop table [RVRS].[DimRegistrar]
-- sp_help '[RVRS].[DimRegistrar]'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimRegistrar]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimRegistrar](
			[DimRegistrarId] INT NOT NULL IDENTITY (1,1),	
			[BkRegistrarId] INT NOT NULL,
			[RegistrarDesc] VARCHAR(128) NOT NULL,  --NAME CLERK_FIRST_NAME + ' ' + CLERK_MIDDLE_NAME + ' ' + CLERK_LAST_NAME
			[FirstName] VARCHAR(128), --CLERK_FIRST_NAME
			[MiddleName] VARCHAR(128), --CLERK_MIDDLE_NAME
			[LastName] VARCHAR(128), --CLERK_LAST_NAME
			[DimSuffixId]INT NOT NULL CONSTRAINT [df_DimRegistrarDimSuffixId] DEFAULT (0),--CLERK_SUFFIX			
			[Title] VARCHAR(32) NULL, --CLERK_TITLE	
			[DimCityId] INT NOT NULL CONSTRAINT [df_DimRegistrarDimCityId] DEFAULT (0),  --CLERK_CITY		
			[DimCountyId] INT NOT NULL CONSTRAINT [df_DimRegistrarDimCountyId] DEFAULT (0),  --CLERK_CITY
			[DimStateId] INT NOT NULL CONSTRAINT [df_DimRegistrarDimStateId] DEFAULT (0),  --CLERK_STATE	
			[DimLocationId] INT NOT NULL CONSTRAINT [df_DimRegistrarDimLocationId] DEFAULT (0), --CLERK_SEC_LOC_ID
			[IsCurrent] VARCHAR(2) NULL, --CLERK_CURRENT	
			[RegistrarType] VARCHAR(32) NOT NULL , --STATE, TOWN CLERK
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimRegistrarId] PRIMARY KEY CLUSTERED 
		(
			[DimRegistrarId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


