--drop table [RVRS].[DimSystemReject]
-- sp_help '[RVRS].[DimSystemReject]
--- SELECT * FROM [RVRS].[DimSystemReject]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimSystemReject]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimSystemReject](
			[DimSystemRejectId] INT NOT NULL IDENTITY (1,1),	
			[BkSystemRejectId] INT NOT NULL,
			[Code] VARCHAR(2) NOT NULL, 
			[SystemRejectDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimSystemRejectId] PRIMARY KEY CLUSTERED 
		(
			[DimSystemRejectId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


