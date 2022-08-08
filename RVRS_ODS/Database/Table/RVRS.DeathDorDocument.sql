--drop table [RVRS].[DeathDorDocument]
--sp_help '[RVRS].[DeathDorDocument]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathDorDocument]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathDorDocument](  		
			[DeathDorDocumentId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[SrcDocumentId] INT NOT NULL, -- DEATH_DOCS_REC_ID			[DocumentName] VARCHAR(50) NOT NULL, -- DOCUMENTNAME
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathDorDocumentCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathDorDocumentId] PRIMARY KEY CLUSTERED 
		(
			[DeathDorDocumentId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 