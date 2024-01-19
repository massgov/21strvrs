--drop table [RVRS].[DivorceEvent]
--drop table [RVRS].[Event]
--sp_help '[RVRS].[DivorceEvent]'
-- use rvrs_testdb

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects         WHERE object_id = OBJECT_ID('[RVRS].[DivorceEvent]') )
	BEGIN 
		CREATE TABLE [RVRS].[DivorceEvent] (  
		   [DivorceEventId] BIGINT NOT NULL IDENTITY (1,1),  --  RVRS Column to store the	 
		   [SrId] VARCHAR(64) NOT NULL, -- Divorce.LegacyPlus.ID
		   [Guid] VARCHAR(64) NOT NULL,  -- Source(f2D) + Module(s2D) + Table Code[third3Ds] + DEATH_REC_ID(last45)  -Unique identifier is used to update data for delta different source , it's used to audit data
	       [CertificateNumber] VARCHAR(32) NOT NULL, --LegacyPlus.Divorce.certificate_number,LegacyPlus.Divorce.cert_num
		   [EventYear] DECIMAL (4,0) NOT NULL, --,Divorce.LegacyPlus.date_of_absolute_judgement, Divorce.LegacyPlus.date_abs_div
		   [EventMonth] DECIMAL (2,0) NOT NULL, --Divorce.LegacyPlus.date_of_absolute_judgement, Divorce.LegacyPlus.date_abs_div
		   [EventDay] DECIMAL (2,0) NOT NULL, --Divorce.LegacyPlus.date_of_absolute_judgement, Divorce.LegacyPlus.date_abs_div
		   [DimEventDateTypeInternalId] INT NOT NULL CONSTRAINT [df_DivorceEventDimEventDateTypeInternalId] DEFAULT (0), --"ABSOLUTE JUDGEMENT DATE","DATE OF BIRTH","ME DATE OF DEATH"		  
		   [DocketNumber] VARCHAR(32) NULL , --legacyPlus.Divorce.docket_number
		   [DimJudgementCountyId]  INT NOT NULL CONSTRAINT [df_DivorceEventDimJudgementCountyId] DEFAULT ((0)), --LegacyPlus.Divorce.county_of_judgement_id,LegacyPlus.Divorce.county_code_id
		   [SrCreatedDate] DATETIME NOT NULL, -- LegacyPlus.Divorce.created_date
		   [SrUpdatedDate] DATETIME NULL, -- LegacyPlus.Divorce.last_modified_date
		   [SrCreatedUserId] INT NOT NULL CONSTRAINT [df_DivorceEventSrCreatedUserId] DEFAULT (0), -- ,LegacyPlus.Divorce.created_by_id
		   [SrUpdatedUserId] INT NOT NULL CONSTRAINT [df_DivorceEventSrUpdatedUserId] DEFAULT (0),  -- LegacyPlus.Divorce.last_modified_by_id
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DivorceEventCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DivorceEventId] PRIMARY KEY CLUSTERED 
		(
			[DivorceEventId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 