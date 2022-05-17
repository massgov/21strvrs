--drop table [RVRS].[DimMedicalInfoStatus]
-- sp_help '[RVRS].[DimMedicalInfoStatus]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimMedicalInfoStatus]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimMedicalInfoStatus](
			[DimMedicalInfoStatusId] INT NOT NULL IDENTITY (1,1),	
			[BkMedicalInfoStatusId] INT NOT NULL,
			[MedicalInfoStatusDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimMedicalInfoStatusVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimMedicalInfoStatusId] PRIMARY KEY CLUSTERED 
		(
			[DimMedicalInfoStatusId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


