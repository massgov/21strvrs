--drop table [RVRS].[DivorcePerson]
--sp_help '[RVRS].[DivorcePerson]'
-- use RVRS_testdb

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO
 

IF NOT EXISTS (SELECT 1 FROM sys.Objects 
                WHERE object_id = OBJECT_ID('[RVRS].[DivorcePerson]') )
	BEGIN 
		CREATE TABLE [RVRS].[DivorcePerson] (  
		   [DivorcePersonId] BIGINT NOT NULL IDENTITY (1,1),  --  RVRS Column to store the		
		   [DivorceEventId] BIGINT NOT NULL,  --  FK ref to DivorceEvent	
		   [DimPersonTypeInternalId] INT NOT NULL CONSTRAINT [df_DivorcePersonDimPersonTypeInternalId] DEFAULT (0), -- RVRS Column to store the	PersonType - Wife, Husband, AParty, BParty
		   [FirstName] VARCHAR(128), --husband_first_name,wife_first_name,aparty_fname,bparty_fname
		   [MiddleName] VARCHAR(128), --aparty_mname, bparty_mname
		   [LastName] VARCHAR(128), --husband_last_name,wife_last_name,aparty_lname,bparty_lname
		   [BirthSurName] VARCHAR(128), --aparty_sname_birth, bparty_sname_birth
		   [UponDivorceSurName] VARCHAR(128), --aparty_sname_upon_div, bparty_sname_upon_div
		   [DimSexId] INT NOT NULL CONSTRAINT [df_DivorcePersonDimSexId] DEFAULT (0), --aparty_sex_id, bparty_sex_id
		   [BirthYear] DECIMAL(4,0) NULL, --Year(her_dob),Year(his_dob),Year(bparty_dob),Year(aparty_dob)
		   [BirthMonth] DECIMAL(2,0) NULL, --Month(her_dob),Month(his_dob),Month(bparty_dob),Month(aparty_dob)
		   [BirthDay] DECIMAL(2,0) NULL, --Day(her_dob),Day(his_dob),Day(bparty_dob),Day(aparty_dob)			
		   [AgeYear] DECIMAL (4,0) NULL,  --her_age, his_age		
		   [Ssn] VARCHAR(11) NULL,--aparty_ssn, bparty_ssn
		   [NumberOfMarriage] TINYINT NULL, --husband_no_of_marriage, wife_no_of_marriage, bparty_mar_num
		   [NumberOfMinorChild] TINYINT NULL, --aparty_num_minor_child, bparty_num_minor_child
		   [DimDivorceeTypeId] INT NOT NULL CONSTRAINT [df_DivorcePersonDimDivorceeTypeId] DEFAULT (0),--docket_number_plantiff_id, aparty_type_id, bparty_type_id
		   [CreatedDate] DATETIME NOT NULL CONSTRAINT [df_DivorcePersonCreatedDate] DEFAULT (GETDATE()), -- RVRS Column to store the created date 
		   [LoadNote] VARCHAR(MAX)
		CONSTRAINT [pk_DivorcePersonId] PRIMARY KEY CLUSTERED 
		(
			[DivorcePersonId] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
		) ON [PRIMARY]

		
	
	
END 