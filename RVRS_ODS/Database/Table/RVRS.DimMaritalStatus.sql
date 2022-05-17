--drop table [RVRS].[DimMaritalStatus]
--sp_help '[RVRS].[DimMaritalStatus]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimMaritalStatus]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimMaritalStatus](
			[DimMaritalStatusId] INT NOT NULL IDENTITY (1,1),
			[BkMaritalStatusId] INT NOT NULL ,
		    [MaritalStatusDesc] VARCHAR(128) NOT NULL,		
			[Abbr] VARCHAR(16) NULL,
			[Code] TINYINT NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimMaritalStatusId] PRIMARY KEY CLUSTERED 
		(
			[DimMaritalStatusId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

