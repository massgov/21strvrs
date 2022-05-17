--drop table [RVRS].[DimDeathManner]
-- sp_help '[RVRS].[DimDeathManner]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDeathManner]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDeathManner](
			[DimDeathMannerId] INT NOT NULL IDENTITY (1,1),	
			[BkDeathMannerId] INT NOT NULL,
			[DeathMannerDesc] VARCHAR(128) NOT NULL, 
			[Abbr] VARCHAR(16) NULL, --Abbr
			[Code] DECIMAL (5,0),
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimDeathMannerId] PRIMARY KEY CLUSTERED 
		(
			[DimDeathMannerId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


