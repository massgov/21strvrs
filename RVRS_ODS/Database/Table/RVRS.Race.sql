--drop table [RVRS].[Race]
--sp_help '[RVRS].[Race]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Race]') )
	BEGIN 
		CREATE TABLE [RVRS].[Race] (  
		   [RaceId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the	  
		   [DimOtherRaceId] INT NOT NULL CONSTRAINT [df_RaceDimOtherRaceId] DEFAULT (0), --	 RACE15,DETHNIC4 
		   [DimRaceId] INT NOT NULL CONSTRAINT [df_RaceDimRaceId] DEFAULT (0), --Multiple Columns (e.g.DETHNIC_AFRICAN_CB,DETHNIC_AMERICAN)		 
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_RaceCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_RaceId] PRIMARY KEY CLUSTERED 
		(
			[RaceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 