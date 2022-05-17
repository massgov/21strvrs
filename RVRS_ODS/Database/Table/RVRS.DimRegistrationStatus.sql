--drop table [RVRS].[DimRegistrationStatus]
-- sp_help '[RVRS].[DimRegistrationStatus]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimRegistrationStatus]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimRegistrationStatus](
			[DimRegistrationStatusId] INT NOT NULL IDENTITY (1,1),	
			[BkRegistrationStatusId] INT  NULL,
			[RegistrationStatusDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimRegistrationStatusVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimRegistrationStatusId] PRIMARY KEY CLUSTERED 
		(
			[DimRegistrationStatusId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


