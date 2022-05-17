--drop table [RVRS].[DeathMedicalRecord]
--sp_help '[RVRS].[DeathMedicalRecord]'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathMedicalRecord]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathMedicalRecord] (  
		   [DeathMedicalRecordId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the				 
		   [RecordNumber] VARCHAR(32) NULL, --MED_REC_NUM
		   [CaseYear] DECIMAL(4,0) NULL,  --ME_CASE_YEAR
		   [CaseNumber] VARCHAR(16),  --ME_CASE_NUM
		   [FirstName] VARCHAR(128), --ME_GNAME
		   [MiddleName] VARCHAR(128), --ME_MNAME		
		   [LastName] VARCHAR(128), --ME_LNAME		 
		   [DimSuffixId]INT NOT NULL CONSTRAINT [df_DeathMedicalRecordDimSuffixId] DEFAULT (0),--ME_SUFF
		   [DimSexId] INT NOT NULL CONSTRAINT [df_DeathMedicalRecordDimSexId] DEFAULT (0), --ME_SEX
		   [BirthYear] DECIMAL(4,0) NULL, --Year(ME_DOB)
		   [BirthMonth] DECIMAL(2,0) NULL, --Month(ME_DOB)
		   [BirthDay] DECIMAL(2,0) NULL, --Day(ME_DOB)
	       [DeathYear] DECIMAL(4,0) NULL,--Year(DOD)
		   [DeathMonth] DECIMAL(2,0) NULL, --Month(DOD)
		   [DeathDay] DECIMAL(2,0) NULL, -- Day(DOD)
		   [DeathHour] DECIMAL(2,0) NULL,--Hour(TOD_ME)		   [DeathMinute] DECIMAL(2,0) NULL,--Min(TOD_ME)
		   [DimTimeIndId] INT NOT NULL CONSTRAINT [df_DeathMedicalRecordDimTimeIndId] DEFAULT (0),--TOD_IN_ME
		   [PronouncedYear] DECIMAL(4,0) NULL, --Year(ME_PRO_DATE)		   [PronouncedMonth] DECIMAL(2,0) NULL,--Month(ME_PRO_DATE)		   [PronouncedDay] DECIMAL(2,0) NULL,--Day(ME_PRO_DATE)		   [PronouncedHour] DECIMAL(2,0) NULL,--Hour(ME_PRO_TIME)		   [PronouncedMinute] DECIMAL(2,0) NULL,--Min(ME_PRO_TIME)
		   [DimPronouncedTimeInd] INT NOT NULL CONSTRAINT [df_DeathMedicalRecordDimPronouncedTimeInd] DEFAULT (0),--ME_PRO_TIME_IN
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathMedicalRecordCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathMedicalRecordId] PRIMARY KEY CLUSTERED 
		(
			[DeathMedicalRecordId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 