--drop table [RVRS].[DimHcProviderTitle]
-- sp_help '[RVRS].[DimHcProviderTitle]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimHcProviderTitle]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimHcProviderTitle](
			[DimHcProviderTitleId] INT NOT NULL IDENTITY (1,1),	
			[BkHcProviderTitleId] INT NOT NULL,
			[HcProviderTitleDesc] VARCHAR(128) NOT NULL,  
			[Code] DECIMAL(2,0) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimHcProviderTitleId] PRIMARY KEY CLUSTERED 
		(
			[DimHcProviderTitleId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


