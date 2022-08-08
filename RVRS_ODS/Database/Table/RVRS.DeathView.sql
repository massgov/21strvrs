--drop table [RVRS].[DeathView]
--sp_help '[RVRS].[DeathView]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathView]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathView](  		
			[DeathViewId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[FlViewNeeded] VARCHAR(2) NOT NULL, -- FL_VIEWS_NEEDED			[FlViewPassed] VARCHAR(2)  NOT NULL, -- FL_VIEWS_PASSED			[DateSent] DATETIME NOT NULL, -- DATE_SENT_TO_VIEWS			[FailedReason] VARCHAR(4000) NOT NULL, -- VIEWS_FAILED_REASON
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathViewCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathViewId] PRIMARY KEY CLUSTERED 
		(
			[DeathViewId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 