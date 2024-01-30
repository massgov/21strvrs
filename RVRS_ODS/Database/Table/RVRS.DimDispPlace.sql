--drop table [RVRS].[DimDispPlace]
-- sp_help '[RVRS].[DimDispPlace]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDispPlace]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDispPlace](
			[DimDispPlaceId] INT NOT NULL IDENTITY (1,1),	
			[BkDispPlaceId] INT NOT NULL,
			[DispPlaceDesc] VARCHAR(128) NOT NULL,  --DISP_NME
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 			
		CONSTRAINT [pk_DimDispPlaceId] PRIMARY KEY CLUSTERED 
		(
			[DimDispPlaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


