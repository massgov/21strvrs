--drop table [RVRS].[DimPhysicianTitle]
-- sp_help '[RVRS].[DimPhysicianTitle]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimPhysicianTitle]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimPhysicianTitle](
			[DimPhysicianTitleId] INT NOT NULL IDENTITY (1,1),	
			[BkPhysicianTitleId] INT NOT NULL,
			[PhysicianTitleDesc] VARCHAR(128) NOT NULL,  
			[Code] DECIMAL(2,0) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimPhysicianTitleId] PRIMARY KEY CLUSTERED 
		(
			[DimPhysicianTitleId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


