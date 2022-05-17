--drop table [RVRS].[DimInjuryTransportOther]
-- sp_help '[RVRS].[DimInjuryTransportOther]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimInjuryTransportOther]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimInjuryTransportOther](
			[DimInjuryTransportOtherId] INT NOT NULL IDENTITY (1,1),	
			[BkInjuryTransportOtherId] INT NOT NULL,
			[InjuryTransportOtherDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimInjuryTransportOtherVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimInjuryTransportOtherId] PRIMARY KEY CLUSTERED 
		(
			[DimInjuryTransportOtherId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


