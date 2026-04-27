/*This query creates a dataset of students for the term and variables useful for different reports
Created by: Megan Wilhelms
Date:  September 2025 		
NOTE: If this script is being created as a report in Infomaker, the useful retrieval arguments are TERM_START_DATE, YEAR, and TERM
*/
DECLARE @TermStartDate DATE = '8/26/2025'; --Change this date to the first date of the semester
DECLARE @Term char(2) = '30'; --Change this to the number representing the semester
DECLARE @YEAR char(4) = '2025'; --Change this to the year representing the semester

 --CTE: DETERMINES PELL STATUS FOR THIS TERM
 WITH DistinctPell AS ( 
  SELECT pfsa.ID_NUM, pffcm.FUND_DESC, pfpd.POE_DESC, pfpd.POE_START_DTE
  FROM TmsEPrd.dbo.PF_STDNT_AWARD pfsa
		LEFT JOIN TmsEPrd.dbo.PF_FUND_CDE_MSTR pffcm ON pfsa.FUND_CDE = pffcm.FUND_CDE
		LEFT JOIN TmsEPrd.dbo.PF_POE_DEF pfpd ON pfsa.POE_ID = pfpd.POE_ID
  WHERE pffcm.fund_cde = '773' AND pfpd.POE_START_DTE = @TermStartDate 
  ),

--CTE: CALCULATES AGE BASED ON THE AGE OF THE STUDENT ON THE FIRST DAY OF THE TERM
CalculatedAge AS ( 
	SELECT bm.ID_NUM,
	DATEDIFF(year, bm.BIRTH_DTE, @TermStartDate) - 
		CASE
			WHEN MONTH(@TermStartDate)<MONTH(bm.birth_dte) OR 
			(MONTH(@TermStartDate) = MONTH(bm.BIRTH_DTE) AND DAY(@TermStartDate) < DAY(bm.BIRTH_DTE)) 
        THEN 1
        ELSE 0
    END AS Age
	FROM TmsEPrd.dbo.BIOGRAPH_MASTER bm
	),

--CTE: CREATES ONE TRIBAL AFFILIATION PER STUDENT
DistrictTribal AS( 
  SELECT DISTINCT stsd.id_num, stsd.yr_cde,  stsd.trm_cde, tad.tribal_code, tad.descr  
    FROM TmsEPrd.dbo.stud_term_sum_div stsd
			LEFT JOIN TmsEPrd.dbo.tribal_information ti ON stsd.id_num = ti.id_num,   
        	TmsEPrd.dbo.tribal_affiliation_def tad  
   WHERE (ti.tribal_affiliation_def_appid = tad.appid) and  
         (stsd.yr_cde = @YEAR AND stsd.trm_cde = @Term) AND ti.current_flag = 'Y' 
), 

--CTE: Creates info on candidacy type that can be assigned a value on the final end  query
DistinctCandidacy AS (
  SELECT cv.ID_NUM, cv.yr_cde, cv.trm_cde, cv.candidacy_type, ctd.candidacy_typ_desc
    FROM TmsEPrd.dbo.candidacy_v cv, TMSEPrd.dbo.CANDIDACY_TYPE_DEF ctd
   WHERE ( cv.CANDIDACY_TYPE = ctd.CANDIDACY_TYPE ) AND (( cv.yr_cde = @YEAR ) AND  ( cv.trm_cde = @Term )) 
		),
--Writing placement score based on ACCUP within the 5 years prior to term start date
DistinctWriting AS (
  SELECT tiv.idnumber, 
         tiv.testelementcode,   
         tiv.testscore, 
		 CASE	
			WHEN tiv.TestElementCode='WRITX' AND tiv.TestScore<=225 THEN 'ASC  087'
			WHEN tiv.TestElementCode='WRITX' AND tiv.TestScore>=226 THEN 'ENG  110/104'
		END AS WRITX_Placement,
         tiv.datetaken 
    FROM TmsEPrd.dbo.test_information_v  tiv
   WHERE tiv.TestElementCode='WRITX' AND ( tiv.testscore > 0 AND tiv.datetaken > DATEADD(year, -5, @TermStartDate) )  
),
--Math placement score based on ACCUP within the 5 years prior to term start date
DistinctMath AS (
  SELECT tiv.idnumber, 
         tiv.testelementcode,   
         tiv.testscore, 
	CASE	
			WHEN tiv.TestElementCode='ARITX' AND tiv.TestScore<=224 THEN 'ASC  090/091'
			WHEN tiv.TestElementCode='ARITX' AND (tiv.TestScore>=225 AND tiv.TestScore<=236) THEN 'ASC  091'
			WHEN tiv.TestElementCode='ARITX' AND (tiv.TestScore>=237 AND tiv.TestScore<=245) THEN 'MTH  101'
			WHEN tiv.TestElementCode='ARITX' AND (tiv.TestScore>=246 AND tiv.TestScore<=254) THEN 'MTH  102'
			WHEN tiv.TestElementCode='ARITX' AND tiv.TestScore>254 THEN 'MTH  103/104/210'
		END AS ARITX_Placement,
         tiv.datetaken 
    FROM TmsEPrd.dbo.test_information_v  tiv
   WHERE tiv.TestElementCode='WRITX' AND ( tiv.testscore > 0 AND tiv.datetaken > DATEADD(year, -5, @TermStartDate) )   
)


--FINAL END QUERY
 SELECT DISTINCT 
	stsd.div_cde, stsd.yr_cde, stsd.trm_cde, stsd.id_num,   
      --   nm.first_name, nm.middle_name, nm.last_name, --remove the two dashes at the beginning of this line to get the name columns to executed
--SCHOOL INFO SECTION
         stsd.major_1, stsd.major_2, mmd.major_minor_desc, stsd.degree_cde,
		 CASE
			WHEN stsd.DEGREE_CDE in ('AS', 'AAS') THEN 'Associate'
			WHEN stsd.DEGREE_CDE = 'BS' THEN 'Bachelor'
			WHEN stsd.DEGREE_CDE in ('CERT','DIPLM') THEN 'Certificate/Diploma'
			WHEN stsd.DEGREE_CDE = 'NON' THEN 'Non'
		 END AS Degree_Code_Name,
		 CASE 
			WHEN stsd.CAREER_HRS_EARNED<31 THEN 'Freshman'
			WHEN stsd.CAREER_HRS_EARNED BETWEEN 31 AND 60 THEN 'Sophomore'
			WHEN stsd.CAREER_HRS_EARNED BETWEEN 61 AND 90 THEN 'Junior'
			WHEN stsd.CAREER_HRS_EARNED>90 THEN 'Senior'
		 END AS Class_Level,
		 CASE 
			WHEN dc.CANDIDACY_TYP_DESC='Transfer Student' THEN 'Transfer'
			WHEN dc.CANDIDACY_TYP_DESC='New Student' THEN 'FTEIC'
			WHEN dc.CANDIDACY_TYP_DESC='Returning Student' THEN 'Returning'	
			WHEN dc.CANDIDACY_TYP_DESC='Dual Credit HS Student' THEN 'Dual Credit'
			ELSE 'Continuing'
		 END AS Term_Entrance_Type,
		 CASE
			WHEN dc.CANDIDACY_TYP_DESC='New Student' THEN 'New'
			WHEN dc.CANDIDACY_TYP_DESC='Transfer Student' THEN 'Transfer'
			WHEN dc.CANDIDACY_TYP_DESC='Dual Credit HS Student' THEN 'NON'
			WHEN stsd.DEGREE_CDE='NON' THEN 'NON'
			ELSE 'Cont/Return'
		END AS IPEDS_ENT,
         stsd.career_hrs_attempt, stsd.career_hrs_earned, stsd.hrs_enrolled, stsd.trm_hrs_attempt, stsd.trm_hrs_earned,  
         stsd.class_cde, stsd.num_of_crs, stsd.career_gpa, stsd.trm_gpa,
		CASE
			WHEN stsd.hrs_enrolled>=12 THEN 'F'
			WHEN stsd.hrs_enrolled<12 THEN 'P'
			ELSE 'Uk'
		END AS PT_FT_STS,
		DistinctMath.ARITX_Placement, 
		DistinctWriting.WRITX_Placement,
--DEMOGRAPHICS SECTION		
		ca.Age,		
		CASE 
			WHEN ca.Age<25 THEN '24 or Less'
			WHEN ca.Age BETWEEN 25 AND 29 THEN '25-29'
			WHEN ca.Age BETWEEN 30 AND 39 THEN '30-39'
			WHEN ca.Age>39 THEN '40 and Over'
		 END AS Age_Range,
		CASE 
			WHEN ca.Age<18 THEN 'Under 18'
			WHEN ca.Age BETWEEN 18 AND 24 THEN '18-24'
			WHEN ca.Age BETWEEN 25 AND 29 THEN '25-29'
			WHEN ca.Age BETWEEN 30 AND 39 THEN '30-39'
			WHEN ca.Age BETWEEN 40 AND 49 THEN '40-49'
			WHEN ca.Age>49 THEN '50 and Over'
		 END AS Age_Range2,
		 bm.birth_dte,
		FORMAT(CAST(bm.birth_dte as date), 'yyyyMMdd') AS formatted_dob,
		 bm.gender,
		CASE
			WHEN bm.gender = 'O' THEN null
			ELSE bm.gender
		END AS Sex,
		 bm.ethnic_group,  
		 CASE 
			WHEN bm.ETHNIC_GROUP = 1 THEN 'African American'
			WHEN bm.ETHNIC_GROUP = 2 THEN 'American Indian/Alaska Native'
			WHEN bm.ETHNIC_GROUP = 3 THEN 'Native Hawaiian/Pacific Islander'
			WHEN bm.ETHNIC_GROUP = 4 THEN 'Hispanic'
			WHEN bm.ETHNIC_GROUP = 5 THEN 'Caucasian'
			WHEN bm.ETHNIC_GROUP = 6 THEN 'Non-Resident'
			WHEN bm.ETHNIC_GROUP = 9 THEN 'Native/Not Enrolled'
			ELSE 'Needs filled in for sql'
		END AS Ethnic_Desc,
		CASE
			WHEN bm.ETHNIC_GROUP = 2 THEN 'Native American'
			WHEN bm.ETHNIC_GROUP = 9 THEN 'Non-Enrolled Native'
			WHEN bm.ETHNIC_GROUP in (1, 3, 4, 5, 6) THEN 'Non-Native'
			ELSE 'Needs filled in for sql'
		END AS Native_Ethnicity,
		ethnic_race_v.ethnic_rpt_desc,
		 DT.TRIBAL_CODE, 
		CASE
			WHEN dt.DESCR = 'Standing Rock Souix Tribe of ND and SD' THEN 'Standing Rock Sioux Tribe of ND and SD'
			ELSE dt.DESCR
		END AS Tribal_descr,
         sm.entrance_yr, sm.entrance_trm, bm.entrance_cde,   
         stsd.academic_honors, stsd.academic_probation, sm.cur_acad_honors, sm.cur_acad_probation,   
         bm.udef_1a_1 as First_Gen,   
         bm.marital_sts, 
	CASE
		WHEN bm.marital_sts in ('M') THEN 'Married'
		WHEN bm.marital_sts in ('D','S','N','W','P') THEN 'Single'
		ELSE 'Needs filled in for sql'
	END AS Marital_descr,
		 CASE 
			WHEN dp.FUND_DESC = 'FEDERAL PELL GRANT' THEN 'Yes'
			ELSE 'No'
		 END AS Pell,	
		 CASE
			WHEN bm.UDEF_11_2N_1 > 0 THEN 'Y'
			WHEN bm.UDEF_11_2N_1 = 0 THEN 'N'
		 END AS Has_Dependents,
         bm.udef_11_2n_1 AS Num_Dependents,
		 bm.disability_sts, bm.citizenship_sts, msm.VETERAN,
	CASE
		WHEN bm.UDEF_11_2N_1 > 0 AND bm.marital_sts in ('D','S','N','W','P','O') THEN 'Y' --UDEF_11_2N_1 is the # of dependents column
		ELSE 'N'
	END AS Single_Parent,
--PII SECTION		 
        /* nm.mobile_phone, bm.ssn,   
         nm.email_address, am.email_addr,
         am.addr_line_1, am.city, am.state, am.zip,     */ --remove the /* and */ for the three lines to get the PII to execute
         sm.tuition_cde,   
		 stsd.transaction_sts, 
         sm.appid,   
         sm.loc_cde   
    FROM TmsEPrd.dbo.stud_term_sum_div stsd  
         LEFT JOIN TmsEPrd.dbo.name_master nm ON stsd.ID_NUM = nm.ID_NUM   
         LEFT JOIN TmsEPrd.dbo.biograph_master bm ON stsd.ID_NUM = bm.ID_NUM
         LEFT JOIN TmsEPrd.dbo.address_master am ON stsd.ID_NUM = am.ID_NUM  
         LEFT JOIN TmsEPrd.dbo.student_master sm ON stsd.ID_NUM = sm.ID_NUM
		 LEFT JOIN DistinctPell dp ON stsd.ID_NUM = dp.ID_NUM
		 LEFT JOIN CalculatedAge ca ON stsd.ID_NUM=ca.ID_NUM
		 LEFT JOIN DistrictTribal dt ON stsd.ID_NUM=dt.ID_NUM
		 LEFT JOIN DistinctCandidacy dc ON stsd.ID_NUM = dc.ID_NUM
		LEFT JOIN TmsEPrd.dbo.major_minor_def mmd ON stsd.major_1 = mmd.major_cde
		LEFT JOIN TmsEPrd.dbo.MILITARY_SERVICE_MASTER msm ON stsd.ID_NUM = msm.ID_NUM
		LEFT JOIN DistinctWriting ON stsd.ID_NUM = DistinctWriting.idnumber
		LEFT JOIN DistinctMath ON stsd.ID_NUM = DistinctMath.idnumber
		LEFT JOIN TmsEPrd.dbo.ethnic_race_v ON stsd.ID_NUM=ethnic_race_v.id_num
   WHERE stsd.hrs_enrolled > '0' AND  am.addr_cde = '*LHP' AND stsd.YR_CDE=@YEAR AND stsd.TRM_CDE = @Term
