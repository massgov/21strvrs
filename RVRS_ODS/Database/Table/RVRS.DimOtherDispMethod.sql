--drop table [RVRS].[DimOtherDispMethod]
-- sp_help '[RVRS].[DimOtherDispMethod]'

--
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimOtherDispMethod]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimOtherDispMethod](
			[DimOtherDispMethodId] INT NOT NULL IDENTITY (1,1),	
			[BkOtherDispMethodId] INT NOT NULL,
			[OtherDispMethodDesc] VARCHAR(128) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[Void] TINYINT NOT NULL CONSTRAINT [df_DimOtherDispMethodVoid] DEFAULT (0),			
		CONSTRAINT [pk_DimOtherDispMethodId] PRIMARY KEY CLUSTERED 
		(
			[DimOtherDispMethodId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


