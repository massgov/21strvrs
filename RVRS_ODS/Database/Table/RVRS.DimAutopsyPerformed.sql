--drop table [RVRS].[DimAutopsyPerformed]
--sp_help  '[RVRS].[DimAutopsyPerformed]'
--select * from [RVRS].[DimAutopsyPerformed]
--

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimAutopsyPerformed]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimAutopsyPerformed](
			[DimAutopsyPerformedId] INT NOT NULL IDENTITY (1,1),	
			[BkAutopsyPerformedId] INT NOT NULL,
		    [AutopsyPerformedDesc] VARCHAR(128) NOT NULL,
			[Abbr] VARCHAR(16) NULL,			
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimAutopsyPerformedId] PRIMARY KEY CLUSTERED 
		(
			[DimAutopsyPerformedId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

