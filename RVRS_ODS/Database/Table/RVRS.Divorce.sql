--drop table [RVRS].[Divorce]
--sp_help '[RVRS].[Divorce]'
-- use RVRS_testdb

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Divorce]') )
	BEGIN 
		CREATE TABLE [RVRS].[Divorce] (  
		   [DivorceId] BIGINT NOT NULL IDENTITY (1,1),  --  RVRS Column to store the		
		   [DivorceEventId] BIGINT NOT NULL,  --  FK of Event
		   [JudgementYear] DECIMAL (4,0) NULL, --doj
		   [JudgementMonth] DECIMAL (2,0) NULL, --doj
		   [JudgementDay] DECIMAL (2,0) NULL, --doj
		   [MarriageYear] DECIMAL (4,0) NULL, --date_of_marriage,dom
		   [MarriageMonth] DECIMAL (2,0) NULL, --date_of_marriage,dom
		   [MarriageDay] DECIMAL (2,0) NULL, --date_of_marriage,dom
           [NumberOfMinorChild] DECIMAl(2,0) NULL, --number_of_children_under_18
		   [NumberOfChild] DECIMAl(2,0)  NULL , --num_child
		   [DimDivorceCauseId] INT NOT NULL CONSTRAINT [df_DivorceDimDivorceCauseId]  DEFAULT ((0)), --cause_for_which_granted_id
		   [DimJudgementTypeId] INT NOT NULL CONSTRAINT [df_DivorceDimJudgementTypeId]  DEFAULT ((0)),--jud_type_id
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DivorceCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DivorceId] PRIMARY KEY CLUSTERED 
		(
			[DivorceId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 