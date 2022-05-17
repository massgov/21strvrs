--drop table [RVRS].[DimPhysician]
-- sp_help '[RVRS].[DimPhysician]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimPhysician]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimPhysician](
			[DimPhysicianId] INT NOT NULL IDENTITY (1,1),	
			[BkPhysicianId] INT NOT NULL,
			[FirstName] VARCHAR(128), --CERT_GNAME,ATTEND_PHYSICIAN_GNAME,MC_NOTIFIED_GNAME
			[MiddleName] VARCHAR(128), --CERT_MNAME,ATTEND_PHYSICIAN_MNAME,MC_NOTIFIED_MNAME
			[LastName] VARCHAR(128), --CERT_LNAME,ATTEND_PHYSICIAN_LNAME,MC_NOTIFIED_LNAME
			[DimSuffixId]INT NOT NULL CONSTRAINT [df_DimPhysicianDimSuffixId] DEFAULT (0),--CERT_SUFF,ATTEND_PHYSICIAN_SUFFIX,MC_NOTIFIED_SUFFIX
			[LicenseNumber] VARCHAR(32) NULL, -- CERT_LIC_NUM
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimPhysicianId] PRIMARY KEY CLUSTERED 
		(
			[DimPhysicianId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


