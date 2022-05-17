--drop table [RVRS].[DeathBurialPermit]
--sp_help '[RVRS].[DeathBurialPermit]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathBurialPermit]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathBurialPermit](  		
			[DeathBurialPermitId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[DimNoBurialPermitId] INT NOT NULL CONSTRAINT [df_DeathBurialPermitDimNoBurialPermitId] DEFAULT (0), -- BURIAL_PERMIT_NONE			[DeathBurialPermitDate] DATETIME NULL, -- BURIAL_PERMIT_ISSUE_DATE			[DeathBurialPermitNumber] VARCHAR(32)  NULL, -- BURIAL_PERMIT_NUMBER			[NoPermitReason] VARCHAR(128) NULL, -- BURIAL_PERMIT_NONE_REASON			[Comment] VARCHAR(128)  NULL, -- BURIAL_PERMIT_COMMENTS			[StatePermitDate]  DATETIME  NULL, -- BURIAL_PERMIT_ISSUE_DATE_RV			[StateTrackNumber]  VARCHAR(32) NULL, -- BURIAL_PERMIT_NUMBER_RV
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathBurialPermitCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathBurialPermitId] PRIMARY KEY CLUSTERED 
		(
			[DeathBurialPermitId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 