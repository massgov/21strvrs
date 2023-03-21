--drop table [RVRS].[DimModuleInternal]
--drop table [RVRS].[DimModule]
--sp_help '[RVRS].[DimModuleInternal]'
--sp_rename 'rvrs.DimModuleInternal.ModuleDesc', 'ModuleInternalDesc', 'Column'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
					WHERE object_id = OBJECT_ID('[RVRS].[DimModuleInternal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DimModuleInternal](
			[DimModuleInternalId] INT NOT NULL,		
		    [ModuleInternalDesc] VARCHAR(128) NOT NULL,		
			[ModuleGuidCode] CHAR(2) NOT NULL,	
			[Void] TINYINT NOT NULL, 
		CONSTRAINT [pk_DimModuleInternalId] PRIMARY KEY CLUSTERED 
		(
			[DimModuleInternalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END 
GO

