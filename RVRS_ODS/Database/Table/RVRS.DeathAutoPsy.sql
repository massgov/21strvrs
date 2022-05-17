-- drop table [RVRS].[DeathAutoPsy]
-- sp_help '[RVRS].[DeathAutoPsy]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DeathAutoPsy]') )
	BEGIN 
		CREATE TABLE [RVRS].[DeathAutoPsy] (  
		   [DeathAutoPsyId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 	 
		   [DimMedicalExaminerContactedId]INT NOT NULL CONSTRAINT [df_DeathAutoPsyDimMedicalExaminerContactedId] DEFAULT (0), --ME_CR_CONT	
		   [DimAutoPysPerformedId]INT NOT NULL CONSTRAINT [df_DeathAutoPsyDimAutoPysPerformedId] DEFAULT (0),	 --AUTOPSY
		   [DimFindingAvailableId]INT NOT NULL CONSTRAINT [df_DeathAutoPsyDimFindingAvailableId] DEFAULT (0),	 --AUTOPSY_F_AVAIL
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DeathAutoPsyCreatedDate] DEFAULT (GETDATE()), -- RVRS Column 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DeathAutoPsyId] PRIMARY KEY CLUSTERED 
		(
			[DeathAutoPsyId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 