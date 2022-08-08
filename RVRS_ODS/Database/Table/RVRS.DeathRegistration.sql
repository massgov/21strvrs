--drop table [RVRS].[DeathRegistration]
--sp_help '[RVRS].[DeathRegistration]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathRegistration]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathRegistration](  		
			[DeathRegistrationId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[RegistrationDate]  VARCHAR(10) NOT NULL, --  RESIDE_REGIS_DATE, OCCUR_REGIS_DATE,ST_REGIS_DATE
			[DimRegistrarId] INT NOT NULL CONSTRAINT [df_DeathRegistrationDimRegistrarId] DEFAULT (0), -- OCCUR_REGIS_NAMEL,RESIDE_REGIS_NAME,RESIDE_REGIS_NAMEL,ST_REGIS_NAME	
			[RegistrationNumber]  VARCHAR(32) NOT NULL, -- RECORD_REGIS_NUM,OCCUR_REGIS_NUM,RESIDE_REGIS_NUM,ST_REGIS_NUM
			[AmendmentDate]  DATETIME   NULL, -- DATE_OF_AMENDMENT,OCCUR_AMENDMENT_DATE,ST_AMENDMENT_DATE
			[DimRecordAccessId] INT NOT NULL CONSTRAINT [df_DeathRegistrationDimRecordAccessId] DEFAULT (0), -- IND_ACCESS_STATUS ,ST_VOLUME_TYPE
			[Volume]  VARCHAR(24) NOT NULL, -- OCCUR_REGIS_VOLUME,RESIDE_REGIS_VOLUME,ST_VOLUME
			[Page]  VARCHAR(10) NOT NULL, -- OCCUR_REGIS_PAGE,RESIDE_REGIS_PAGE,ST_PAGE
			[DepositionNumber]  VARCHAR(24)  NULL, -- OCCUR_DEPOSITION_NUM,RESIDE_DEPOSITION_NUM,ST_DEPOSITION_NUM
			[ArchivalPrintedDate]  VARCHAR(10)  NULL, -- ARCHIVAL_COPY_PRINTED_DATE,ARCHIVL_COPY_PRINT_RESIDE_DATE,ST_ARCHVL_COPY_PRINTED_DATE	
			[FlArchived]  DECIMAL (1,0)  NULL, -- FL_OCCUR_ARCHIVED,FL_RES_ARCHIVED,FL_RVRS_ARCHIVED		
			[FlAcknowledge] DECIMAL (1,0)  NULL, -- RESIDE_AMEND_ACKNOWLEDGE_FL 				
			[PreviousVolumePage]  VARCHAR(15)  NULL, -- ST_PREVIOUS_VOL_PAGE,PREV_VOL_PG_HIDDEN
			[DimPageEntryTypeId] INT NOT NULL CONSTRAINT [df_DeathRegistrationDimPageEntryTypeId] DEFAULT (0), -- ST_VOL_PAGE_ENTRY_TYPE	
			[FlRegistered]  DECIMAL (1,0) NOT NULL, -- OCCUR_REGISTERED_FL,RESIDE_REGISTERED_FL,STATE_REGISTERED_FL			
			[SrcRegistererUserId]  INT NOT NULL, -- REGISTERER_ID(Occur),REGISTERER_ID_RE(Res), REGISTERER_ID_ST			
			[FlSearchable]  DECIMAL (1,0)  NULL, -- FL_SEARCHABLE,FL_SEARCHABLE_RVRS,FL_SEARCHABLE_RESIDE
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathRegistrationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathRegistrationId] PRIMARY KEY CLUSTERED 
		(
			[DeathRegistrationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 
