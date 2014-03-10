GO
USE [BHSDB];
GO


go

ALTER PROCEDURE dbo.stp_RPT10_LOADBALANCING_NORMAL
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @INTERVAL INT,--MINUTES
		  @SUBSYSTEM VARCHAR(MAX)
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;

	DECLARE @INTERVAL_END DATETIME=GETDATE();
	DECLARE @INTERVAL_START DATETIME=DATEADD(MINUTE,-@INTERVAL,@INTERVAL_END);

	--Create temp table for final result
	CREATE TABLE #LB_NORMAL_SUBSYSTEM_TEMP
	(
		SUBSYSTEM_TYPE VARCHAR(30),
		SUBSYSTEM VARCHAR(20),
		TOTAL_BAGS INT,
		CRT_INTERVAL_LOAD INT
	);

	--1. count the bags for EDS line
	INSERT INTO #LB_NORMAL_SUBSYSTEM_TEMP
	SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, COUNT(DISTINCT ITI.GID) AS TOTAL_BAGS, NULL AS CRT_INTERVAL_LOAD
	FROM	MIS_SubsystemCatalog SC
	INNER JOIN LOCATIONS LOC ON SC.DETECT_LOCATION=LOC.LOCATION
	LEFT JOIN ITEM_TRACKING ITI WITH(NOLOCK)
		ON LOC.LOCATION_ID=ITI.LOCATION 
		AND ITI.TIME_STAMP BETWEEN @DTFROM AND @DTTO 
	WHERE  (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
		AND SC.SUBSYSTEM_TYPE='EDS'
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
		--AND SC.MDS_DATA=0
	GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM

	--2. count the current interval load for EDS
	UPDATE LNST
	SET LNST.CRT_INTERVAL_LOAD=CRT_LOAD.CRT_INTERVAL_LOAD
	FROM
	(
		SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, COUNT(DISTINCT ITI.GID) AS CRT_INTERVAL_LOAD
		FROM	MIS_SubsystemCatalog SC
		INNER JOIN LOCATIONS LOC ON SC.DETECT_LOCATION=LOC.LOCATION
		LEFT JOIN ITEM_TRACKING ITI WITH(NOLOCK)
			ON LOC.LOCATION_ID=ITI.LOCATION 
			AND ITI.TIME_STAMP BETWEEN @INTERVAL_START AND @INTERVAL_END
		WHERE  (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
			AND SC.SUBSYSTEM_TYPE='EDS'
			AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
			--AND SC.MDS_DATA=0
		GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM
	) AS CRT_LOAD,#LB_NORMAL_SUBSYSTEM_TEMP LNST
	WHERE CRT_LOAD.SUBSYSTEM_TYPE=LNST.SUBSYSTEM_TYPE AND CRT_LOAD.SUBSYSTEM=LNST.SUBSYSTEM
		AND LNST.CRT_INTERVAL_LOAD IS NULL;

	--3. count the total bags for normal subsystems by item_proceed
	INSERT INTO #LB_NORMAL_SUBSYSTEM_TEMP
	SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, COUNT(DISTINCT IPR.GID) AS TOTAL_BAGS, NULL AS CRT_INTERVAL_LOAD
	FROM	MIS_SubsystemCatalog SC,
			ITEM_PROCEEDED IPR, 
			LOCATIONS LOC 
			WITH(NOLOCK)
	WHERE SC.DETECT_LOCATION=LOC.LOCATION
		AND LOC.LOCATION_ID=IPR.PROCEED_LOCATION
		AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
		AND IPR.TIME_STAMP BETWEEN @DTFROM AND @DTTO 
		AND NOT EXISTS(SELECT * FROM #LB_NORMAL_SUBSYSTEM_TEMP LNST WHERE LNST.SUBSYSTEM=SC.SUBSYSTEM)
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
		--AND SC.MDS_DATA=0
	GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM

	--4. count the current interval load for normal subsystems by item_proceed
	UPDATE LNST
	SET LNST.CRT_INTERVAL_LOAD=CRT_LOAD.CRT_INTERVAL_LOAD
	FROM 
	(
		SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM,COUNT(DISTINCT IPR.GID) AS CRT_INTERVAL_LOAD
		FROM MIS_SubsystemCatalog SC, ITEM_PROCEEDED IPR, LOCATIONS LOC WITH(NOLOCK)
		WHERE SC.DETECT_LOCATION=LOC.LOCATION
			AND LOC.LOCATION_ID=IPR.PROCEED_LOCATION
			AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
			AND IPR.TIME_STAMP BETWEEN @INTERVAL_START AND @INTERVAL_END
			--AND SC.MDS_DATA=0
		GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM
	) AS CRT_LOAD,#LB_NORMAL_SUBSYSTEM_TEMP LNST
	WHERE CRT_LOAD.SUBSYSTEM_TYPE=LNST.SUBSYSTEM_TYPE AND CRT_LOAD.SUBSYSTEM=LNST.SUBSYSTEM
		AND LNST.CRT_INTERVAL_LOAD IS NULL;
		

	--5. count the total bags for normal subsystems by MDS_BAG_COUNT
	INSERT INTO #LB_NORMAL_SUBSYSTEM_TEMP
	SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM, SUM(MBC.DIFFERENT) AS TOTAL_BAGS, NULL AS CRT_INTERVAL_LOAD
	FROM MIS_SubsystemCatalog SC, MDS_BAG_COUNT MBC, MDS_BAG_COUNTERS MBCR WITH(NOLOCK)
	WHERE MBCR.LOCATION=DBO.RPT_FORMAT_LOCATION(SC.DETECT_LOCATION)
		AND MBCR.COUNTER_ID=MBC.COUNTER_ID
		AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
		AND MBC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		AND NOT EXISTS(SELECT * FROM #LB_NORMAL_SUBSYSTEM_TEMP LNST WHERE LNST.SUBSYSTEM=SC.SUBSYSTEM)
		AND MBCR.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@SUBSYSTEM))
		--AND SC.MDS_DATA=1 
	GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM

	--6. count the current interval load for normal subsystems by MDS_BAG_COUNT
	--current interval is from nowtime-interval to nowtime ?????
	UPDATE LNST
	SET LNST.CRT_INTERVAL_LOAD=CRT_LOAD.CRT_INTERVAL_LOAD
	FROM 
	(
		SELECT SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM,SUM(MBC.DIFFERENT) AS CRT_INTERVAL_LOAD
		FROM MIS_SubsystemCatalog SC, MDS_BAG_COUNT MBC, MDS_BAG_COUNTERS MBCR
		WHERE MBCR.LOCATION=DBO.RPT_FORMAT_LOCATION(SC.DETECT_LOCATION)
			AND MBCR.COUNTER_ID=MBC.COUNTER_ID
			AND (SC.DETECT_LOCATION IS NOT NULL OR SC.DETECT_LOCATION<>'')
			AND MBC.TIME_STAMP BETWEEN @INTERVAL_START AND @INTERVAL_END
			--AND SC.MDS_DATA=1 
		GROUP BY SC.SUBSYSTEM_TYPE,SC.SUBSYSTEM
	) AS CRT_LOAD,#LB_NORMAL_SUBSYSTEM_TEMP LNST
	WHERE CRT_LOAD.SUBSYSTEM_TYPE=LNST.SUBSYSTEM_TYPE AND CRT_LOAD.SUBSYSTEM=LNST.SUBSYSTEM
		
	
	SELECT * FROM #LB_NORMAL_SUBSYSTEM_TEMP
	ORDER BY SUBSYSTEM_TYPE,SUBSYSTEM;
		 
END

--DECLARE @DTFrom [datetime]='2014-1-1';
--DECLARE @DTTo [datetime]='2014-1-3';
--DECLARE @INTERVAL INT =60;
--DECLARE @SUBSYSTEM VARCHAR(MAX)='ED1,ED2,ED3,ED4,ML01,ML02,ML03,ML04,MU,ME1,ME2,ME3';
--EXEC stp_RPT10_LOADBALANCING_NORMAL @DTFROM,@DTTO,@INTERVAL,@SUBSYSTEM;