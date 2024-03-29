USE [RVRS_Staging]
GO
/****** Object:  StoredProcedure [RVRS].[Load_CountryCDPr]    Script Date: 11/8/2021 10:55:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE   PROCEDURE [RVRS].[Load_CountryCDPr]
	AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
DROP TABLE IF EXISTS #TEMP

 
CREATE TABLE #TEMP (
 ID INT IDENTITY (1,1),
 CODE VARCHAR(2) ,
 FIPSCODE VARCHAR (3),
 NCHSCODE TINYINT ,
 COUNTRYDESC VARCHAR(128),
 SRCVOID TINYINT
 )

 
INSERT INTO #TEMP ( CODE,FIPSCODE,NCHSCODE,COUNTRYDESC,SRCVOID)

	SELECT DISTINCT
	CASE WHEN CODE = 'ZZ' THEN  NULL ELSE  CODE  END  CODE,
	--[CODE] AS CODE,
	CASE WHEN FIPS_CODE = 'ZZ' THEN  NULL ELSE  [FIPS_CODE]  END  FIPS_CODE,
	[NUMERIC_NCHS_CODE] as NchsCode,
	[COUNTRY] as CountryDesc,
	[VOID] as SrcVoid
	FROM [RVRS].[VIP_VT_COUNTRY_CD]
	WHERE COUNTRY <> 'UNKNOWN'
	ORDER BY COUNTRY, FIPS_CODE
select * from #TEMP


INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DimCountry] 
	([DimCountryId],[CountryDesc],[SrcVoid])
	VALUES (0,'UNKNOWN', 0)

INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DimCountry] 
( DimCountryId, Code,FipsCode,NchsCode,CountryDesc,SrcVoid)
  SELECT 
	[ID] ,
	[CODE] ,
	FIPSCODE  ,
	NCHSCODE  ,
	[COUNTRYDESC] ,
	[SRCVOID] 
	FROM #TEMP
	

END



GO
