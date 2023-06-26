--drop table [RVRS].[DimFuneralHomeTypeInternal]
-- sp_help '[RVRS].[DimFuneralHomeTypeInternal]'
-- use rvrs_testdb
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimFuneralHomeTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimFuneralHomeTypeInternal](
			[DimFuneralHomeTypeInternalId] INT NOT NULL IDENTITY (1,1),			
			[FuneralHomeTypeInternalDesc] VARCHAR(128) NOT NULL,  
			[Void] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimFuneralHomeTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimFuneralHomeTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


