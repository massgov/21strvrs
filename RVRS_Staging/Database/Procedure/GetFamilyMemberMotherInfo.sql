USE [RVRS_Staging]
GO

/****** Object:  StoredProcedure [RVRS].[GetFamilyMemberMotherInfo]    Script Date: 9/17/2021 1:13:13 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Foyzur Rahman>
-- Create date: <06/15/2021>
-- Description:	<This StoredProcedure use to generate SSIS package Extract_Death_FamilyMembers.dtsx>
-- =============================================
CREATE PROCEDURE [RVRS].[GetFamilyMemberMotherInfo] 
	-- Add the parameters for the stored procedure here

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
SET NOCOUNT ON;

    -- Insert statements for procedure here
--  *********Main Code Mother
SELECT 1 AS FamilyMemberTypeID,DEATH_REC_ID,
CASE MOTHER_NME_UNK
  WHEN 'Y' THEN 1
  ELSE 0
END
MOTHER_NME_UNK,MOTHER_GNAME,MOTHER_MNAME,MOTHER_LNAME,MOTHER_SUFF,MOTHER_LNAME_PRIOR,C.VT_COUNTRY_ID,S.VT_STATE_ID
FROM RVRS.Death D JOIN [RVRS].[State] S ON S.Name = RTRIM(D.MOTHER_BSTATE) JOIN [RVRS].[Country] C ON C.Country = RTRIM(D.MOTHER_BCOUNTRY)  ;

END
GO


