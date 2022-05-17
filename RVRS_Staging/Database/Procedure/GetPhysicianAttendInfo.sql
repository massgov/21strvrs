USE [RVRS_Staging]
GO

/****** Object:  StoredProcedure [RVRS].[GetPhysicianAttendInfo]    Script Date: 9/17/2021 1:17:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This StoredProcedure use to generate SSIS package Extract_Death_Physician.dtsx>
-- =============================================
CREATE PROCEDURE [RVRS].[GetPhysicianAttendInfo] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
----    Attend  Physician
select DEATH_REC_ID,2 as PhysicianTypeID,ATTEND_PHYSICIAN_GNAME,ATTEND_PHYSICIAN_MNAME,ATTEND_PHYSICIAN_LNAME,ATTEND_PHYSICIAN_SUFFIX,
NP_ASSOCIATED_PHYSICIAN  FROM [RVRS].[Death]  ;

END
GO


