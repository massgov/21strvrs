--drop table [RVRS].[DeathBirthMatch]
--sp_help '[RVRS].[DeathBirthMatch]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathBirthMatch]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathBirthMatch](  		
			[DeathBirthMatchId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[DimBirthMatchId] INT NOT NULL CONSTRAINT [df_DeathBirthMatchDimBirthMatchId] DEFAULT (0), -- Birth_MATCH_CODE
			[BirthSfn] VARCHAR(16) NOT NULL, -- Birth_SFN_NUM
			[BirthInternalCaseNumber] VARCHAR(32) NOT NULL, -- Birth_INTERNAL_CASE_NUMBER			
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathBirthMatchCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathBirthMatchId] PRIMARY KEY CLUSTERED 
		(
			[DeathBirthMatchId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 