--drop table [RVRS].[Ethnicity]
--sp_help '[RVRS].[Ethnicity]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Ethnicity]') )
	BEGIN 
		CREATE TABLE [RVRS].[Ethnicity] (  
		   [EthnicityId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the	
		   [DimEthnicityParentId] INT NOT NULL CONSTRAINT [df_EthnicityDimEthnicityParentId] DEFAULT (0), --e.g. DETHNIC_AFRICAN_CB,DETHNIC_EUROPEAN	  
		   [DimEthnicityId] INT NOT NULL CONSTRAINT [df_EthnicityDimEthnicityId] DEFAULT (0), --Multiple Columns (e.g.DETHNIC_AFRICAN_CB,DETHNIC_AMERICAN)		   
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_EthnicityCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_EthnicityId] PRIMARY KEY CLUSTERED 
		(
			[EthnicityId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 