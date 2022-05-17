-- drop table [RVRS].[Occupation]
-- sp_help '[RVRS].[Occupation]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Occupation]') )
	BEGIN 
		CREATE TABLE [RVRS].[Occupation] (  
		   [OccupationId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 	 
		   [DimIndustryId]INT NOT NULL CONSTRAINT [df_OccupationDimIndustryId] DEFAULT (0),	
		   [DimOccupationId]INT NOT NULL CONSTRAINT [df_OccupationDimOccupationId] DEFAULT (0),	
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_OccupationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column	
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_OccupationId] PRIMARY KEY CLUSTERED 
		(
			[OccupationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 