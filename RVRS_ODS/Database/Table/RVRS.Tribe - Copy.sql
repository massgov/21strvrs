--drop table [RVRS].[DeathInjury]
--sp_help '[RVRS].[DeathInjury]'
--sp_help '[RVRS].[Death]'
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
		   [DeathYear] DECIMAL(4,0) NULL,--Year(DOI)
		   [DeathMonth] DECIMAL(2,0) NULL, --Month(DOI)
		   [DeathDay] DECIMAL(2,0) NULL, -- Day(DOI)
		   [DeathHour] DECIMAL(2,0) NULL,--TOI
		   [DeathMinute] DECIMAL(2,0) NULL,--TOI
		   [DimTimeInd] INT NOT NULL CONSTRAINT [df_DeathInjuryDimTimeInd] DEFAULT (0), --TOI_IND,
		   [DimInjuryAtWorkId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryAtWorkId] DEFAULT (0), --INJRY_WORK
		   [DimInjuryOccurredId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryOccurredId] DEFAULT (0), --INJRY_
		   [DimInjuryPlaceId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryPlaceId] DEFAULT (0), --INJRY_PLACEL
		   [DimInjuryTransportId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryTransportId] DEFAULT (0), --INJRY_TRANSPRT
		   [DimInjuryTransportOtherId] INT NOT NULL CONSTRAINT [df_DeathInjuryDimInjuryTransportOtherId] DEFAULT (0), --INJRY_TRANSPRT_OTHER
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathInjuryCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_DeathInjuryId] PRIMARY KEY CLUSTERED 
		(
			[DeathInjuryId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 