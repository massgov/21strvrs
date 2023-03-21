-- drop table [RVRS].[DeathAutopsy]
-- sp_help '[RVRS].[DeathAutopsy]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathAutopsy]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathAutopsy] (  
		   [DeathAutopsyId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 	 
		   [DimMedicalExaminerContactedId]INT NOT NULL CONSTRAINT [df_DeathAutopsyDimMedicalExaminerContactedId] DEFAULT (0), --ME_CR_CONT	
		   [DimAutopsyPerformedId]INT NOT NULL CONSTRAINT [df_DeathAutopsyDimAutopsyPerformedId] DEFAULT (0),	 --AUTOpsy
		   [DimFindingAvailableId]INT NOT NULL CONSTRAINT [df_DeathAutopsyDimFindingAvailableId] DEFAULT (0),	 --AUTOpsy_F_AVAIL
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathAutopsyCreatedDate] DEFAULT (GETDATE()), -- RVRS Column 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathAutopsyId] PRIMARY KEY CLUSTERED 
		(
			[DeathAutopsyId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 