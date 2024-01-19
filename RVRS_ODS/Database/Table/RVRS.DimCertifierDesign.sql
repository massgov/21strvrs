--drop table [RVRS].[DimCertifierDesign]
-- sp_help '[RVRS].[DimCertifierDesign]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimCertifierDesign]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimCertifierDesign](
			[DimCertifierDesignId] INT NOT NULL IDENTITY (1,1),	
			[BkCertifierDesignId] INT NOT NULL,
			[CertifierDesignDesc] VARCHAR(128) NOT NULL,  
			[Code] VARCHAR(8) NULL,  
			[StartDate] DATETIME NULL,
			[EndDate] DATETIME NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimCertifierDesignId] PRIMARY KEY CLUSTERED 
		(
			[DimCertifierDesignId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


