--drop table [RVRS].[DimPersonTypeInternal]
--sp_help '[RVRS].[DimPersonTypeInternal]'
--sp_rename 'rvrs.DimPersonTypeInternal.PersonTypeDesc', 'PersonTypeInternalDesc', 'Column'
--sp_rename 'rvrs.DimPersonTypeInternal.DimPersonTypeId', 'DimPersonTypeInternalId', 'Column'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimPersonTypeInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimPersonTypeInternal](
			[DimPersonTypeInternalId] INT NOT NULL,		
		    [PersonTypeInternalDesc] VARCHAR(128) NOT NULL,	
			[PersonGuidCode] char(3),
			[Void] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimPersonTypeInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimPersonTypeInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

