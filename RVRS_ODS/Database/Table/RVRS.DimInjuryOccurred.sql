--drop table [RVRS].[DimInjuryOccurred]
-- sp_help '[RVRS].[DimInjuryOccurred]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimInjuryOccurred]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimInjuryOccurred](
			[DimInjuryOccurredId] INT NOT NULL IDENTITY (1,1),	
			[BkInjuryOccurredId] INT NOT NULL,
			[InjuryOccurredDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimInjuryOccurredVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimInjuryOccurredId] PRIMARY KEY CLUSTERED 
		(
			[DimInjuryOccurredId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


