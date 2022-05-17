USE [RVRS_ODS]
GO

/****** Object:  Table [RVRS].[Physician]    Script Date: 9/17/2021 1:42:26 PM ******/
-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This Table uploads data by generate SSIS package Extract_Death_Physician.dtsx>
-- =============================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [RVRS].[Physician](
	[PhysicianID] [int] IDENTITY(1,1) NOT NULL,
	[DeathID] [int] NULL,
	[PhysicianTypeID] [int] NULL,
	[FirstName] [varchar](50) NULL,
	[MiddleName] [varchar](50) NULL,
	[LastName] [varchar](50) NULL,
	[Suffix] [varchar](24) NULL,
	[PhoneNumber] [varchar](25) NULL,
	[FaxNumber] [varchar](25) NULL,
	[MedicalLicenseNumber] [varchar](20) NULL,
	[NPINumber] [varchar](10) NULL,
 CONSTRAINT [PK__Physicia__DFF5ED733ED4A518] PRIMARY KEY CLUSTERED 
(
	[PhysicianID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


