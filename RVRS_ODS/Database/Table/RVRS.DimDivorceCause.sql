--drop table [RVRS].[DimDivorceCause]
-- sp_help '[RVRS].[DimDivorceCause]'
-- use rvrs_testdb
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDivorceCause]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDivorceCause](
			[DimDivorceCauseId] INT NOT NULL IDENTITY (1,1),	
			[BkDivorceCauseId] INT NOT NULL,
			[DivorceCauseDesc] VARCHAR(128) NOT NULL, 			
			[Code] VARCHAR(8) NOT NULL, 
			[ValueSet] VARCHAR(512) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimDivorceCauseVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimDivorceCauseId] PRIMARY KEY CLUSTERED 
		(
			[DimDivorceCauseId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


