--drop table [RVRS].[DeathBurialAgent]
--sp_help '[RVRS].[DeathBurialAgent]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathBurialAgent]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathBurialAgent](  		
			[DeathBurialAgentId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[DimBurialAgentId] INT NOT NULL CONSTRAINT [df_DeathBurialAgentDimBurialAgentId] DEFAULT (0), -- BURIAL_AGENT_TITLE,BURIAL_AGENT_GNAME,BURIAL_AGENT_MNAME,BURIAL_AGENT_LNAME,BURIAL_AGENT_SUFFIX
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathBurialAgentCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathBurialAgentId] PRIMARY KEY CLUSTERED 
		(
			[DeathBurialAgentId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 