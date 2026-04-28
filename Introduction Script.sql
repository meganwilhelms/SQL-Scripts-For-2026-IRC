--Result set is a table of the first ten rows and all columns of the candidacy_v table
SELECT Top 10 * 
FROM TmsEPrd.dbo.candidacy

--Result set is a table with all columns of the candidacy_type_def table
SELECT *
FROM TmsEPrd.dbo.candidacy_type_def

--Result set is a table of the first ten rows and all columns from both of the joined tables
SELECT Top 10 *
FROM TmsEPrd.dbo.candidacy c
		LEFT JOIN TmsEPrd.dbo.CANDIDACY_TYPE_DEF ctd ON c.CANDIDACY_TYPE=ctd.CANDIDACY_TYPE

--Result set is a table of the first ten rows and all columns from both of the joined tables, but only where the rows are 2025 and 30 (fall)
SELECT Top 10 *
FROM TmsEPrd.dbo.candidacy_v c
	LEFT JOIN TmsEPrd.dbo.CANDIDACY_TYPE_DEF ctd ON c.CANDIDACY_TYPE=ctd.CANDIDACY_TYPE
WHERE c.yr_cde = 2025 AND c.trm_cde = '30'

--Result set is a table of the specified columns from the joined tables, where the rows are for year 2025 and term 30 (fall)
SELECT c.ID_NUM, c.YR_CDE, c.TRM_CDE, c.CANDIDACY_TYPE, ctd.CANDIDACY_TYP_DESC
FROM TmsEPrd.dbo.candidacy_v c
	LEFT JOIN TmsEPrd.dbo.CANDIDACY_TYPE_DEF ctd ON c.CANDIDACY_TYPE=ctd.CANDIDACY_TYPE
WHERE c.yr_cde = 2025 AND c.trm_cde = '30'
