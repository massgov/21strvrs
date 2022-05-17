--drop table [RVRS].[DimWarOther]
-- sp_help '[RVRS].[DimWarOther]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimWarOther]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimWarOther](
			[DimWarOtherId] INT NOT NULL IDENTITY (1,1),	
			[BkCityId] INT NOT NULL,
			[WarOtherDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimWarOtherId] PRIMARY KEY CLUSTERED 
		(
			[DimWarOtherId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


