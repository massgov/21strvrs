--drop table [RVRS].[DimInjuryTransport]
-- sp_help '[RVRS].[DimInjuryTransport]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimInjuryTransport]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimInjuryTransport](
			[DimInjuryTransportId] INT NOT NULL IDENTITY (1,1),	
			[BkInjuryTransportId] INT NOT NULL,
			[InjuryTransportDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimInjuryTransportId] PRIMARY KEY CLUSTERED 
		(
			[DimInjuryTransportId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


