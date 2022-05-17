--drop table [RVRS].[DimFuneralDirector]
-- sp_help '[RVRS].[DimFuneralDirector]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimFuneralDirector]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimFuneralDirector](
			[DimFuneralDirectorId] INT NOT NULL IDENTITY (1,1),	
			[BkFuneralDirectorId] INT NOT NULL,		
			[FirstName] VARCHAR(128) NULL, --FDIR_FRST_NME
		    [MiddleName] VARCHAR(128) NULL, --FDIR_MIDD_NME
		    [LastName] VARCHAR(128) NULL, --FDIR_LST_NME			
		    [DimSuffixId]INT NOT NULL CONSTRAINT [df_DimFuneralDirectorDimSuffixId] DEFAULT (0),--FDIR_SUFFIX
		    [LicenseNumber] VARCHAR(32), -- FDIR_LIC_NUM
			[DimLocationId] INT NOT NULL CONSTRAINT [df_DimFuneralDirectorDimLocationId] DEFAULT (0), --FDIR_LOCATION_ID
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimFuneralDirectorId] PRIMARY KEY CLUSTERED 
		(
			[DimFuneralDirectorId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


