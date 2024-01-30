--drop table [RVRS].[DimOtherInformantRelation]
-- sp_help '[RVRS].[DimOtherInformantRelation]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOtherInformantRelation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOtherInformantRelation](
			[DimOtherInformantRelationId] INT NOT NULL IDENTITY (1,1),	
			[BkOtherInformantRelationId] INT NOT NULL,
			[OtherInformantRelationDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimOtherInformantRelationId] PRIMARY KEY CLUSTERED 
		(
			[DimOtherInformantRelationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


