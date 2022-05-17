--drop table [RVRS].[DimDeathPlaceOther]
-- sp_help '[RVRS].[DimDeathPlaceOther]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDeathPlaceOther]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDeathPlaceOther](
			[DimDeathPlaceOtherId] INT NOT NULL IDENTITY (1,1),	
			[BkDeathPlaceOtherId] INT NOT NULL,
			[DeathPlaceOtherDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimDeathPlaceOtherVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimDeathPlaceOtherId] PRIMARY KEY CLUSTERED 
		(
			[DimDeathPlaceOtherId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


