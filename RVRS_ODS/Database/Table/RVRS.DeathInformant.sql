--drop table [RVRS].[DeathInformant]
--sp_help '[RVRS].[DeathInformant]'

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathInformant]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathInformant] (  
		   [DeathInformantId] BIGINT NOT NULL IDENTITY (1,1),  --  RVRS Column to store the	
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 
		   [FirstName] VARCHAR(128), --INFO_NME
		   [MiddleName] VARCHAR(128), --INFO_MIDD_NME	
		   [LastName] VARCHAR(128), --INFO_LST_NME	
		   [DimSuffixId]INT NOT NULL CONSTRAINT [df_DeathInformantDimSuffixId] DEFAULT (0),--INFO_SUFFIX
		   [DimInformantRelationId] INT NOT NULL CONSTRAINT [df_DeathInformantDimInformantRelationId] DEFAULT (0), --INFO_RELATION
		   [DimInformantRelationOtherId] INT NOT NULL CONSTRAINT [df_DeathInformantDimInformantRelationOtherId] DEFAULT (0), --INFO_RELATION_OTHER 
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathInformantCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathInformantId] PRIMARY KEY CLUSTERED 
		(
			[DeathInformantId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 