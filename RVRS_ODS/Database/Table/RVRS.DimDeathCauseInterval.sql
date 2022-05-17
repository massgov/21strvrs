--drop table [RVRS].[DimDeathCauseInterval]
--sp_help '[RVRS].[DimDeathCauseInterval]'



SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDeathCauseInterval]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDeathCauseInterval](
			[DimDeathCauseIntervalId] INT NOT NULL IDENTITY (1,1),	
			[BkCityId] INT NOT NULL,
			[DeathCauseIntervalDesc] VARCHAR(128) NOT NULL,  			
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT  NOT NULL DEFAULT (0), 		
		CONSTRAINT [pk_DimDeathCauseIntervalId] PRIMARY KEY CLUSTERED 
		(
			[DimDeathCauseIntervalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


