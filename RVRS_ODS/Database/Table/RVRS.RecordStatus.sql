--drop table [RVRS].[RecordStatus]
--sp_help '[RVRS].[RecordStatus]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[RecordStatus]') )
	BEGIN
		CREATE TABLE[RVRS].[RecordStatus](  		
			[RecordStatusId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[DimMedicalInfoStatusId] INT NOT NULL CONSTRAINT [df_RecordStatusDimMedicalInfoStatusId] DEFAULT (0), -- IND_MED_INFO_STATUS
			[DimPersonalInfoStatusId] INT NOT NULL CONSTRAINT [df_RecordStatusDimPersonalInfoStatusId] DEFAULT (0), -- IND_PERS_INFO_STATUS
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_RecordStatusCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_RecordStatusId] PRIMARY KEY CLUSTERED 
		(
			[RecordStatusId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 