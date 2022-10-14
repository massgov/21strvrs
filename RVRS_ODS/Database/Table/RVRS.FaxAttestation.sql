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
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_FaxAttestationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_FaxAttestationId] PRIMARY KEY CLUSTERED 
		(
			[FaxAttestationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 