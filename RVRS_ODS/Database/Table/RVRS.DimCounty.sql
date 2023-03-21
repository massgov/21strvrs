--drop  table [RVRS].[DimCounty]
--sp_help '[RVRS].[DimCounty]'
-- select * from [RVRS].[DimCounty] order by fipscode 
-- Alter table [RVRS].[DimCounty] ADD [InStateCode] VARCHAR(3) NULL
--alter table [RVRS].[DimCounty] ADD ValueSet VARCHAR(512)  
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimCounty]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimCounty](
			[DimCountyId] INT NOT NULL IDENTITY (1,1),	
			[BkCountyId] INT NOT NULL,		
			[DimStateId] INT NOT NULL CONSTRAINT [df_DimCountyDimStateId]  DEFAULT ((0)),
			[FipsCode] VARCHAR(3) NULL,
			[NchsCode] VARCHAR(3) NULL,
			[InStateCode] VARCHAR(3) NULL,
			[CountyDesc] VARCHAR(128) NOT NULL,  --COUNTY_NAME
			[ValueSet] VARCHAR(512) NOT NULL, 
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL  --- CONSTRAINT [df_DimCountyActive]  DEFAULT ((1)), --Void
		CONSTRAINT [pk_DimCountyId] PRIMARY KEY CLUSTERED 
		(
			[DimCountyID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO


