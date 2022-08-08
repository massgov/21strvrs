--drop table [RVRS].[DimIntentionalReject]
-- sp_help '[RVRS].[DimIntentionalReject]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimIntentionalReject]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimIntentionalReject](
			[DimIntentionalRejectId] INT NOT NULL IDENTITY (1,1),	
			[BkIntentionalRejectId] INT NOT NULL,
			[IntentionalRejectDesc] VARCHAR(128) NOT NULL,  
			[Code] DECIMAL(2,0) NOT NULL, 
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimIntentionalRejectId] PRIMARY KEY CLUSTERED 
		(
			[DimIntentionalRejectId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


