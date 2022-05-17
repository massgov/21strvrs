--drop table [RVRS].[Death]
--sp_help '[RVRS].[Death]'
 --select * from [RVRS].[Death]
-- 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Death]') )
	BEGIN 
		CREATE TABLE [RVRS].[Death] (  
		   [DeathId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the	
		   [InternalCaseNumber] VARCHAR(64) NULL, --INTERNAL_CASE_NUMBER
		   [SfnType] VARCHAR(16),-- SFN_TYPE_ID		   
		   [Sfn] VARCHAR(32) NULL,  --SFN_NUM
		   [SfnOutOfState] VARCHAR(32) NULL, --SFN_NUM_OOS
		   [SfnYear]DECIMAL(4,0) NULL, --Sfn_Year  
		   [RecordType] CHAR(3) NULL,--VRV_RECORD_TYPE_ID,
		   [OtherRecordType] CHAR(1) NULL,		  
		   [DeathYear] DECIMAL(4,0) NULL,--Year(DOD_4_FD)
		   [DeathMonth] DECIMAL(2,0) NULL, --Month(DOD_4_FD)
		   [DeathDay] DECIMAL(2,0) NULL, -- Day(DOD_4_FD)
		   [DeathHour] DECIMAL(2,0) NULL,--TOD
		   [DeathMinute] DECIMAL(2,0) NULL,--TOD
		   [DimDeathTimeIndId] INT NOT NULL CONSTRAINT [df_DeathDimTimeOfDeathIndId] DEFAULT (0), --TOD_IN
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathId] PRIMARY KEY CLUSTERED 
		(
			[DeathId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 