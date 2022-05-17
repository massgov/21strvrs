--drop table [RVRS].[DimRecordAccess]
-- sp_help '[RVRS].[DimRecordAccess]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimRecordAccess]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimRecordAccess](
			[DimRecordAccessId] INT NOT NULL IDENTITY (1,1),	
			[BkRecordAccessId] INT NOT NULL,
			[RecordAccessDesc] VARCHAR(128) NOT NULL,  
			[Abbr] VARCHAR(16) NOT NULL,  
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT  NOT NULL, -- it set by source - Src = Source 		
		CONSTRAINT [pk_DimRecordAccessId] PRIMARY KEY CLUSTERED 
		(
			[DimRecordAccessId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


