--drop table [RVRS].[FamilyMember]
--sp_help '[RVRS].[FamilyMember]'
-- SELECT * from [RVRS].[FamilyMember]

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[FamilyMember]') )
	BEGIN 
		CREATE TABLE [RVRS].[FamilyMember] (  
		    [FamilyMemberId] BIGINT NOT NULL IDENTITY (1,1),  --  RVRS Column to store the		
			[PersonId] BIGINT NOT NULL,  --  RVRS Column 
		    [FirstName] VARCHAR(128), --INFO_NME
		    [MiddleName] VARCHAR(128), --INFO_MIDD_NME		  
		    [LastName] VARCHAR(128), --INFO_LST_NME
			[LastNamePrior] VARCHAR(128), --SPOUSE_LNAME_PRIOR
			[DimFamilyTypeInternalId] INT NOT NULL CONSTRAINT [df_FamilyMemberDimFamilyTypeInternalId] DEFAULT (0), 	--Spouse, Father, Mother
            [DimSuffixId] INT NOT NULL CONSTRAINT [df_FamilyMemberDimSuffixId] DEFAULT (0), -- INFO_SUFFIX
		    [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_FamilyMemberCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
			[LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_FamilyMemberId] PRIMARY KEY CLUSTERED 
		(
			[FamilyMemberId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 