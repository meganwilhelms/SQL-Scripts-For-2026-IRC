/*This query calculates the proportion of online courses the student is taking for the specified term. 
To run this query, the only values that should need updated are the two beginning DECLARE statements.
*/

DECLARE @YEAR char(4) = 2025; --CHANGE BASED ON THE YEAR
DECLARE @Term char(2) = '30'; --CHANGE BASED ON THE TERM


--CTE: GETTING DISTINCT COURSES PER STUDENT
WITH DistinctCourses AS (
	SELECT DISTINCT 
		sch.id_num, sch.crs_cde, sch.YR_CDE, sch.TRM_CDE
	FROM TmsEPrd.dbo.STUDENT_CRS_HIST sch, TmsEPrd.dbo.REG_CONFIG rg, TmsEPrd.dbo.STUDENT_MASTER sm
	WHERE sch.YR_CDE = @YEAR AND sch.TRM_CDE = @Term AND sch.ID_NUM=sm.ID_NUM AND 
		(rg.reg_config_cde = '1' AND  
		sch.transaction_sts in ('C', 'H', 'P', 'R', 'W') AND 
				(((sm.hold_1_cde is NULL OR sm.hold_1_cde = '') AND (sm.hold_2_cde is NULL OR sm.hold_2_cde = '') AND (sm.hold_3_cde is NULL OR sm.hold_3_cde = '') AND  
				(sm.hold_4_cde is NULL OR sm.hold_4_cde = '') AND (sm.hold_5_cde is NULL OR sm.hold_5_cde = '') AND (sm.hold_6_cde is NULL OR sm.hold_6_cde = '')) OR  
		rg.clas_lst_incl_hold = 'Y'))
	),
--CTE: CREATING TOTALS 
--     COUNT TOTALS FOR TOTAL COURSES THE STUDENT IS TAKING AND SUM TOTAL COURSES THE STUDENT IS TAKING WHERE THE SECTION IS OL (ONLINE) 
counts AS (
	SELECT id_num,
		COUNT(*) AS N,
		SUM(CASE WHEN dc.CRS_CDE LIKE '%OL' THEN 1 ELSE 0 END) AS number_ol
	FROM DistinctCourses dc
	GROUP BY ID_NUM
	),

--CTE: CALCULATES PROPORTION ONLINE
WithProportions AS (
	SELECT c.ID_NUM, c.N, c.number_ol,
	CAST(c.number_ol AS float) / NULLIF(c.N, 0) AS Proportion_Online
	FROM counts c
	)

--FINAL QUERY
SELECT ID_NUM, @YEAR AS Year, @Term AS Term, Proportion_Online,
		CASE 
            WHEN Proportion_Online = 1 THEN 'All Online'
            WHEN Proportion_Online > 0 AND Proportion_Online < 1 THEN 'Some Online'
            WHEN Proportion_Online = 0 THEN 'No Online'
        END AS Location
FROM WithProportions
