--drop table [RVRS].[DimAutoPysPerformed]
--sp_help  '[RVRS].[DimAutoPysPerformed]'
--select * from [RVRS].[DimAutoPysPerformed]
--

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimAutoPysPerformed]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimAutoPysPerformed](
			[DimAutoPysPerformedId] INT NOT NULL IDENTITY (1,1),	
			[BkAutoPysPerformedId] INT NOT NULL,
		    [AutoPysPerformedDesc] VARCHAR(128) NOT NULL,
			[Abbr] VARCHAR(16) NULL,
			[Code] DECIMAL(2,0) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimAutoPysPerformedId] PRIMARY KEY CLUSTERED 
		(
			[DimAutoPysPerformedId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

