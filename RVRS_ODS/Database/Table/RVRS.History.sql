--drop table [RVRS].[History]
--sp_help '[RVRS].[History]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[History]') )
	BEGIN
		CREATE TABLE[RVRS].[History](  		
			[HistoryId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[DimHcFacilityId] INT NOT NULL CONSTRAINT [df_HistoryDimHcFacilityId] DEFAULT (0), -- VRV_HOSPITAL_OWNER_ID			[Note] VARCHAR(1024) NULL, -- NOTES			[History] VARCHAR(4000) NOT NULL, -- HISTORY			[MeApprovedHistory] VARCHAR(1024) NOT NULL, -- ME_APPROVED_INFO			[FiledMode] DECIMAL(1,0) NOT NULL, -- IND_FILED_MODE			[GrpStartCase] VARCHAR(2) NOT NULL, -- FL_START_CASE			[GrpCreatedModification] VARCHAR(2) NULL, -- IND_MOD_STARTED_BY
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_HistoryCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_HistoryId] PRIMARY KEY CLUSTERED 
		(
			[HistoryId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 