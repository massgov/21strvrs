--drop table [RVRS].[Person]
--sp_help '[RVRS].[Person]'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Person]') )
	BEGIN 
		CREATE TABLE [RVRS].[Person] (  
		   [PersonId] BIGINT NOT NULL IDENTITY (1,1),  --  RVRS Column to store the		
		   [DimModuleInternalId] INT NOT NULL CONSTRAINT [df_PersonDimModuleInternalId] DEFAULT (0),  -- RVRS Column to store the	 the module- e.g Birth, Death
		   [DimPersonTypeInternalId] INT NOT NULL CONSTRAINT [df_PersonDimPersonTypeInternalId] DEFAULT (0), -- RVRS Column to store the	PersonType - Decedent,Child, Mother, Father
		   [SrId] VARCHAR(64) NOT NULL, --DEATH_REC_ID
		   [Guid] VARCHAR(64) NOT NULL,  -- Source(f2D) + Module(s2D) + PersonType(t2D) + DEATH_REC_ID(last45)  -Unique identifier is used to update data for delta different source , it's used to audit data
		   [GuidBaseLine] VARCHAR(64) NULL, --VRV_BASELINE_RECORD_ID
		   [GuidOriginate] VARCHAR(64) NULL,  --VRV_ORIGINATING_REC_ID
		   [SrVersion] DECIMAL (2,0) NOT NULL, --VRV_REC_REPLACE_NBR
		   [FlCurrent] DECIMAL (1,0) NOT NULL,  --FL_CURRENT
		   [FlAbandoned] DECIMAL (1,0) NOT NULL,	--FL_ABANDONED
		   [SrVoided] DECIMAL (1,0) NOT NULL, --FL_VOIDED
		   [FirstName] VARCHAR(128), --GNAME
		   [MiddleName] VARCHAR(128), --MNAME
		   [MiddleInitial] VARCHAR(32), --middle_initial
		   [LastName] VARCHAR(128), --LNAME_MAIDEN
		   [LastNameMaiden] VARCHAR(128), -- LNAME
		   [DimSuffixId]INT NOT NULL CONSTRAINT [df_PersonDimSuffixId] DEFAULT (0),--SUFF
		   [DimSexId] INT NOT NULL CONSTRAINT [df_PersonDimSexId] DEFAULT (0), --SEX
		   [BirthYear] DECIMAL(4,0) NULL, --Year(DOB)
		   [BirthMonth] DECIMAL(2,0) NULL, --Month(DOB)
		   [BirthDay] DECIMAL(2,0) NULL, --Day(DOB)
		   [AgeCalcYear] DECIMAL (3,0) NULL, --AGE1_CALC
		   [AgeYear] DECIMAL (4,0) NULL,  --AGE1, 
		   [AgeMonth] DECIMAL (2,0) NULL, --AGE2
		   [AgeDay] DECIMAL (2,0) NULL, --AGE3
		   [AgeHour] DECIMAL (2,0) NULL, --AGE4
		   [AgeMinute] DECIMAL (2,0) NULL, --AGE5
		   [DimAgeTypeId] INT NOT NULL CONSTRAINT [df_PersonDimAgeTypeId] DEFAULT (0), --AGETYPE
		   [DimMaritalStatusId] INT NOT NULL CONSTRAINT [df_PersonDimMaritalStatusId] DEFAULT (0),
		   [Ssn] VARCHAR(11) NULL,
		   [SrCreatedDate] DATETIME NOT NULL, -- VRV_REC_DATE_CREATED
		   [SrUpdatedDate] DATETIME NOT NULL, --LAST_UPDATED_DATE
		   [SrCreatedUserId] INT NOT NULL CONSTRAINT [df_PersonSrCreatedUserId] DEFAULT (0), --VRV_REC_INIT_USER_ID
		   [SrUpdatedUserId] INT NOT NULL CONSTRAINT [df_PersonSrUpdatedUserId] DEFAULT (0),  --LAST_UPDATED_USER_ID		  
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_PersonCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_PersonId] PRIMARY KEY CLUSTERED 
		(
			[PersonId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 