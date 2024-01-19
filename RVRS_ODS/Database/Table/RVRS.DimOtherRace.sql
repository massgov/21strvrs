--drop table [RVRS].[DimOtherRace]
-- sp_help '[RVRS].[DimOtherRace]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOtherRace]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOtherRace](
			[DimOtherRaceId] INT NOT NULL IDENTITY (1,1),	
			[BkOtherRaceId] INT NOT NULL,
			[OtherRaceDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[Void] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimOtherRaceId] PRIMARY KEY CLUSTERED 
		(
			[DimOtherRaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


