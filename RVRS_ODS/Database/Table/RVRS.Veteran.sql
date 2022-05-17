--drop table [RVRS].[Veteran]
--sp_help '[RVRS].[Veteran]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Veteran]') )
	BEGIN 
		CREATE TABLE [RVRS].[Veteran] (  
		   [VeteranId] BIGINT NOT NULL IDENTITY (1,1),--  RVRS Column to store the
		   [PersonId] BIGINT NOT NULL ,  --  RVRS Column to store the	
		   [Order] TINYINT NOT NULL, -- value 1 or 2 or 3
		   [DimWarId] INT NOT NULL CONSTRAINT [df_VeteranDimWarId] DEFAULT (0), --VET1_WAR, 2 , 3 		  
		   [DimWarOtherId] INT NOT NULL CONSTRAINT [df_VeteranDimWarOtherId] DEFAULT (0), --VET1_WAR, 2 , 3 
		   [DimArmyBranchId] INT NOT NULL CONSTRAINT [df_VeteranDimWarBranchId] DEFAULT (0), --VET1_BRANCH,2,3	
		   [RankOrgOutFit] VARCHAR(128) NULL, --VET1_ORG,2,3
		   [DateEntered] DATETIME NULL, --VET1_DATE_ENTERED
		   [DateDischarged] DATETIME NULL, --VET1_DATE_DISCHARGED
		   [ServiceNumber] VARCHAR(32) NULL, --VETR1_SERVICE_NUM
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_VeteranCreatedDate] DEFAULT (GETDATE()) -- RVRS Column to store the 		   
		CONSTRAINT [pk_VeteranId] PRIMARY KEY CLUSTERED 
		(
			[VeteranId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

END 