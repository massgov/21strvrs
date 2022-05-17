USE [RVRS_ODS]
GO

/****** Object:  Table [RVRS].[FamilyMemberType]    Script Date: 9/17/2021 1:42:15 PM ******/
-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This Table information use to uploads data in [RVRS].[FamilyMembers] by generate SSIS package Extract_Death_FamilyMembers.dtsx>
-- =============================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [RVRS].[FamilyMemberType](
	[FamilyMemberTypeID] [int] NOT NULL,
	[FamilyMemberTypeDesc] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[FamilyMemberTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


