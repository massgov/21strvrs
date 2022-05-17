USE [RVRS_Staging]
GO

/****** Object:  StoredProcedure [RVRS].[GetPhysicianMCInfo]    Script Date: 9/17/2021 1:20:56 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This StoredProcedure use to generate SSIS package Extract_Death_Physician.dtsx>
-- =============================================
CREATE PROCEDURE [RVRS].[GetPhysicianMCInfo] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
------    Medical Examiner
select DEATH_REC_ID,3 as PhysicianTypeID,MC_NOTIFIED_GNAME,MC_NOTIFIED_MNAME,MC_NOTIFIED_LNAME,MC_NOTIFIED_SUFFIX,
MC_NOTIFIED_PHONE  FROM [RVRS].[Death]  ;

END
GO


