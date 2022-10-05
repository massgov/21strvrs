--drop table [RVRS].[DimDeathCauseUnit]
--sp_help '[RVRS].[DimDeathCauseUnit]'



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDeathCauseUnit]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDeathCauseUnit](
			[DimDeathCauseUnitId] INT NOT NULL IDENTITY (1,1),	
			[BkDeathCauseUnitId] INT NOT NULL,
			[DeathCauseUnitDesc] VARCHAR(128) NOT NULL,  	
			[Abbr] VARCHAR(16) NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, 		
		CONSTRAINT [pk_DimDeathCauseUnitId] PRIMARY KEY CLUSTERED 
		(
			[DimDeathCauseUnitId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


