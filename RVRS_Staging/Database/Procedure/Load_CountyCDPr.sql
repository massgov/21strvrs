USE [RVRS_Staging]
GO
/****** Object:  StoredProcedure [RVRS].[Load_CountyCDPr]    Script Date: 11/8/2021 10:55:07 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [RVRS].[Load_CountyCDPr]
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
 CountryID INT,
 StateID INT,
 State varchar(128),
 FIPSCODE VARCHAR (3),
 NCHSCODE VARCHAR(3) ,
 COUNTYDESC VARCHAR(128),
 SRCVOID TINYINT )


INSERT INTO #TEMP (CountryID, StateID, State,FIPSCODE,NCHSCODE,COUNTYDESC,SRCVOID)

SELECT DISTINCT
	CASE WHEN A.STATE = 'VIRGIN ISLANDS'  THEN '280' ELSE  DimCountryId  END  DimCountryId,
	CASE WHEN A.STATE = 'VIRGIN ISLANDS'  THEN '51' ELSE  DimStateID  END  DimStateID,
	CASE WHEN A.STATE = 'VIRGIN ISLANDS'  THEN 'VIRGIN ISLANDS, U.S.' ELSE  A.STATE END STATE ,
	A.FIPS_CODE,
	A.NCHS_COUNTY_CODE,
	A.COUNTY_NAME,
	A.[VOID] as SrcVoid
    FROM [RVRS].[VIP_VT_COUNTY_CD] A
	LEFT JOIN [RVRS_PROD].[RVRS_ODS].[RVRS].[DimState] S ON
	A.STATE = S.StateDesc
	WHERE 
	A.COUNTY_NAME <> 'NULL'	AND
	DimCountryId <> 0 OR
	A.State  NOT IN ('NULL','VOID', 'UNKNOWN') 
	order by DimCountryId

	
INSERT INTO  [RVRS_PROD].[RVRS_ODS].[RVRS].[DimCounty]
	([DimCountyId],CountyDesc,[SrcVoid])
	VALUES (0,'UNKNOWN', 0)

INSERT INTO [RVRS_PROD].[RVRS_ODS].[RVRS].[DimCounty] ( DimCountyId,DimCountryId,DimStateId,FipsCode,NchsCode,CountyDesc,SrcVoid)
	
	SELECT DISTINCT
	A.[ID] ,
	A.CountryId,
	A.StateID,
	A.FIPSCODE,
	A.NCHSCODE ,
	A.COUNTYDESC,
	A.SrcVoid
	FROM #TEMP A
	
END
GO
