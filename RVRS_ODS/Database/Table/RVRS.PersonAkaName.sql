-- drop table [RVRS].[PersonAkaName]
-- sp_help '[RVRS].[PersonAkaName]'
-- select * from [RVRS].[PersonAkaName]
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[PersonAkaName]') )
	BEGIN 
		CREATE TABLE [RVRS].[PersonAkaName] (  
		   [PersonAkaNameId] BIGINT NOT NULL IDENTITY (1,1),
		   [PersonId] BIGINT NOT NULL,  --  RVRS Column to store the
		   [AkaOrder] TINYINT NOT NULL, -- (1,2,3,4)
		   [FirstName] VARCHAR(128) NULL,  --AKA1_FNAME
		   [MiddleName] VARCHAR(128) NULL,   --AKA1_MNAME
		   [LastName] VARCHAR(128) NULL,  --AKA1_LNAME 
		   [DimSuffixId]INT NOT NULL CONSTRAINT [df_PersonAkaNameDimSuffixId] DEFAULT (0),--SUFF		
		   [NameChangedDate] DateTime NULL,
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_PersonAkaNameCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the 	
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_PersonAkaNameId] PRIMARY KEY CLUSTERED 
		(
			[PersonAkaNameId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 