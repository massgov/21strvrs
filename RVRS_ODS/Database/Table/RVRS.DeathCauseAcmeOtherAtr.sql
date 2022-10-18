--drop table [RVRS].[DeathCauseAcmeOtherAttr]
--sp_help '[RVRS].[DeathCauseAcmeOtherAttr]' 

SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathCauseAcmeOtherAttr]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathCauseAcmeOtherAttr](  		
			[DeathCauseAcmeOtherAttrId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[DimFlTransaxConversionId] INT NOT NULL CONSTRAINT [df_DeathCauseAcmeOtherAttrDimFlTransaxConversionId] DEFAULT (0), -- TRX_FLG
			[CauseManual] VARCHAR(8)  NULL, -- TRX_CAUSE_MANUAL
			[InjuryPlace] VARCHAR(1)  NULL, -- TRX_INJRY_PLACE
			[DimSystemRejectId] INT NOT NULL CONSTRAINT [df_DeathCauseAcmeOtherAttrDimSystemRejectId] DEFAULT (0), -- TRX_SYS_REJECT_CD
			[DimIntentionalRejectId] INT NOT NULL CONSTRAINT [df_DeathCauseAcmeOtherAttrDimIntentionalRejectId] DEFAULT (0), -- TRX_INT_REJECT_CD
			[ActivityAtTimeOfDeath] DECIMAL (1,0) NULL, -- TRX_INJRY_L
			[UnderlyingCause] VARCHAR(8)  NULL, -- TRX_CAUSE_ACME
			[RecordAxisCode] VARCHAR(1024)  NULL, -- TRX_REC_AXIS_CD
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathCauseAcmeOtherAttrCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathCauseAcmeOtherAttrId] PRIMARY KEY CLUSTERED 
		(
			[DeathCauseAcmeOtherAttrId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 