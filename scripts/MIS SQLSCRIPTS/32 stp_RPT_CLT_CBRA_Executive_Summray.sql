GO
USE [BHSDB];
GO

ALTER PROCEDURE dbo.stp_RPT_CLT_CBRA_Executive_Summray
		  @DTFROM datetime,
		  @DTTO datetime
AS
BEGIN
	DECLARE @MINUTERANGE INT=20;

	--11	Machine Alarm / Operator Alarm		Alarmed
	--12	Machine Alarm / Operator Clear		Cleared
	--13	Machine Alarm / Operator Unknown	No Decision
	--14	Machine Alarm / Operator Pending	Pending
	--15	Machine Alarm / Operator Timeout	OSR Time-out
	--21	Machine Clear / Operator Alarm		Alarmed
	--22	Machine Clear / Operator Clear		Cleared
	--23	Machine Clear / Operator Unknown	No Decision
	--24	Machine Clear / Operator Pending	Pending
	--25	Machine Clear / Operator Timeout	OSR Time-out
	--33	Error / Unknown						No Decision
	--X		Error / Unknown						No Decision

	--Reason To CBRA
	--Cleared, Alarmed, No Decision(OSR Timeout), Lost Tracking, Unscreened

	DECLARE @TOTAL_BAGS INT;
	DECLARE @EDS_BAGS INT;
	DECLARE @CBRA_BAGS INT;
	DECLARE @CBRA_CLEARED_BAGS INT;
	DECLARE @CBRA_ALARMED_BAGS INT;
	DECLARE @CBRA_NODECISION_BAGS INT;
	DECLARE @CBRA_PENDING_BAGS INT;
	DECLARE @CBRA_TIMEOUT_BAGS INT;
	DECLARE @CBRA_LOST_BAGS INT;
	DECLARE @CBRA_UNSCREENED_BAGS INT;

	--1. Get the quantity of total bags 
	SELECT	@TOTAL_BAGS = COUNT(ITI.GID) 
	FROM	ITEM_TRACKING ITI, GET_RPT_EDS_LINE_DEVICE() ELD,LOCATIONS LOC WITH(NOLOCK)
	WHERE	ITI.LOCATION=LOC.LOCATION_ID
		AND LOC.LOCATION=ELD.PRE_XM_LOCATION
		AND	ITI.TIME_STAMP BETWEEN @DTFROM AND @DTTO 

	--2. Get the quantity of bags screened by EDS machine
	SELECT	@EDS_BAGS = COUNT(ICR.GID)
	FROM	ITEM_SCREENED ICR WITH(NOLOCK)
	WHERE	ICR.TIME_STAMP BETWEEN @DTFROM AND @DTTO 

	--3. Get the LIST of bags proceedes to CBRA
	CREATE TABLE #CBRA_BAGS_LIST
	(
		BAG_GID VARCHAR(10),
		CLEARED_FLAG INT,
		ALARMED_FLAG INT,
		NODECISION_FLAG INT,
		PENDING_FLAG INT,
		TIMEOUT_FLAG INT,
		LOST_FLAG INT,
		UNSCREENED_FLAG INT
	)

	--4. Find all bags which are proceeded to CBRA area with their screening status
	INSERT INTO #CBRA_BAGS_LIST
	SELECT	IPR.GID,
			CASE
				WHEN ICR.RESULT_TYPE='12' OR ICR.RESULT_TYPE='22' THEN 1
				ELSE 0
			END AS CLEARED_FLAG,

			CASE 
				WHEN ICR.RESULT_TYPE='11' OR ICR.RESULT_TYPE='21' THEN 1
				ELSE 0
			END AS ALARMED_FLAG,

			CASE 
				WHEN ICR.RESULT_TYPE='13' OR ICR.RESULT_TYPE='23' OR ICR.RESULT_TYPE='33' OR ICR.RESULT_TYPE='X' THEN 1
				ELSE 0
			END AS NODECISION_FLAG,

			CASE
				WHEN ICR.RESULT_TYPE='14' OR ICR.RESULT_TYPE='24' THEN 1
				ELSE 0
			END AS PENDING_FLAG,
			
			CASE
				WHEN ICR.RESULT_TYPE='15' OR ICR.RESULT_TYPE='25' THEN 1
				ELSE 0
			END AS TIMEOUT_FLAG,
			0 AS LOST_FLAG, 0 AS UNSCREENED_FLAG
	FROM	LOCATIONS PRELOC,ITEM_PROCEEDED IPR WITH(NOLOCK)
	LEFT JOIN ITEM_SCREENED ICR WITH(NOLOCK)
		ON	IPR.GID=ICR.GID
		AND ICR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
	WHERE	IPR.PROCEED_LOCATION=PRELOC.LOCATION_ID
		AND PRELOC.SUBSYSTEM LIKE 'SB%'
		AND IPR.TIME_STAMP BETWEEN @DTFROM AND @DTTO 

	--5. Update the bags lost status when they are proceeded to their destination
	UPDATE	CBL
	SET		CBL.LOST_FLAG = 1
	FROM	#CBRA_BAGS_LIST CBL, GID_USED GID, LOCATIONS LOC WITH(NOLOCK)
	WHERE	CBL.BAG_GID=GID.GID
		AND GID.BAG_TYPE='02'
		AND	GID.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		AND CBL.CLEARED_FLAG=0 AND CBL.ALARMED_FLAG=0 AND CBL.TIMEOUT_FLAG=0 --If they are 0, then no screen info
		AND GID.LOCATION=LOC.LOCATION_ID
		AND 
			(
				LOC.SUBSYSTEM LIKE 'OOG%'
				OR LOC.SUBSYSTEM LIKE 'SB%'
				OR EXISTS(
							SELECT ELD.POST_XM_LOCATION
							FROM GET_RPT_EDS_LINE_DEVICE() ELD 
							WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM 
							AND LOC.LOCATION>=ELD.POST_XM_LOCATION
						  )
			)

	--6. Update the bags unscreened
	UPDATE	CBL
	SET		CBL.UNSCREENED_FLAG = 1
	FROM	#CBRA_BAGS_LIST CBL
	WHERE	CBL.CLEARED_FLAG=0 AND CBL.ALARMED_FLAG=0 AND CBL.TIMEOUT_FLAG=0 AND CBL.LOST_FLAG=0

	--SELECT * FROM #CBRA_BAGS_LIST;

	--Get Statistic Data
	SELECT @CBRA_BAGS=COUNT(BAG_GID) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_CLEARED_BAGS=SUM(CLEARED_FLAG) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_ALARMED_BAGS=SUM(ALARMED_FLAG) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_NODECISION_BAGS=SUM(NODECISION_FLAG) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_PENDING_BAGS=SUM(PENDING_FLAG) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_TIMEOUT_BAGS=SUM(TIMEOUT_FLAG) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_LOST_BAGS =SUM(LOST_FLAG) FROM #CBRA_BAGS_LIST
	SELECT @CBRA_UNSCREENED_BAGS =SUM(UNSCREENED_FLAG) FROM #CBRA_BAGS_LIST

	--Return result
	SELECT	@TOTAL_BAGS AS TOTAL_BAGS,
			@EDS_BAGS AS EDS_BAGS,
			@CBRA_BAGS AS CBRA_BAGS,
			@CBRA_CLEARED_BAGS AS CBRA_CLEARED_BAGS,
			@CBRA_ALARMED_BAGS AS CBRA_ALARMED_BAGS,
			@CBRA_NODECISION_BAGS AS CBRA_NODECISION_BAGS,
			@CBRA_PENDING_BAGS AS CBRA_PENDING_BAGS,
			@CBRA_TIMEOUT_BAGS AS CBRA_TIMEOUT_BAGS,
			@CBRA_LOST_BAGS AS CBRA_LOST_BAGS,
			@CBRA_UNSCREENED_BAGS AS CBRA_UNSCREENED_BAGS
END


--DECLARE @DTFROM datetime='05/07/2014 09:00:00 AM'
--DECLARE @DTTO datetime='05/07/2014 10:50:00 AM'
--EXEC stp_RPT_OKC_CBRA_Executive_Summray @DTFROM,@DTTO