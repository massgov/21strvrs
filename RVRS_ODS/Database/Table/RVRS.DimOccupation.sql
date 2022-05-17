--drop table [RVRS].[DimOccupation]
--sp_help  '[RVRS].[DimOccupation]'
--select * from [RVRS].[DimOccupation]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOccupation]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOccupation](
			[DimOccupationId] INT NOT NULL IDENTITY (1,1),	
			[BkTimeIndId] INT NOT NULL,
		    [OccupationDesc] VARCHAR(128) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimOccupationVoid] DEFAULT (0), 
		CONSTRAINT [pk_DimOccupationId] PRIMARY KEY CLUSTERED 
		(
			[DimOccupationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

