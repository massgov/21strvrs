--drop table [RVRS].[DimPregnancyStatus]
-- sp_help '[RVRS].[DimPregnancyStatus]'
-- select * from [RVRS].[DimPregnancyStatus]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimPregnancyStatus]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimPregnancyStatus](
			[DimPregnancyStatusId] INT NOT NULL IDENTITY (1,1),	
			[BkPregnancyStatusId] INT NOT NULL,
			[PregnancyStatusDesc] VARCHAR(128) NOT NULL,  
			[Code] VARCHAR(8) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimPregnancyStatusId] PRIMARY KEY CLUSTERED 
		(
			[DimPregnancyStatusId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


