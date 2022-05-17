-- drop table [RVRS].[Education]
-- sp_help '[RVRS].[Education]'
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[Education]') )
	BEGIN 
		CREATE TABLE [RVRS].[Education] (  
		   [EducationId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column 	 
		   [DimEducationId]INT NOT NULL CONSTRAINT [df_EducationDimEducationId] DEFAULT (0),	
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_EducationCreatedDate] DEFAULT (GETDATE()), -- RVRS Column	
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_EducationId] PRIMARY KEY CLUSTERED 
		(
			[EducationId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 