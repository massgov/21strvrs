--drop table [RVRS].[DimDispMethodOther]
-- sp_help '[RVRS].[DimDispMethodOther]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimDispMethodOther]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimDispMethodOther](
			[DimDispMethodOtherId] INT NOT NULL IDENTITY (1,1),	
			[BkDispMethodOtherId] INT NOT NULL, --DISP
			[DimDispMethodId] INT NOT NULL CONSTRAINT [df_DimDispMethodOtherDimDispMethodId] DEFAULT (0), --DISPL
			[DispMethodOtherDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimDispMethodOtherVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimDispMethodOtherId] PRIMARY KEY CLUSTERED 
		(
			[DimDispMethodOtherId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


