--drop table [RVRS].[DeathRegistrationGeneral]
--sp_help '[RVRS].[DeathRegistrationGeneral]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathRegistrationGeneral]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathRegistrationGeneral](  		
			[DeathRegistrationGeneralId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[DimRegistrarId] INT NOT NULL CONSTRAINT [df_DeathRegistrationGeneralDimRegistrarId] DEFAULT (0), -- RECORD_REGISTRAR
			[RegistrationNumber] VARCHAR(32) NOT NULL, -- RECORD_REGIS_NUM
			[RegistrationDate]  DATETIME NOT NULL, -- RECORD_REGIS_DATE
			[AmendmentDate]  DATETIME NULL, -- DATE_OF_AMENDMENT
			[DimRecordAccessId] INT NOT NULL CONSTRAINT [df_DeathRegistrationGeneralDimRecordAccessId] DEFAULT (0), -- IND_ACCESS_STATUS
			[GrpRegistered]  VARCHAR(2) NOT NULL, -- IND_RECORD_OWNER
			[ScrRegistererUserId]  INT NOT NULL, -- RECORD_REGISTRAR_ID
			[FlRegistered] DECIMAL (1,0) NOT NULL, -- VRV_REGISTERED_FLAG
			[FlUpdatePending] DECIMAL (1,0)  NULL, -- FL_UPDATE_PENDING
			[FlAmendmentInProcess] DECIMAL (1,0)  NULL, -- AMEND_IN_PROCESS
			[FlDelayed] DECIMAL (1,0) NULL, -- FL_DELAYED
			[FlAmended] DECIMAL (1,0) NULL, -- FL_AMENDED
			[DimRegistrationStatusId] INT NOT NULL CONSTRAINT [df_DeathRegistrationGeneralDimRegistrationStatusId] DEFAULT (0), -- IND_REGIS_STATUS
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathRegistrationGeneralCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathRegistrationGeneralId] PRIMARY KEY CLUSTERED 
		(
			[DeathRegistrationGeneralId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 