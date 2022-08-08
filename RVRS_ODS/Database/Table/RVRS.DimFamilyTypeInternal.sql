--drop table [RVRS].[DimFamilyTypeInternal]
--sp_help '[RVRS].[DimFamilyTypeInternal]'
--- select * from [RVRS].[DimFamilyTypeInternal]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimFamilyTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimFamilyTypeInternal](
			[DimFamilyTypeInternalId] INT NOT NULL IDENTITY (1,1) ,		
		    [FamilyTypeInternalDesc] VARCHAR(128) NOT NULL,	
			[Code] CHAR(2) NOT NULL,	
			[Void] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimFamilyTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimFamilyTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

