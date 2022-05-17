--drop table [RVRS].[SsnVerify]
--sp_help '[RVRS].[SsnVerify]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[SsnVerify]') )
	BEGIN
		CREATE TABLE[RVRS].[SsnVerify](  		
			[SsnVerifyId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[DimCompanionId] INT NOT NULL CONSTRAINT [df_SsnVerifyDimCompanionId] DEFAULT (0), -- SSN_COMPANION			[DimOvsStatusId] INT NOT NULL CONSTRAINT [df_SsnVerifyDimOvsStatusId] DEFAULT (0), -- SSN_VERIFY_STATUS			[FlInvokeOvs] VARCHAR(1) NULL, -- FL_CALL_OVS2			[FlVerified] VARCHAR(1) NULL, -- FL_SSN_VERIFIED			[OvsCount] DECIMAL (3,0) NULL, -- OVS_SEND_COUNT			[OvsDate]  DATETIME  NULL, -- OVS_SEND_DATE
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_SsnVerifyCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_SsnVerifyId] PRIMARY KEY CLUSTERED 
		(
			[SsnVerifyId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 