USE [RVRS_ODS]
GO

/****** Object:  Table [RVRS].[PhysicianType]    Script Date: 9/17/2021 1:42:35 PM ******/
-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This Table information use to uploads data in [RVRS].[Physician] by generate SSIS package Extract_Death_Physician.dtsx>
-- =============================================
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [RVRS].[PhysicianType](
	[PhysicianTypeID] [int] NOT NULL,
	[PhysicianTypeDesc] [varchar](50) NULL,
PRIMARY KEY CLUSTERED 
(
	[PhysicianTypeID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO


