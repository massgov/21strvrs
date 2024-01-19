--drop table [RVRS].[DimSex]
--sp_help  '[RVRS].[DimSex]'
--select * from [RVRS].[DimSex]
--Alter table [RVRS].[DimSex] ADD Code VARCHAR(8)
--Alter table [RVRS].[DimSex] ADD ValueSet VARCHAR(512) 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimSex]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimSex](
			[DimSexId] INT NOT NULL IDENTITY (1,1),	
			[BkSexId] INT NOT NULL,
		    [SexDesc] VARCHAR(128) NOT NULL,
			[Abbr] VARCHAR(16) NULL,
			[Code] VARCHAR(8) NULL,
			[ValueSet] VARCHAR (512),
			[StartDate] DateTime NULL,
			[EndDate] DateTime NULL,
			[SrcVoid] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimSexId] PRIMARY KEY CLUSTERED 
		(
			[DimSexId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

