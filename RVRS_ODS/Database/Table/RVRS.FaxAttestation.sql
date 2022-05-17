--drop table [RVRS].[FaxAttestation]
--sp_help '[RVRS].[FaxAttestation]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[FaxAttestation]') )
	BEGIN
		CREATE TABLE[RVRS].[FaxAttestation](  		
			[FaxAttestationId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[SerialNumber] DECIMAL(10,0) NULL, -- FAX_SERIAL_NUMBER,			[FlSigned] VARCHAR(1) NULL, -- FAX_SIGNED_FL			[FlDeclined] VARCHAR(1)  NULL, -- FAX_DECLINED_FL			[AttestationStatus] VARCHAR(2) NOT NULL, -- IND_ATTESTATION_STATUS			[ObjectId] VARCHAR(28) NULL, -- FAX_OBJECT_ID			[ReturnCode] INT NOT NULL, -- FAX_RETURN_CODE			[ReturnMessage] VARCHAR(512) NOT NULL, -- FAX_RETURN_MESSAGE			[SentDate] DATETIME2  NULL, -- FAX_SENT_DATE			[WaitingNew]  VARCHAR(1) NOT NULL, -- FAX_WAITING_NEW
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_FaxAttestationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_FaxAttestationId] PRIMARY KEY CLUSTERED 
		(
			[FaxAttestationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 