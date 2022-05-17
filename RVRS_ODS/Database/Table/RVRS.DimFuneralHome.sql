--drop table [RVRS].[DimFuneralHome]
-- sp_help '[RVRS].[DimFuneralHome]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimFuneralHome]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimFuneralHome](
			[DimFuneralHomeId] INT NOT NULL IDENTITY (1,1),	
			[BkFuneralHomeId] INT NOT NULL,
			[FuneralHomeDesc] VARCHAR(128) NOT NULL,  
			[LicenseNumber] VARCHAR(16) NOT NULL,  
			[WayToContact] VARCHAR(64) NULL, 
			[ContactInfo] VARCHAR(64) NULL,  			 
			[CaseAccess] VARCHAR(16) NOT NULL,  
			[FaxNumber] VARCHAR(32) NOT NULL,  
			[PhoneNumber] VARCHAR(32) NOT NULL, 
			[DimLocationId] INT NOT NULL CONSTRAINT [df_DimFuneralHomeDimLocationId] DEFAULT (0), 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimFuneralHomeId] PRIMARY KEY CLUSTERED 
		(
			[DimFuneralHomeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


