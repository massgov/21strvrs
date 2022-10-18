-- drop table [RVRS].[DeathCauseAcme]
-- sp_help '[RVRS].[DeathCauseAcme]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathCauseAcme]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathCauseAcme] (  
		   [DeathCauseAcmeId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 
		   [Order] DECIMAL (3,0) NOT NULL,
		   [Line] DECIMAL (3,0) NOT NULL, --LINE1,2,3 etc 
		   [Sequence] DECIMAL (3,0) NOT NULL, --SEQ1,2,3 etc 
		   [CauseCategory] VARCHAR(8) NOT NULL, --CAUSE_CATEGORY1,2,3 etc 
		   [InjuryNature] DECIMAL (3,0)  NULL, --NATURE_OF_INJURY_FLAG1,2,3 etc 
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathCauseAcmeCreatedDate] DEFAULT (GETDATE()), -- RVRS Column	
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathCauseAcmeId] PRIMARY KEY CLUSTERED 
		(
			[DeathCauseAcmeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 