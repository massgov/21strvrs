--drop table [RVRS].[DimEmployer]
-- sp_help '[RVRS].[DimEmployer]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimEmployer]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimEmployer](
			[DimEmployerId] INT NOT NULL IDENTITY (1,1),	
			[BkEmployerId] INT NOT NULL,
			[EmployerDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimEmployerVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimEmployerId] PRIMARY KEY CLUSTERED 
		(
			[DimEmployerId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


