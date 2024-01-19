--drop table [RVRS].[DimNioshOccupation]
--sp_help  '[RVRS].[DimNioshOccupation]'
--select * from [RVRS].[DimNioshOccupation]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimNioshOccupation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimNioshOccupation](
			[DimNioshOccupationId] INT NOT NULL IDENTITY (1,1),	
			[BkNioshOccupationId] INT NOT NULL,
		    [NioshOccupationDesc] VARCHAR(128) NOT NULL,
			[CensusTitle] VARCHAR(128) NOT NULL, --Census Occ Title
			[Code] VARCHAR(8) NULL, --Census Occ Title
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimNioshOccupationVoid] DEFAULT (0), 
		CONSTRAINT [pk_DimNioshOccupationId] PRIMARY KEY CLUSTERED 
		(
			[DimNioshOccupationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

