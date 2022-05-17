-- drop table [RVRS].[DeathCause]
-- sp_help '[RVRS].[DeathCause]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathCause]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathCause] (  
		   [DeathCauseId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 
		   [CauseOrder] VARCHAR(16) NOT NULL, --Value = A or B or C or D or OTHER
		   [Cause] VARCHAR (512) NOT NULL,
		   [DimDeathCauseUnitId] INT NOT NULL CONSTRAINT [df_DeathCauseDimDeathCauseUnitId] DEFAULT (0),
		   [DimDeathCauseIntervalId] INT NOT NULL CONSTRAINT [df_DeathCauseDimDeathCauseIntervalId] DEFAULT (0),
		   [OtherCause] VARCHAR (512) NULL,		  
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathCauseCreatedDate] DEFAULT (GETDATE()), -- RVRS Column	
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathCauseId] PRIMARY KEY CLUSTERED 
		(
			[DeathCauseId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 