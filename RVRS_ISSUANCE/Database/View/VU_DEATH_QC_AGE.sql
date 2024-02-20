/*
NAME	: RVRS.VU_DEATH_QC_AGE
AUTHOR	: Naba Sarker
CREATED	: Dec   05 2023  
PURPOSE	: Reporting view for death data of RVRS Issuance DB

----------------------------------------------------------------------------------------------------------------------------------------------
Environment: SQL Server
Here Oracle view converted/transformed into SQL view. ENd of this view the Oracle view has been copied. 
*****************************************************************************************

*/
  CREATE VIEW "RVRS"."VU_DEATH_QC_AGE" ("FUNERAL_HOME", "DEATH_REC_ID", "SFN_NUM", "LAST_NAME", "DOB", "DEATH_DATE", "AGE_MEASURE", "CALCULATED_YEARS", "AGE_IN_YEARS", "AGE_IN_MONTHS", "AGE_IN_DAYS", "AGE_IN_HOURS", "AGE_IN_MINUTES", "AGE_BYPASS", "OCCUR_REGISTERED_FL") AS 
  (

   select X.FUNERAL_HOME,
          X.DEATH_REC_ID,
          X.SFN_NUM,
      X.LAST_NAME,
      X.DOB,
      X.DEATH_DATE,
      X.AGE_MEASURE,
      X.CALCULATED_YEARS,
      X.AGE_IN_YEARS,
      X.AGE_IN_MONTHS,
      X.AGE_IN_DAYS,
      X.AGE_IN_HOURS,
      X.AGE_IN_MINUTES,
      X.AGE_BYPASS,
      X.OCCUR_REGISTERED_FL

FROM  (select D.FH_RESPONSIBLE_NAME as FUNERAL_HOME,
    D.DEATH_REC_ID,
    D.SFN_NUM,
    D.LNAME as LAST_NAME,
    D.DOB,
    coalesce(D.DOD_4_FD,D.DOD) as DEATH_DATE,
    coalesce( A.AGE_LABEL, 'missing') as AGE_MEASURE,
    case
       when AGE1 is NULL and AGE1_CALC is NOT NULL then '*'
       when AGE1 <> AGE1_CALC then '*'
       else ' '
    end as CHECK_AGE_IN_YEARS,

    D.AGE1_CALC as CALCULATED_YEARS,
    D.AGE1 as AGE_IN_YEARS,
    D.AGE2 as AGE_IN_MONTHS,
    D.AGE3 as AGE_IN_DAYS,
    D.AGE4 as AGE_IN_HOURS,
    D.AGE5 as AGE_IN_MINUTES,
    D.AGE_BYPASS,
    D.OCCUR_REGISTERED_FL
FROM  RVRS.VIP_VRV_Death_Tbl      D
  left OUTER join RVRS.VIP_VT_Age_Type_CD A on (D.AGETYPE=A.AGE_TYPE_CODE and A.VOID=0)
where 
--trunc((sysdate - D.VRV_REC_DATE_CREATED)) < 10
   DATEDIFF(DAY, D.VRV_REC_DATE_CREATED, GETDATE()) < 10
   AND   D.FL_CURRENT=1
   AND   D.FL_VOIDED <> 1
   AND   D.FL_ABANDONED <>'Y' ) X

 WHERE x.CHECK_AGE_IN_YEARS = '*'
);


  

  /*

  Oracle view as below

  ********************************
  */

  /*
  
  
  CREATE OR REPLACE FORCE EDITIONABLE VIEW "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" ("FUNERAL_HOME", "DEATH_REC_ID", "SFN_NUM", "LAST_NAME", "DOB", "DEATH_DATE", "AGE_MEASURE", "CALCULATED_YEARS", "AGE_IN_YEARS", "AGE_IN_MONTHS", "AGE_IN_DAYS", "AGE_IN_HOURS", "AGE_IN_MINUTES", "AGE_BYPASS", "OCCUR_REGISTERED_FL") AS 
  (

   select X.FUNERAL_HOME,
          X.DEATH_REC_ID,
          X.SFN_NUM,
      X.LAST_NAME,
      X.DOB,
      X.DEATH_DATE,
      X.AGE_MEASURE,
      X.CALCULATED_YEARS,
      X.AGE_IN_YEARS,
      X.AGE_IN_MONTHS,
      X.AGE_IN_DAYS,
      X.AGE_IN_HOURS,
      X.AGE_IN_MINUTES,
      X.AGE_BYPASS,
      X.OCCUR_REGISTERED_FL

FROM  (select D.FH_RESPONSIBLE_NAME as FUNERAL_HOME,
    D.DEATH_REC_ID,
    D.SFN_NUM,
    D.LNAME as LAST_NAME,
    D.DOB,
    coalesce(D.DOD_4_FD,D.DOD) as DEATH_DATE,
    coalesce( A.AGE_LABEL, 'missing') as AGE_MEASURE,
    case
       when AGE1 is NULL and AGE1_CALC is NOT NULL then '*'
       when AGE1 <> AGE1_CALC then '*'
       else ' '
    end as CHECK_AGE_IN_YEARS,

    D.AGE1_CALC as CALCULATED_YEARS,
    D.AGE1 as AGE_IN_YEARS,
    D.AGE2 as AGE_IN_MONTHS,
    D.AGE3 as AGE_IN_DAYS,
    D.AGE4 as AGE_IN_HOURS,
    D.AGE5 as AGE_IN_MINUTES,
    D.AGE_BYPASS,
    D.OCCUR_REGISTERED_FL
FROM  MA_VRVWEB_EVENTS.VRV_DEATH_TBL      D
  left OUTER join MA_VRVWEB_VT.VT_AGE_TYPE A on (D.AGETYPE=A.AGE_TYPE_CODE and A.VOID=0)
where 
   trunc((sysdate - D.VRV_REC_DATE_CREATED)) < 10
   AND   D.FL_CURRENT=1
   AND   D.FL_VOIDED <> 1
   AND   D.FL_ABANDONED <>'Y' ) X

 WHERE x.CHECK_AGE_IN_YEARS = '*'
);


  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "NSARKER";
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO PUBLIC;
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "DSKALTSIS";
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "MWONG01";
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "MA_VRWEB_TOOLS";
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "BWOLDESENBET";
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "SPAGNANO";
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "DMATHER";
  GRANT DELETE ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "MA_RVRS_SCHEMA_RW" WITH GRANT OPTION;
  GRANT SELECT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "MA_RVRS_SCHEMA_RW" WITH GRANT OPTION;
  GRANT UPDATE ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "MA_RVRS_SCHEMA_RW" WITH GRANT OPTION;
  GRANT INSERT ON "MA_RVRS_SCHEMA"."VU_DEATH_QC_AGE" TO "MA_RVRS_SCHEMA_RW";

  */
