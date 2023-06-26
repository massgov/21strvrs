--drop table [RVRS].[DeathFuneralDirector]
--sp_help '[RVRS].[DeathFuneralDirector]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathFuneralDirector]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathFuneralDirector](  		
			[DeathFuneralDirectorId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
			[FirstName] VARCHAR(128), ----FDIR_FRST_NME 
		    [MiddleName] VARCHAR(128), --FDIR_MIDD_NME
		    [LastName] VARCHAR(128), --FDIR_LST_NME
		    [DimSuffixId]INT NOT NULL CONSTRAINT [df_DeathFuneralDirectorDimSuffixId] DEFAULT (0),--FDIR_SUFFIX
			[LicenseNumber] VARCHAR(32), -- FDIR_LIC_NUM		
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathFuneralDirectorCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathFuneralDirectorId] PRIMARY KEY CLUSTERED 
		(
			[DeathFuneralDirectorId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 




