--drop table [RVRS].[DimInformantRelation]
--sp_help '[RVRS].[DimInformantRelation]'
-- SELECT * FROM [RVRS].[DimInformantRelation]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimInformantRelation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimInformantRelation](
			[DimInformantRelationId] INT NOT NULL IDENTITY (1,1),	
			[BkInformantRelationId] INT NOT NULL, 
			[InformantRelationDesc] VARCHAR(128) NOT NULL,
			[Code] DECIMAL(2,0) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL,
		CONSTRAINT [pk_DimInformantRelationId] PRIMARY KEY CLUSTERED 
		(
			[DimInformantRelationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

