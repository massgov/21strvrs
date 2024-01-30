--drop table [RVRS].[OtherUser]
--sp_help '[RVRS].[OtherUser]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[OtherUser]') )
	BEGIN
		CREATE TABLE[RVRS].[OtherUser](  		
			[OtherUserId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 			[ScrUserID] INT NOT NULL , -- FDIR_SIGN_USER_ID,CERT_SIGN_USER_ID,BIRTH_MATCH_USER_ID			[DimUserTypeId] INT NOT NULL CONSTRAINT [df_OtherUserDimUserTypeId] DEFAULT (0), -- SEED
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_OtherUserCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_OtherUserId] PRIMARY KEY CLUSTERED 
		(
			[OtherUserId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 