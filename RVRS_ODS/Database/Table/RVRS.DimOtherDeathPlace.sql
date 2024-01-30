--drop table [RVRS].[DimOtherDeathPlace]
-- sp_help '[RVRS].[DimOtherDeathPlace]'

--
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOtherDeathPlace]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOtherDeathPlace](
			[DimOtherDeathPlaceId] INT NOT NULL IDENTITY (1,1),	
			[BkOtherDeathPlaceId] INT NOT NULL,
			[OtherDeathPlaceDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimOtherDeathPlaceVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimOtherDeathPlaceId] PRIMARY KEY CLUSTERED 
		(
			[DimOtherDeathPlaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


