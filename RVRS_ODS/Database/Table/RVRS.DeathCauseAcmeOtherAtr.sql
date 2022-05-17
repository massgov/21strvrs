--drop table [RVRS].[DeathCauseAcmeOtherAtr]
--sp_help '[RVRS].[DeathCauseAcmeOtherAtr]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathCauseAcmeOtherAtr]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathCauseAcmeOtherAtr] (  
		   [DeathCauseAcmeOtherAtrId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the		  
		   [FgTransaxConversion] VARCHAR(2) NULL, --TRX_FLG
		   [InjuryPlace] VARCHAR(2) NULL,  --TRX_INJRY_PLACE	
		   [SystemRejectCode] VARCHAR(2) NULL, --TRX_SYS_REJECT_CD
		   [IntentionalReject] VARCHAR(2) NULL, --TRX_INT_REJECT_CD
		   [ActivityAtTimeOfDeath] DECIMAL (1,0) NULL, --TRX_INJRY_L
		   [UnderlyingCauseManual] VARCHAR(8) NULL,  --TRX_CAUSE_MANUAL		
		   [AcmeUnderlyingCause] VARCHAR(8) NULL, --TRX_CAUSE_ACME
		   [RecordAxisCode] VARCHAR(100) NULL, --TRX_REC_AXIS_CD
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathCauseAcmeOtherAtrCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_DeathCauseAcmeOtherAtrId] PRIMARY KEY CLUSTERED 
		(
			[DeathCauseAcmeOtherAtrId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		

END 