USE [RVRS_ODS]
GO

/****** Object:  Table [RVRS].[FamilyMembers]    Script Date: 9/17/2021 1:41:54 PM ******/
-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This Table uploads data by generate SSIS package Extract_Death_FamilyMembers.dtsx>
-- =============================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [RVRS].[FamilyMembers](
	[FamilyMemberID] [int] IDENTITY(1,1) NOT NULL,
	[FamilyMemberTypeID] [int] NOT NULL,
	[DeathID] [int] NOT NULL,
	[NameUnknown] [bit] NULL,
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Suffix] [varchar](25) NULL,
	[LastNamePrior] [varchar](50) NULL,
	[CountryOfBirthID] [int] NULL,
	[StateProvinceID] [int] NULL,
 CONSTRAINT [PK__FamilyMe__B7AD6DF38BA2D125] PRIMARY KEY CLUSTERED 
(
	[FamilyMemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [RVRS].[FamilyMembers] ADD  CONSTRAINT [DF__FamilyMem__NameU__160F4887]  DEFAULT ((0)) FOR [NameUnknown]
GO


