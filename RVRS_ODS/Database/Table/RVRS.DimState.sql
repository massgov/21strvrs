-- drop table [RVRS].[DimState]
-- sp_help  '[RVRS].[DimState]'
-- select * from [RVRS].[DimState]
---alter table [RVRS].[DimState] ADD ValueSet VARCHAR(512)  
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimState]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimState](
			[DimStateId] INT NOT NULL IDENTITY (1,1),
			[BkStateId] INT NOT NULL,
			[DimCountryId] INT NOT NULL CONSTRAINT [df_DimStateDimCountryId]  DEFAULT ((0)),
			[NchsCode] VARCHAR(2) NULL,
			[FipsCode] VARCHAR(3) NULL,
			[AlphaFipsCode] VARCHAR(3)  NULL,
			[Code] VARCHAR(3)  NULL,
			[StateDesc] VARCHAR(128) NOT NULL,   --name 
			ValueSet VARCHAR(512),  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL -- CONSTRAINT [df_DimStateSrcVoid]  DEFAULT ((1)), -- void
		CONSTRAINT [pk_DimStateId] PRIMARY KEY CLUSTERED 
		(
			[DimStateID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


