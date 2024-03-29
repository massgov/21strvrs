USE [RVRS_Staging]
GO
/****** Object:  StoredProcedure [RVRS].[Load_StateCDPr]    Script Date: 11/8/2021 10:55:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [RVRS].[Load_StateCDPr]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
DROP TABLE IF EXISTS #TEMP

 
CREATE TABLE #TEMP (
 ID INT IDENTITY (1,1),
 COUNTRYId INT,
 NCHSCODE VARCHAR(2) ,
  FIPSCODE VARCHAR (3),
 ALPHAFIPSCODE VARCHAR (3) ,
STATEDESC VARCHAR(128),
 SRCVOID TINYINT )

 INSERT INTO #TEMP ( COUNTRYId,NCHSCODE,FIPSCODE,ALPHAFIPSCODE,STATEDESC,SRCVOID)

	SELECT DISTINCT
	C.DimCountryId AS COUNTRYId,
	S.NCHS_CODE AS NchsCode,
	S.NUMERIC_FIPS_CODE as FipsCode,
	S.ALPHA_FIPS_CODE as AlphaFipsCode,
	S.NAME as StateDesc,
	S.[VOID] as SrcVoid
	FROM [RVRS].[VIP_VT_STATE_CD] S, [RVRS_PROD].[RVRS_ODS].[RVRS].[DimCountry] C
	where 
	S.COUNTRY = C.CountryDesc
	order by COUNTRYId
 
 
	INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DimState]
	([DimStateID],StateDesc,[SrcVoid])
	VALUES (0,'UNKNOWN', 0)

	INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DimState] ( DimStateID,DimCountryId,NchsCode,FipsCode,AlphaFipsCode,StateDesc,SrcVoid)
  SELECT 
	[ID] ,
	COUNTRYId,
	CASE WHEN NCHSCODE = 99 THEN  NULL ELSE  NCHSCODE  END  NCHSCODE,
	CASE WHEN FIPSCODE = 99 THEN  NULL ELSE  FIPSCODE  END  FIPSCODE,
	CASE WHEN ALPHAFIPSCODE IN('ZZ' , 'XX') THEN  NULL ELSE  ALPHAFIPSCODE  END  ALPHAFIPSCODE,
	StateDesc ,
	[SRCVOID] 
	FROM #TEMP
	WHERE COUNTRYId <> 0

DROP TABLE  #TEMP

END
GO
