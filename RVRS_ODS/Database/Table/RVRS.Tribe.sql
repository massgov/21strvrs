--drop table [RVRS].[Tribe]
--sp_help '[RVRS].[Tribe]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Tribe]') )
	BEGIN 
		CREATE TABLE [RVRS].[Tribe] (  
		   [TribeId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the		  
		   [DimEthnicityGroupId] INT NOT NULL CONSTRAINT [df_TribeDimEthnicityGroupId] DEFAULT (0), --RACE3	 
		   [DimTribeGroupId] INT NOT NULL CONSTRAINT [df_TribeDimTribeGroupId] DEFAULT (0), --RACE16		
		   [DimTribeId] INT NOT NULL CONSTRAINT [df_TribeDimTribeId] DEFAULT (0), --Multiple Columns (e.g.DETHNIC_AFRICAN_CB,DETHNIC_AMERICAN)		  	     
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_TribeCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_TribeId] PRIMARY KEY CLUSTERED 
		(
			[TribeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 