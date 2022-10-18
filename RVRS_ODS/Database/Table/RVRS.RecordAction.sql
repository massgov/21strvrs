--drop table [RVRS].[RecordAction]
--sp_help '[RVRS].[RecordAction]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[RecordAction]') )
	BEGIN
		CREATE TABLE[RVRS].[RecordAction](  		
			[RecordActionId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[DimRecordActionId] INT NOT NULL CONSTRAINT [df_RecordActionDimRecordActionId] DEFAULT (0), -- SEED			[Value] DECIMAL(1,0) NOT NULL, -- EXP_SSA_SENT_FL-- FL_CERT_SAVE,ME_APPROVED,FL_CERT_INFO_COMPLETE...						[Comment] VARCHAR(4000) NOT NULL, -- RETURN_TO_FH_COMMENTS,DO_NOT_ISSUE_COMMENT			
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_RecordActionCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_RecordActionId] PRIMARY KEY CLUSTERED 
		(
			[RecordActionId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 