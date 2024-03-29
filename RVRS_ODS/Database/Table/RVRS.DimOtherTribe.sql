--drop table [RVRS].[DimOtherTribe]
-- sp_help '[RVRS].[DimOtherTribe]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOtherTribe]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOtherTribe](
			[DimOtherTribeId] INT NOT NULL IDENTITY (1,1),	
			[BkOtherTribeId] INT NOT NULL,
			[OtherTribeDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[Void] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimOtherTribeId] PRIMARY KEY CLUSTERED 
		(
			[DimOtherTribeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


