--drop table [RVRS].[DimFuneralHomeName]
-- sp_help '[RVRS].[DimFuneralHomeName]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimFuneralHomeName]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimFuneralHomeName](
			[DimFuneralHomeNameId] INT NOT NULL IDENTITY (1,1),	
			[BkFuneralHomeNameId] INT NOT NULL,
			[FuneralHomeNameDesc] [varchar](128) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimFuneralHomeNameId] PRIMARY KEY CLUSTERED 
		(
			[DimFuneralHomeNameId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


