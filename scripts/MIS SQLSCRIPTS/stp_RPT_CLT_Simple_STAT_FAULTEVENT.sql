GO
USE [BHSDB_CLT_Demo];
GO

--Simple Bag Volume Statistics

alter PROCEDURE dbo.stp_RPT_CLT_Simple_STAT_FAULTEVENT
		  @DTFrom DATETIME,
		  @DTTo DATETIME
AS
BEGIN
	CREATE TABLE #TMP_STFE_FINAL
	(
		STATISTICS_TYPE VARCHAR(50),
		DOWN_TIME INT, -- SECOND
	)

	INSERT INTO #TMP_STFE_FINAL
	SELECT	CASE 
				WHEN RF.FAULT_USED=0 AND RF.FAULT_NAME!='AA_BJAM' AND RF.FAULT_NAME!='AA_FSAL' THEN 'Events'
				WHEN RF.FAULT_USED=1 AND RF.FAULT_NAME!='AA_BJAM' AND RF.FAULT_NAME!='AA_FSAL' THEN 'Faults'
				WHEN RF.FAULT_NAME='AA_BJAM' THEN 'Jams'
				WHEN RF.FAULT_NAME='AA_FSAL' THEN 'Fail Safe'
			END AS STATISTICS_TYPE,
			CASE
				WHEN ALM_ENDTIME IS NOT NULL THEN DATEDIFF(SECOND,ALM_STARTTIME,ALM_ENDTIME)
				ELSE 0
			END AS DOWN_TIME
	FROM	MDS_ALARMS MA, REPORT_FAULT RF WITH(NOLOCK)
	WHERE	MA.ALM_UNCERTAIN = 0
			AND MA.ALM_ALMAREA2 = RF.FAULT_NAME
			AND MA.ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 

	INSERT INTO #TMP_STFE_FINAL
	SELECT	'Lost in Track', 0 AS DOWN_TIME
	FROM	ITEM_LOST ILT WITH(NOLOCK)
	WHERE	ILT.TIME_STAMP BETWEEN @DTFrom AND @DTTo 

	SELECT STATISTICS_TYPE, COUNT(STATISTICS_TYPE) AS NUMBER, SUM(DOWN_TIME) AS DOWN_TIME, AVG(DOWN_TIME) AS AVG_TIME
	FROM #TMP_STFE_FINAL
	GROUP BY STATISTICS_TYPE
END

--DECLARE @DTFrom DATETIME = '2014-04-08'
--DECLARE @DTTo DATETIME = '2014-04-09'
--EXEC stp_RPT_CLT_Simple_STAT_FAULTEVENT @DTFrom,@DTTo