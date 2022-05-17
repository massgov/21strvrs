--drop table [RVRS].[DimInformantRelationOther]
--sp_help '[RVRS].[DimInformantRelationOther]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimInformantRelationOther]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimInformantRelationOther](
			[DimInformantRelationOtherId] INT NOT NULL,	
			[BkInformantRelationOtherId] INT NOT NULL, 
			[DimInformantRelationId] INT NOT NULL CONSTRAINT [df_DimInformantRelationOtherDimInformantRelationId] DEFAULT (0), --INFO_RELATION
			[InformantRelationOtherDesc] VARCHAR(128) NOT NULL,
			[Code] CHAR(1) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimInformantRelationOtherVoid] DEFAULT (0),
		CONSTRAINT [pk_DimInformantRelationOtherId] PRIMARY KEY CLUSTERED 
		(
			[DimInformantRelationOtherId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

