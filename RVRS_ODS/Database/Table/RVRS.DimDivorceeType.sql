--drop table [RVRS].[DimDivorceeType]
-- sp_help '[RVRS].[DimDivorceeType]'
-- use RVRS_testdb
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDivorceeType]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDivorceeType](
			[DimDivorceeTypeId] INT NOT NULL IDENTITY (1,1),	
			[BkDivorceeTypeId] INT NOT NULL,
			[DivorceeTypeDesc] VARCHAR(128) NOT NULL, 
			[Code] VARCHAR(8) NOT NULL,
			[ValueSet] VARCHAR(512) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimDivorceeTypeVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimDivorceeTypeId] PRIMARY KEY CLUSTERED 
		(
			[DimDivorceeTypeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


