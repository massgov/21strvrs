--drop table [RVRS].[DimTimeInd]
--sp_help  '[RVRS].[DimTimeInd]'
--select * from [RVRS].[DimTimeInd]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimTimeInd]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimTimeInd](
			[DimTimeIndId] INT NOT NULL IDENTITY (1,1),	
			[BkTimeIndId] INT NOT NULL,
		    [TimeIndDesc] VARCHAR(128) NOT NULL,
			[Abbr] VARCHAR(16) NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimTimeIndId] PRIMARY KEY CLUSTERED 
		(
			[DimTimeIndId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

