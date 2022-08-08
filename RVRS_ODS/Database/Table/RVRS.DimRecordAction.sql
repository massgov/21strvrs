--drop table [RVRS].[DimRecordAction]
-- sp_help '[RVRS].[DimRecordAction]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimRecordAction]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimRecordAction](
			[DimRecordActionId] INT NOT NULL IDENTITY (1,1),	
			[BkRecordActionId] INT NOT NULL,
			[GroupName] VARCHAR(64) NOT NULL,
			[RecordActionDesc] VARCHAR(128) NOT NULL,   --ME_APPROVED,FL_CERT_INFO_COMPLETE(more fields)
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimRecordActionVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimRecordActionId] PRIMARY KEY CLUSTERED 
		(
			[DimRecordActionId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


