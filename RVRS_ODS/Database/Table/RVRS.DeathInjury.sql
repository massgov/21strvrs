--drop table [RVRS].[DeathInjury]
--sp_help '[RVRS].[DeathInjury]'
 --select * from [RVRS].[DeathInjury]
-- 
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathInjury]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathInjury] (  
		   [DeathInjuryId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the	
		   [InjuryYear] DECIMAL(4,0) NULL,--Year(DOI)
		   [InjuryMonth] DECIMAL(2,0) NULL, --Month(DOI)
		   [InjuryDay] DECIMAL(2,0) NULL, -- Day(DOI)
		   [InjuryHour] DECIMAL(2,0) NULL,--TOI
		   [InjuryMinute] DECIMAL(2,0) NULL,--TOI
		   [DimInjuryTimeIndId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryTimeIndId] DEFAULT (0), --TOI_IND
		   [DimInjuryAtWorkId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryAtWorkId] DEFAULT (0),  
		   [DimInjuryOccurredId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryOccurredId] DEFAULT (0),
		   [DimInjuryPlaceId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryPlaceId] DEFAULT (0),
		   [DimInjuryTransportId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryTransportId] DEFAULT (0),
		   [DimInjuryTransportOtherId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryTransportOtherId] DEFAULT (0),		
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathInjuryCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathInjuryId] PRIMARY KEY CLUSTERED 
		(
			[DeathInjuryId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 