

GO
USE BHSDB;
GO



create PROCEDURE dbo.stp_RPT_CLT_INDIVIDUAL_EDS
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @SUBSYSTEM VARCHAR(20)
AS
BEGIN
	DECLARE @MINRANGE INT = 30;

	CREATE TABLE #INDIV_EDS_STATUS(
		EDS_NAME varchar(50) NULL,
		SW_TYPE varchar(50) NULL,
		SW_REV varchar(50) NULL,
		KEY_POS varchar(50) NULL,
		EDS_STATUS varchar(20) NULL,
		PLC_SCAN_TIME int NULL,
		ESTOP int NULL,
		FAULTS int NULL,
		RTR_HIGH int NULL,
		RTR_LOW int NULL,
		JAMS int NULL,
		BAGS_SCR int NULL,
		BAGS_CLR int NULL,
		BAGS_ALM int NULL,
		BAGS_EDS_UNKNOWN int NULL,
		BAGS_SEEN int NULL,
		BAGS_BHS_UNKNOWN int NULL,
		BAGS_BHS_UNKNOWN_PER float NULL,
		BAGS_TIMEOUTS int NULL,
		AVG_L2_DECISION_TIME float NULL,
		AVG_BAG_PROC_TIME float NULL,
		COMM_IF_STATUS int NULL,
		COMM_PLC_NAME varchar(30) NULL
	) 

	--1. Insert item_screened data into a temp table
	SELECT	GID,SCREEN_LEVEL,TIME_STAMP,RESULT_TYPE,LOC.SUBSYSTEM,LOC.LOCATION
	INTO	#EDS_ITEM_SCREENED_TEMP
	FROM	ITEM_SCREENED ICR,LOCATIONS LOC WITH(NOLOCK)
	WHERE	TIME_STAMP BETWEEN @DTFrom AND @DTTo
		AND ICR.LOCATION=LOC.LOCATION_ID
		AND LOC.SUBSYSTEM=@SUBSYSTEM;

	CREATE NONCLUSTERED INDEX #EDS_ITEM_SCREENED_TEMP_IDXGID ON #EDS_ITEM_SCREENED_TEMP(GID);

	--2. UPDATE BAGS_SCR
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_SCR = COUNT(ICR.GID)
	FROM #EDS_ITEM_SCREENED_TEMP ICR;

	--3. UPDATE BAGS_CLR
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_CLR = COUNT(ICR.GID)
	FROM #EDS_ITEM_SCREENED_TEMP ICR
	WHERE ICR.RESULT_TYPE='12' OR ICR.RESULT_TYPE='22';

	--4. UPDATE BAGS_ALM
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_CLR = COUNT(ICR.GID)
	FROM #EDS_ITEM_SCREENED_TEMP ICR
	WHERE ICR.RESULT_TYPE<>'12' AND ICR.RESULT_TYPE<>'22' --CLEAR
		AND ICR.RESULT_TYPE<>'13' AND ICR.RESULT_TYPE<>'23' --UNKNOW
		AND ICR.RESULT_TYPE<>'15' AND ICR.RESULT_TYPE<>'25'; --TIMEOUT

	--5. UPDATE BAGS_EDS_UNKNOWN
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_CLR = COUNT(ICR.GID)
	FROM #EDS_ITEM_SCREENED_TEMP ICR
	WHERE ICR.RESULT_TYPE='13' OR ICR.RESULT_TYPE='23';

	--6. BAGS_SEEN
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_SEEN = SUM(MBC.DIFFERENT)
	FROM MDS_BAG_COUNT MBC, MDS_BAG_COUNTERS MBCR, GET_RPT_EDS_LINE_DEVICE() ELD
	WHERE MBC.TIME_STAMP BETWEEN @DTFrom AND @DTTo
		AND MBC.COUNTER_ID=MBCR.COUNTER_ID
		AND MBCR.SUBSYSTEM=ELD.SUBSYSTEM AND ELD.SUBSYSTEM=@SUBSYSTEM
		AND MBCR.LOCATION=ELD.PRE_XM_LOCATION;

	--7. BAGS_BHS_UNKNOWN
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_BHS_UNKNOWN=COUNT(GID.GID)
	FROM #EDS_ITEM_SCREENED_TEMP ICR, GID_USED GID
	WHERE ICR.GID=GID.GID 
		AND GID.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINRANGE,@DTFROM) AND @DTTO
		AND GID.BAG_TYPE='02';

	--8. BAGS_BHS_UNKNOWN_PER
	DECLARE @BAG_SEEN_CNT INT = (SELECT BAGS_SEEN FROM #INDIV_EDS_STATUS)
	IF @BAG_SEEN_CNT != 0
	BEGIN
		UPDATE #INDIV_EDS_STATUS
		SET BAGS_BHS_UNKNOWN_PER=CAST(BAGS_BHS_UNKNOWN AS FLOAT)/CAST(BAGS_SEEN AS FLOAT)
	END
	ELSE
	BEGIN
		UPDATE #INDIV_EDS_STATUS
		SET BAGS_BHS_UNKNOWN_PER=-1;
	END

	--9. BAGS_TIMEOUTS
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_CLR = COUNT(ICR.GID)
	FROM #EDS_ITEM_SCREENED_TEMP ICR
	WHERE ICR.RESULT_TYPE='15' OR ICR.RESULT_TYPE='25';

	--TIME STAMP FOR EDS
	SELECT	ITI.GID,LOC.SUBSYSTEM,LOC.LOCATION,ITI.TIME_STAMP
	INTO	#EDS_ITEM_TRACKING_TEMP
	FROM	ITEM_TRACKING ITI,LOCATIONS LOC WITH(NOLOCK)
	WHERE	ITI.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINRANGE,@DTFROM) AND DATEADD(MINUTE,@MINRANGE,@DTTO)
		AND ITI.LOCATION=LOC.LOCATION_ID
		AND LOC.SUBSYSTEM=@SUBSYSTEM;

	CREATE NONCLUSTERED INDEX #EDS_ITEM_TRACKING_TEMP_IDXGID ON #EDS_ITEM_TRACKING_TEMP(GID);

	SELECT ICR.GID,PREITI.TIME_STAMP AS ENTER_TIME, POSTITI.TIME_STAMP AS EXIT_TIME, ICR.TIME_STAMP AS ICR_TIME
	INTO #EDS_BAG_TIME
	FROM #EDS_ITEM_SCREENED_TEMP ICR, #EDS_ITEM_TRACKING_TEMP PREITI, #EDS_ITEM_TRACKING_TEMP POSTITI, GET_RPT_EDS_LINE_DEVICE() ELD
	WHERE ICR.GID=PREITI.GID AND ICR.GID=POSTITI.GID
		AND ICR.SUBSYSTEM=ELD.SUBSYSTEM
		AND ELD.PRE_XM_LOCATION=PREITI.LOCATION AND ELD.POST_XM_LOCATION=POSTITI.LOCATION

	--TIME DURATION
	SELECT EBT.GID, DATEDIFF(SECOND,EBT.ICR_TIME,EBT.EXIT_TIME) AS L2_DURATION, DATEDIFF(SECOND,EBT.ICR_TIME,EBT.ENTER_TIME) AS PROC_DURATION
	INTO #EDS_BAG_DURATION
	FROM #EDS_BAG_TIME EBT


	--10.AVG_L2_DECISION_TIME
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_CLR = AVG(EBD.L2_DURATION)
	FROM #EDS_BAG_DURATION EBD

	--11.AVG_BAG_PROC_TIME
	UPDATE #INDIV_EDS_STATUS
	SET BAGS_CLR = AVG(EBD.PROC_DURATION)
	FROM #EDS_BAG_DURATION EBD
END