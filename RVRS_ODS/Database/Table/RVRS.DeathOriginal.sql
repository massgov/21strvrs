--drop table [RVRS].[DeathOriginal]
--sp_help '[RVRS].[DeathOriginal]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathOriginal]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathOriginal] (  
		   [DeathOriginalId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [SrId] VARCHAR(64) NOT NULL,
		   [Entity] VARCHAR(128) NOT NULL,  --  Name of the table 
		   [EntityColumnName] VARCHAR(128) NULL, -- the name of the column that the EntityID comes from 
		   [EntityId] BIGINT NULL , 
		   [ConvertedColumn] VARCHAR(128) NOT NULL , --
		   [OriginalValue] VARCHAR(MAX)  NOT NULL , --
		   [ConvertedValue] VARCHAR(MAX) NOT NULL, --
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathOriginalCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_DeathOriginalId] PRIMARY KEY CLUSTERED 
		(
			[DeathOriginalId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 