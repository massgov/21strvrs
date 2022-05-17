--drop table [RVRS].[DimArmyBranch]
-- sp_help '[RVRS].[DimArmyBranch]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimArmyBranch]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimArmyBranch](
			[DimArmyBranchId] INT NOT NULL IDENTITY (1,1),	
			[BkCityId] INT NOT NULL,
			[ArmyBranchDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimArmyBranchId] PRIMARY KEY CLUSTERED 
		(
			[DimArmyBranchId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


