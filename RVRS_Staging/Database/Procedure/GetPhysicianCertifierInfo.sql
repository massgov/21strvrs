USE [RVRS_Staging]
GO

/****** Object:  StoredProcedure [RVRS].[GetPhysicianCertifierInfo]    Script Date: 9/17/2021 1:20:42 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This StoredProcedure use to generate SSIS package Extract_Death_Physician.dtsx>
-- =============================================
CREATE PROCEDURE [RVRS].[GetPhysicianCertifierInfo] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
--  *********Certifier 
select DEATH_REC_ID,1 as PhysicianTypeID,CERT_GNAME,CERT_MNAME,CERT_LNAME,CERT_SUFF,
CERT_CONTACT,CERT_CONTACT_INFO,CERT_LIC_NUM,CERT_NPI_NUM  FROM [RVRS].[Death]  ;

END
GO


