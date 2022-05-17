--drop table [RVRS].[DeathManner]
--sp_help '[RVRS].[DeathManner]'
--sp_help '[RVRS].[Death]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathManner]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathManner] (  
		   [DeathMannerId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the			
		   [DimDeathMannerId] INT NOT NULL CONSTRAINT [df_DeathMannerDimDeathMannerId] DEFAULT (0), --INJRY_PLACEL		 
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathMannerCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_DeathMannerId] PRIMARY KEY CLUSTERED 
		(
			[DeathMannerId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 