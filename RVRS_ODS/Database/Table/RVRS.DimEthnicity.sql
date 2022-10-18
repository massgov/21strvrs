--drop table [RVRS].[DimEthnicity]
-- sp_help '[RVRS].[DimEthnicity]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimEthnicity]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimEthnicity](
			[DimEthnicityId] INT NOT NULL IDENTITY (1,1),	
			[BkEthnicityId] INT NOT NULL,
			[EthnicityDesc] VARCHAR(128) NOT NULL,  			
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimEthnicityId] PRIMARY KEY CLUSTERED 
		(
			[DimEthnicityId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


