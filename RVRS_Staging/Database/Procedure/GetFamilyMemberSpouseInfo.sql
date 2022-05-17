USE [RVRS_Staging]
GO

/****** Object:  StoredProcedure [RVRS].[GetFamilyMemberSpouseInfo]    Script Date: 9/17/2021 1:14:22 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This StoredProcedure use to generate SSIS package Extract_Death_FamilyMembers.dtsx>
-- =============================================
CREATE PROCEDURE [RVRS].[GetFamilyMemberSpouseInfo] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
--  *********Main Code Spouse  NO state,country info
SELECT 3 AS FamilyMemberTypeID,DEATH_REC_ID,
CASE SPOUSE_NAME_UNK
  WHEN 'Y' THEN 1
  ELSE 0
END
SPOUSE_NAME_UNK,SPOUSE_GNAME,SPOUSE_MNAME,SPOUSE_LNAME,SPOUSE_SUFFIX,SPOUSE_LNAME_PRIOR FROM RVRS.Death  ;

END
GO


