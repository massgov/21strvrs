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
		   [EthnicityId] BIGINT NOT NULL , --RACE3	
		   [DimTribeId] INT NOT NULL CONSTRAINT [df_TribeDimTribeId] DEFAULT (0), --Multiple Columns (e.g.DETHNIC_AFRICAN_CB,DETHNIC_AMERICAN)	
		   [DimOtherTribeId] INT NOT NULL CONSTRAINT [df_TribeDimOtherTribeId] DEFAULT (0), --RACE16			  	  	     
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_TribeCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_TribeId] PRIMARY KEY CLUSTERED 
		(
			[TribeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 