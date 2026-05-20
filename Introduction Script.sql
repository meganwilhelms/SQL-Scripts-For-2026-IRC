--Result set is a table of the first ten rows (indicated by Top 10) and all columns (indicated by *) of the candidacy table
--TmsEPrd is the database name
--dbo is the default schema name that most tables exist in
--candidacy is the table name
SELECT Top 10 * 
FROM TmsEPrd.dbo.candidacy

--Result set is a table with all columns (indicated by *) of the candidacy_type_def table
SELECT *
FROM TmsEPrd.dbo.candidacy_type_def

--Result set is a table of the first ten rows (indicated by Top 10) and all columns (*) from both of the joined tables
--LEFT JOIN = Starting with ALL records that exist in the CANDIDACY table, add matching information from the candidacy_type_def table 
--The c after the candidacy table is the alias for this table, so the table name can be referenced in other areas of the query with a c instead of always writing the full name;
--The ctd after the candidacy_type_def table name is the alias for this table
SELECT Top 10 *
FROM TmsEPrd.dbo.candidacy c
		LEFT JOIN TmsEPrd.dbo.CANDIDACY_TYPE_DEF ctd ON c.CANDIDACY_TYPE=ctd.CANDIDACY_TYPE

--Result set is a table of the first ten rows (indicated by Top 10) and all columns (*) from both of the joined tables, 
--LEFT JOIN = Starting with ALL records that exist in the CANDIDACY table, add matching information from the candidacy_type_def table
--But only where the student candidacy year is 2025 and student candidacy term is 30
--The c after the candidacy table is the alias for this table, so the table name can be referenced in other areas of the query with a c instead of always writing the full name;
--The ctd after the candidacy_type_def table name is the alias for this table
SELECT Top 10 *
FROM TmsEPrd.dbo.candidacy c
	LEFT JOIN TmsEPrd.dbo.CANDIDACY_TYPE_DEF ctd ON c.CANDIDACY_TYPE=ctd.CANDIDACY_TYPE
WHERE c.yr_cde = 2025 AND c.trm_cde = '30'

--Result set is a table of the specified columns from each of the joined table, the alias in front of the column name indicates which table the column comes from
--LEFT JOIN = Starting with ALL records that exist in the CANDIDACY table, add matching information from the candidacy_type_def table
--But only where the student candidacy year is 2025 and student candidacy term is 30
--The c after the candidacy table is the alias for this table, so the table name can be referenced in other areas of the query with a c instead of always writing the full name;
--The ctd after the candidacy_type_def table name is the alias for this table
SELECT c.ID_NUM, c.YR_CDE, c.TRM_CDE, c.CANDIDACY_TYPE, ctd.CANDIDACY_TYP_DESC
FROM TmsEPrd.dbo.candidacy_v c
	LEFT JOIN TmsEPrd.dbo.CANDIDACY_TYPE_DEF ctd ON c.CANDIDACY_TYPE=ctd.CANDIDACY_TYPE
WHERE c.yr_cde = 2025 AND c.trm_cde = '30'

