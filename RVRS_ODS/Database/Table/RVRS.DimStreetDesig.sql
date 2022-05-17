-- drop table [RVRS].[DimStreetDesig]
-- sp_help '[RVRS].[DimStreetDesig]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimStreetDesig]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimStreetDesig](
			[DimStreetDesigID] INT NOT NULL IDENTITY (1,1),
			[BkStreetDesigID] INT NOT NULL,
			[StreetDesigDesc] VARCHAR(128) NOT NULL,
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL  --CONSTRAINT [df_DimStreetDesigActive]  DEFAULT ((1)),  --Void
		CONSTRAINT [pk_DimStreetDesigId] PRIMARY KEY CLUSTERED 
		(
			[DimStreetDesigID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


