--drop table [RVRS].[DimRace]
-- sp_help '[RVRS].[DimRace]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimRace]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimRace](
			[DimRaceId] INT NOT NULL IDENTITY (1,1),	
			[BkRaceId] INT NOT NULL,
			[RaceDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimRaceId] PRIMARY KEY CLUSTERED 
		(
			[DimRaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


