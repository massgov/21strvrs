--drop table [RVRS].[DimDispMethod]
-- sp_help '[RVRS].[DimDispMethod]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDispMethod]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDispMethod](
			[DimDispMethodId] INT NOT NULL IDENTITY (1,1),	
			[BkDispMethodId] INT NOT NULL,
			[DispMethodDesc] VARCHAR(128) NOT NULL, 
			[Abbr] VARCHAR(16) NOT NULL,
			[Code] DECIMAL(2,0) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimDispMethodId] PRIMARY KEY CLUSTERED 
		(
			[DimDispMethodId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


