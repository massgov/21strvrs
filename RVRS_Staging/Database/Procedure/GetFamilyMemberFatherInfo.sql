USE [RVRS_Staging]
GO

/****** Object:  StoredProcedure [RVRS].[GetFamilyMemberFatherInfo]    Script Date: 9/17/2021 1:08:41 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This StoredProcedure use to generate SSIS package Extract_Death_FamilyMembers.dtsx>
-- =============================================
CREATE PROCEDURE [RVRS].[GetFamilyMemberFatherInfo] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
--  *********Main Code Father
SELECT 2 AS FamilyMemberTypeID,DEATH_REC_ID,
CASE FATHER_NME_UNK
  WHEN 'Y' THEN 1
  ELSE 0
END
FATHER_NME_UNK,FATHER_GNAME,FATHER_MNAME,FATHER_LNAME,FATHER_SUFF,FATHER_LNAME_PRIOR,C.VT_COUNTRY_ID,S.VT_STATE_ID
FROM RVRS.Death D JOIN [RVRS].[State] S ON S.Name = RTRIM(D.FATHER_BSTATE) JOIN [RVRS].[Country] C ON C.Country = RTRIM(D.FATHER_BCOUNTRY)  ;

END
GO


