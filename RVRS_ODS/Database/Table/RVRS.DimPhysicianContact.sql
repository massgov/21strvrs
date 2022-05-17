--drop table [RVRS].[DimPhysicianContact]
-- sp_help '[RVRS].[DimPhysicianContact]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimPhysicianContact]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimPhysicianContact](
			[DimPhysicianContactId] INT NOT NULL IDENTITY (1,1),
			[BkPhysicianContactId] INT NOT NULL,
			[DimPhysicianId] TINYINT NOT NULL CONSTRAINT [df_DimPhysicianContactDimPhysicianId] DEFAULT (0),			
			[PhysicianContactDesc] VARCHAR(128) NOT NULL, --PH_WAY_2_CONTACT,PH_CONTACT_INFO
			[ContactType] VARCHAR(128) NOT NULL, --FAX, PHONE 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimPhysicianContactVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimPhysicianContactId] PRIMARY KEY CLUSTERED 
		(
			[DimPhysicianContactId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


