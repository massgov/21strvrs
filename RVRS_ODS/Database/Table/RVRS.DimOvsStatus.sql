--drop table [RVRS].[DimOvsStatus]
-- sp_help '[RVRS].[DimOvsStatus]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOvsStatus]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOvsStatus](
			[DimOvsStatusId] INT NOT NULL IDENTITY (1,1),	
			[BkOvsStatusId] INT NOT NULL,
			[OvsStatusDesc] VARCHAR(128) NOT NULL,  
			[Code] TINYINT NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimOvsStatusId] PRIMARY KEY CLUSTERED 
		(
			[DimOvsStatusId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


