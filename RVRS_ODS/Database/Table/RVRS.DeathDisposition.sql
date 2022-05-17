--drop table [RVRS].[DeathDisposition]
--sp_help '[RVRS].[DeathDisposition]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathDisposition]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathDisposition](  		
			[DeathDispositionId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[DimDispMethodId] INT NOT NULL CONSTRAINT [df_DeathDispositionDimDispMethodId] DEFAULT (0), --DISP
			[DimDispMethodOtherId] INT NOT NULL CONSTRAINT [df_DeathDispositionDimDispMethodOtherId] DEFAULT (0), --DISPL
			[DispDate] DATE NULL, --DISP_DATE
			[DimDispPlaceId] INT NOT NULL CONSTRAINT [df_DeathDispositionDimDispPlaceId] DEFAULT (0), --DISP_NME
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathDispositionCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathDispositionId] PRIMARY KEY CLUSTERED 
		(
			[DeathDispositionId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END