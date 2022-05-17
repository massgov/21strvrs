--drop table [RVRS].[DeathCremation]
--sp_help '[RVRS].[DeathCremation]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathCremation]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathCremation](  		
			[DeathCremationId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[DimMeClearedId] INT NOT NULL CONSTRAINT [df_DeathCremationDimMeClearedId] DEFAULT (0), -- CREM_CLEAR_ME			[ClearedComment] VARCHAR(128) NULL, -- CREM_CLEAR_COMMENTS			[DimMeReleasedId] INT NOT NULL CONSTRAINT [df_DeathCremationDimMeReleasedId] DEFAULT (0), -- CREM_RELEASE_ME			[MeCremationDate] DATETIME NULL, -- CREM_RELEASE_DATE_ME
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathCremationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathCremationId] PRIMARY KEY CLUSTERED 
		(
			[DeathCremationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 