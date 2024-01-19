--drop table [RVRS].[DivorceRegistration]
--sp_help '[RVRS].[DivorceRegistration]'
-- use rvrs_testdb
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DivorceRegistration]') )
	BEGIN
		CREATE TABLE[RVRS].[DivorceRegistration](  		
			[DivorceRegistrationId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[DivorceEventId] BIGINT NOT NULL,  --  FK DivorceEvent
			[DimRegistrarTypeInternalId] INT NOT NULL CONSTRAINT [df_DivorceRegistrationDimRegistrarTypeInternalId] DEFAULT (0), --COUNTY		
			[DimRegistrarId] INT NOT NULL CONSTRAINT [df_DivorceRegistrationDimRegistrarId] DEFAULT (0), -- LegacyPlus.registrar_name
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DivorceRegistrationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DivorceRegistrationId] PRIMARY KEY CLUSTERED 
		(
			[DivorceRegistrationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END
	
	GO 
