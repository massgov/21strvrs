--drop table [RVRS].[DeathPronouncement]
--sp_help '[RVRS].[DeathPronouncement]'

SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathPronouncement]') )
	BEGIN
		CREATE TABLE[rvrs].[DeathPronouncement](  		
			[DeathPronouncementId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[PronouncedYear] DECIMAL(4,0) NOT NULL, --PRO_DATE
			[PronouncedMonth] DECIMAL(2,0) NOT NULL,--PRO_DATE
			[PronouncedDay] DECIMAL(2,0) NOT NULL,--PRO_DATE
			[PronouncedHour] DECIMAL(2,0) NULL,--PRO_TIME
			[PronouncedMinute] DECIMAL(2,0) NULL,--PRO_TIME
			[DimPronouncedTimeIndId] INT NOT NULL CONSTRAINT [df_DeathPronouncementDimPronouncedTimeIndId] DEFAULT (0),--PRO_TIME_IN
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathPronouncementCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathPronouncementId] PRIMARY KEY CLUSTERED 
		(
			[DeathPronouncementId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END