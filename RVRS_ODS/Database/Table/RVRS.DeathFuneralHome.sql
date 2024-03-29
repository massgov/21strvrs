--drop table [RVRS].[DeathFuneralHome]
--sp_help '[RVRS].[DeathFuneralHome]'
SET ANSI_NULLS ON
GO
 
 
SET QUOTED_IDENTIFIER ON
GO
 
 
IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathFuneralHome]') )
	BEGIN
		CREATE TABLE[RVRS].[DeathFuneralHome](  		
			[DeathFuneralHomeId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column 
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
            [DimFuneralHomeId] INT NOT NULL CONSTRAINT [df_DeathFuneralHomeDimFuneralHomeId] DEFAULT (0), -- FNRL_NME
			[DimTradeServiceCallId] INT NOT NULL CONSTRAINT [df_DeathFuneralHomeDimTradeServiceCallId] DEFAULT (0), -- FNRL_SERVICE_OOS			
			[CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathFuneralHomeCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store created date
		   	[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathFuneralHomeId] PRIMARY KEY CLUSTERED 
		(
			[DeathFuneralHomeId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]
	END

GO 