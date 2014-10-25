GO
USE [BHSDB_CLT_Demo];
GO


alter PROCEDURE dbo.stp_RPT_CLT_TIMEINSYSTEM
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @Interval INT
AS
BEGIN
--PROBLEM1: EDS LEVEL1 & LEVEL2 AVERAGE GO-THROUGHT TIME

	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @HOURRANGE INT=1;
	DECLARE @DATERANGE INT=1;

	--1. Query the bags data from BSM
	--SELECT DISTINCT LICENSE_PLATE,BSM_RECD_TIME,TAG_PRINT_TIME INTO #TIS_BAG_SORTING_TEMP
	--FROM 
	--(
	--	SELECT LICENSE_PLATE,TIME_STAMP AS BSM_RECD_TIME,CHECK_IN_TIME_STAMP AS TAG_PRINT_TIME
	--	FROM BAG_SORTING WITH(NOLOCK)
	--	WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE, @DTFrom) AND DATEADD(DAY,@DATERANGE, @DTTo)	
				
	--	UNION ALL
	--	SELECT LICENSE_PLATE,TIME_STAMP AS BSM_RECD_TIME,CHECK_IN_TIME_STAMP AS TAG_PRINT_TIME
	--	FROM BAG_SORTING_HIS WITH(NOLOCK)
	--	WHERE TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE, @DTFrom) AND DATEADD(DAY,@DATERANGE, @DTTo) 
	--) AS BAG_SORTING_ALL ;
	
	--CREATE TABLE FOR FINAL STATISTIC
	CREATE TABLE #TIS_TIMEINSYSTEM_TEMP
	(
		START_TIME DATETIME,
		END_TIME DATETIME,
		MAX_TIME INT,--SECONDS
		MIN_TIME INT,--SECONDS
		AVG_TIME INT,--SECONDS

		EDSLVL1_AVGTIME INT,
		EDSLVL2_AVGTIME INT
	);

	--Create table for all bags time detail
	--Start Time when bags entering into system BY GID at the entrance ATR
	--End Time when bags are sorted to MU BY GID at the mainline ATR
	CREATE TABLE #TIS_BAGS_TIMEDETAIL
	(
		LICENSE_PLATE varchar(10),
		FIRST_ATR_GID varchar(10),
		STARTTIME datetime,
		SECOND_ATR_GID varchar(10),
		ENDTIME datetime,
		TRAVEL_DURATION INT,

		ENTER_ITI_TIME DATETIME,
		ICR_LVL1_TIME DATETIME,
		ICR_LVL2_TIME DATETIME,
		LVL1_DURATION INT,
		LVL2_DURATION INT
	);

	--1. Insert bag info(license plate) and entering time BY GID at the entrance ATR
	INSERT INTO #TIS_BAGS_TIMEDETAIL
	SELECT 
		CASE
			WHEN ISC.LICENSE_PLATE1 NOT LIKE '1%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE1
			WHEN ISC.LICENSE_PLATE2 NOT LIKE '1%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE2
		END AS LICENSE_PLATE, 
		ISC.GID AS FIRST_ATR_GID,
		NULL AS STARTTIME,
		NULL AS SECOND_ATR_GID,
		NULL AS ENDTIME,
		NULL AS TRAVEL_DURATION,
		NULL AS ENTER_ITI_TIME, NULL AS ICR_LVL1_TIME, NULL AS ICR_LVL2_TIME, NULL AS LVL1_DURATION, NULL AS LVL2_DURATION
	FROM ITEM_SCANNED ISC, 
		 --GID_USED GUD, 
		 --LOCATIONS GID_LOC,
		 LOCATIONS ISC_LOC WITH(NOLOCK)
	WHERE ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		--AND ISC.GID=GUD.GID
		--AND GUD.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
		AND (ISC.LICENSE_PLATE1 NOT LIKE '1%' OR ISC.LICENSE_PLATE2 NOT LIKE '1%')
		AND (	 (ISC.LICENSE_PLATE1 <>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10) 
			  OR (ISC.LICENSE_PLATE2 <>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10)
			)
		--AND GUD.LOCATION=GID_LOC.LOCATION_ID
		--AND GID_LOC.LOCATION IN ('','','','','','')--
		AND ISC.LOCATION=ISC_LOC.LOCATION_ID
		AND EXISTS( SELECT * FROM MIS_SS_LINE_DEVICE MSLD WHERE MSLD.ATR_LOCATION=ISC_LOC.LOCATION)
		--AND ISC_LOC.LOCATION IN ('SS1-2','SS2-2','SS3-2','SS4-2');---THE ATR AT THE CHECKIN LOCATION

	
	--No data in the fields TAG_PRINT_TIME or BSM_RECD_TIME for all BSM 
	--Commented by Guo Wenyu 2014/10/17

	--2 Update the start time by BSM Tag print time or BSM time stamp
	--UPDATE TBT
	--SET TBT.STARTTIME=
	--	(	CASE 
	--			WHEN BS.TAG_PRINT_TIME IS NOT NULL THEN TAG_PRINT_TIME
	--			ELSE BS.BSM_RECD_TIME
	--		END 
	--	)
	--FROM #TIS_BAGS_TIMEDETAIL TBT, #TIS_BAG_SORTING_TEMP BS
	--WHERE TBT.LICENSE_PLATE=BS.LICENSE_PLATE;

	UPDATE	TBT
	SET		TBT.STARTTIME=GUD.TIME_STAMP
	FROM	#TIS_BAGS_TIMEDETAIL TBT,
			GID_USED GUD, 
			LOCATIONS GID_LOC
	WHERE	TBT.FIRST_ATR_GID=GUD.GID
		AND GUD.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
		AND GUD.LOCATION=GID_LOC.LOCATION_ID
		AND EXISTS( SELECT * FROM MIS_SS_LINE_DEVICE MSLD WHERE MSLD.GID_LOCATION=GID_LOC.LOCATION)

	

	--SELECT * FROM #TIS_BAGS_TIMEDETAIL;

	--3. Query the data of the bags which are proceeded to make-up carousel
	SELECT IPR.GID, MAX(IPR.TIME_STAMP) AS TIME_STAMP
	INTO #TIS_ITEM_PROCEEDED_TEMP
	FROM ITEM_PROCEEDED IPR,LOCATIONS PRD_LOC WITH(NOLOCK)
	WHERE IPR.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		AND PRD_LOC.SUBSYSTEM LIKE 'MU%'
	GROUP BY IPR.GID;

	--SELECT * FROM #TIS_ITEM_PROCEEDED_TEMP;

	--4. Update the end time BY GID at the mainline ATR with same license plate
	UPDATE TBT
	SET TBT.SECOND_ATR_GID=ISC.GID, TBT.ENDTIME=IPR.TIME_STAMP
	FROM #TIS_BAGS_TIMEDETAIL TBT, 
		 ITEM_SCANNED ISC, 
		 LOCATIONS ISC_LOC,
		 #TIS_ITEM_PROCEEDED_TEMP IPR WITH(NOLOCK)
	WHERE (TBT.LICENSE_PLATE=ISC.LICENSE_PLATE1 OR TBT.LICENSE_PLATE=ISC.LICENSE_PLATE2)
		AND ISC.LOCATION=ISC_LOC.LOCATION_ID
		AND ISC.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND ISC_LOC.SUBSYSTEM LIKE 'ML%'
		AND ISC.GID=IPR.GID
		--AND IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		--AND PRD_LOC.LOCATION IN ('MU1','MU2','MU3','MU4','MU5','MU6')
		--AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO);	

	--Update the end time by GID at MES with same license plate
	UPDATE TBT
	SET TBT.SECOND_ATR_GID=IEC.GID, TBT.ENDTIME=IPR.TIME_STAMP
	FROM #TIS_BAGS_TIMEDETAIL TBT, 
		 ITEM_ENCODED IEC, 
		 LOCATIONS LOC,
		 #TIS_ITEM_PROCEEDED_TEMP IPR WITH(NOLOCK)
	WHERE	TBT.LICENSE_PLATE=IEC.LICENSE_PLATE
		AND IEC.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND IEC.GID=IPR.GID
		AND TBT.SECOND_ATR_GID IS NULL

	--SELECT * FROM #TIS_BAGS_TIMEDETAIL;	

	--5. Calculate the duration(SECONDS) between start time and end time
	UPDATE TBT
	SET TBT.TRAVEL_DURATION = DATEDIFF(SECOND,TBT.STARTTIME,TBT.ENDTIME)
	FROM #TIS_BAGS_TIMEDETAIL TBT
	WHERE TBT.ENDTIME IS NOT NULL AND TBT.STARTTIME IS NOT NULL;


	--6. Update ITI timestamp before EDS, ICR timestamp of level1 and leve2 into #TIS_BAGS_TIMEDETAIL
	UPDATE TBT
	SET TBT.ENTER_ITI_TIME=PRE_ITI.TIME_STAMP,TBT.ICR_LVL1_TIME=POST_ITI.TIME_STAMP,TBT.ICR_LVL2_TIME=ICR.TIME_STAMP
	FROM #TIS_BAGS_TIMEDETAIL TBT
	INNER JOIN (	SELECT GID,MAX(TIME_STAMP) AS TIME_STAMP FROM ITEM_SCREENED WITH(NOLOCK) 
					WHERE (SCREEN_LEVEL='1' OR SCREEN_LEVEL='2' OR SCREEN_LEVEL='3')
						AND TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
					GROUP BY GID
				) AS ICR
		ON TBT.FIRST_ATR_GID=ICR.GID
			
	INNER JOIN ITEM_TRACKING PRE_ITI WITH(NOLOCK) 
		ON TBT.FIRST_ATR_GID=PRE_ITI.GID 
		AND PRE_ITI.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND  EXISTS(
						SELECT ELD.PRE_XM_LOCATION 
						FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
						WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.PRE_XM_LOCATION=LOC.LOCATION AND PRE_ITI.LOCATION=LOC.LOCATION_ID
					)
	INNER JOIN ITEM_TRACKING POST_ITI WITH(NOLOCK) 
		ON TBT.FIRST_ATR_GID=POST_ITI.GID 
		AND POST_ITI.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND  EXISTS(
						SELECT ELD.POST_XM_LOCATION 
						FROM GET_RPT_EDS_LINE_DEVICE() ELD, LOCATIONS LOC
						WHERE ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.POST_XM_LOCATION=LOC.LOCATION AND POST_ITI.LOCATION=LOC.LOCATION_ID
					)
	--INNER JOIN (	SELECT GID,MAX(TIME_STAMP) AS TIME_STAMP FROM ITEM_SCREENED WITH(NOLOCK) 
	--				WHERE SCREEN_LEVEL='2'
	--					AND TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
	--				GROUP BY GID
	--			) AS ICRLVL2 
	--	ON TBT.FIRST_ATR_GID=ICRLVL2.GID
	WHERE TBT.FIRST_ATR_GID=ICR.GID 
		AND TBT.FIRST_ATR_GID=POST_ITI.GID
		AND TBT.FIRST_ATR_GID=PRE_ITI.GID;
		
	
	--7. Calculate duration for level 1 and level 2
	UPDATE TBT
	SET TBT.LVL1_DURATION=
			CASE 
				WHEN ENTER_ITI_TIME IS NOT NULL AND ICR_LVL1_TIME IS NOT NULL
					THEN DATEDIFF(SECOND,ENTER_ITI_TIME,ICR_LVL1_TIME)
				ELSE NULL
			END,
		TBT.LVL2_DURATION=
			CASE
				WHEN ICR_LVL1_TIME IS NOT NULL AND ICR_LVL2_TIME IS NOT NULL
					THEN DATEDIFF(SECOND,ICR_LVL1_TIME,ICR_LVL2_TIME)
				ELSE NULL
			END
	FROM #TIS_BAGS_TIMEDETAIL TBT;
	
	--SELECT * FROM #TIS_BAGS_TIMEDETAIL;
	--8. Calculate the max,min and avg travel time for each interval
	DECLARE @STARTTIME_IDX DATETIME = @DTFROM;
	DECLARE @ENDTIME_IDX DATETIME = DATEADD(MINUTE,@INTERVAL,@STARTTIME_IDX);
	
	WHILE(@STARTTIME_IDX < @DTTO)
	BEGIN
		IF (@ENDTIME_IDX > @DTTO)
		BEGIN
			SET @ENDTIME_IDX=@DTTO;
		END
		
		INSERT INTO #TIS_TIMEINSYSTEM_TEMP
		SELECT @STARTTIME_IDX AS START_TIME,
			   @ENDTIME_IDX AS END_TIME,
			   MAX(TBT.TRAVEL_DURATION) AS MAX_TIME,
			   MIN(TBT.TRAVEL_DURATION) AS MIN_TIME,
			   AVG(TBT.TRAVEL_DURATION) AS AVG_TIME,
			   0 AS EDSLVL1_AVGTIME,
			   0 AS EDSLVL2_AVGTIME
		FROM #TIS_BAGS_TIMEDETAIL TBT
		WHERE TBT.STARTTIME BETWEEN @STARTTIME_IDX AND @ENDTIME_IDX
			AND TBT.TRAVEL_DURATION IS NOT NULL AND TBT.TRAVEL_DURATION > 0;

		UPDATE TIS
		SET EDSLVL1_AVGTIME=
		(	SELECT AVG(TBT.LVL1_DURATION)
			FROM #TIS_BAGS_TIMEDETAIL TBT
			WHERE TBT.ENTER_ITI_TIME BETWEEN @STARTTIME_IDX AND @ENDTIME_IDX
				AND TBT.LVL1_DURATION IS NOT NULL AND TBT.LVL1_DURATION>0
		) 
		FROM #TIS_TIMEINSYSTEM_TEMP TIS
		WHERE TIS.START_TIME=@STARTTIME_IDX AND TIS.END_TIME=@ENDTIME_IDX

		UPDATE TIS
		SET EDSLVL2_AVGTIME=
		(	SELECT AVG(TBT.LVL2_DURATION)
			FROM #TIS_BAGS_TIMEDETAIL TBT
			WHERE TBT.ENTER_ITI_TIME BETWEEN @STARTTIME_IDX AND @ENDTIME_IDX
				AND TBT.LVL2_DURATION IS NOT NULL AND TBT.LVL2_DURATION>0
		) 
		FROM #TIS_TIMEINSYSTEM_TEMP TIS
		WHERE TIS.START_TIME=@STARTTIME_IDX AND TIS.END_TIME=@ENDTIME_IDX

			
		SET @STARTTIME_IDX = DATEADD(MINUTE,@INTERVAL,@STARTTIME_IDX);
		SET @ENDTIME_IDX = DATEADD(MINUTE,@INTERVAL,@STARTTIME_IDX);
	END

	SELECT * FROM #TIS_TIMEINSYSTEM_TEMP;
	
END

--DECLARE @DTFrom [datetime]='2013-12-30 15:10:00.000';
--DECLARE @DTTo [datetime]='2013-12-30 15:20:00.000';
--DECLARE @Interval INT=1;
--exec stp_RPT26_TIMEINSYSTEM_GWYTEST @DTFrom,@DTTo,@Interval