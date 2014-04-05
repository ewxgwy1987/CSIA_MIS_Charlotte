GO
USE [BHSDB_CLT];
GO


ALTER PROCEDURE dbo.stp_RPT_CLT_STANDBY_BAGGAGE
		  @DTFROM DATETIME,
		  @DTTO DATETIME
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @DATERANGE INT=1;
	DECLARE @HOURRANGE INT=1;

	--Create temp table for final result
	CREATE TABLE #SBB_STANDBY_BAGGAGE_TEMP 
	(
		TIME_STAMP DATETIME,
		GID BIGINT,
		LICENSE_PLATE VARCHAR(10),
		PAX_NAME VARCHAR(200),
		FLIGHT_NUMBER VARCHAR(5),
		AIRLINE VARCHAR(3),
		SDO DATETIME,
		TAG_READ_TIME DATETIME,
		TAG_READ_LOCATION VARCHAR(20),
		ALLOC_MU VARCHAR(10),
		SORTED_MU VARCHAR(10),
	);

	--INSERT INTO #SBB_STANDBY_BAGGAGE_TEMP EXEC DBO.stp_RPT_BAGTAG_GWYTEST

	--1. Query the bags data from BSM
	SELECT DISTINCT TIME_STAMP, LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE, SDO INTO #SBB_BAG_SORTING_TEMP
	FROM 
	(
		SELECT TIME_STAMP, LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE, SDO
		FROM BAG_SORTING WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE, @DTFrom) AND DATEADD(HOUR,@HOURRANGE, @DTTo)	
			--AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
			--AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM))
			AND RECONCILIATION_PASSENGER_STATUS='S'
			
		UNION ALL
		SELECT TIME_STAMP, LICENSE_PLATE,GIVEN_NAME,SURNAME,OTHERS_NAME,FLIGHT_NUMBER,AIRLINE, SDO
		FROM BAG_SORTING_HIS WITH(NOLOCK)
		WHERE TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE, @DTFrom) AND DATEADD(HOUR,@HOURRANGE, @DTTo) 
			--AND AIRLINE IN (SELECT * FROM RPT_GETPARAMETERS(@AIRLINE)) 
			--AND FLIGHT_NUMBER IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@FLIGHTNUM))
			AND RECONCILIATION_PASSENGER_STATUS='S'
	) AS BAG_SORTING_ALL ;

	--2. Insert bags data into final table
	INSERT INTO #SBB_STANDBY_BAGGAGE_TEMP
	SELECT TIME_STAMP, NULL AS GID, LICENSE_PLATE, (ISNULL(GIVEN_NAME,'')+' '+ISNULL(SURNAME,'')+' '+ISNULL(OTHERS_NAME,''))  AS PAX_NAME,
		   FLIGHT_NUMBER, AIRLINE, SDO, NULL AS TAG_READ_TIME,'' AS TAG_READ_LOCATION,'' AS ALLOC_MU,'' AS SORTED_MU
	FROM #SBB_BAG_SORTING_TEMP

	CREATE INDEX #SBB_STANDBY_BAGGAGE_TEMP_IDXLP ON #SBB_STANDBY_BAGGAGE_TEMP(LICENSE_PLATE);


	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP INTO #BT_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE (ISC.LICENSE_PLATE1=SBB.LICENSE_PLATE OR ISC.LICENSE_PLATE2=SBB.LICENSE_PLATE)
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7')
	--ORDER BY ISC.TIME_STAMP DESC; 

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #BT_ITEM_TAGREAD_TEMP
	SELECT IEC.GID,IEC.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IEC.LOCATION,IEC.TIME_STAMP 
	FROM ITEM_ENCODED IEC,#SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE IEC.LICENSE_PLATE=SBB.LICENSE_PLATE
		AND IEC.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)
	UNION
	SELECT IRM.GID,IRM.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IRM.LOCATION,IRM.TIME_STAMP 
	FROM ITEM_REMOVED IRM WITH(NOLOCK)
	WHERE IRM.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO)

	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp

	--SELECT GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION, TIME_STAMP INTO #BT_TAGREAD_TEMP
	--FROM #BT_ITEM_TAGREAD_TEMP
	--ORDER BY TIME_STAMP DESC;

	DECLARE @TAGREAD_TABLE AS TAGREAD_TABLETYPE; --For the parameter of stp_RPT_GET_LATEST_TAGREAD

	INSERT INTO @TAGREAD_TABLE
	SELECT * FROM #BT_ITEM_TAGREAD_TEMP;

	CREATE TABLE #BT_TAGREAD_TEMP
	( 
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(10), 
		LOCATION VARCHAR(20), 
		TIME_STAMP DATETIME
	);

	INSERT INTO #BT_TAGREAD_TEMP
	EXEC dbo.stp_RPT_GET_LATEST_TAGREAD @TAGREAD_TABLE;


	CREATE INDEX #BT_TAGREAD_TEMP_IDXLP ON #BT_TAGREAD_TEMP(LICENSE_PLATE);
	--CREATE INDEX #BT_TAGREAD_TEMP_IDXGID ON #BT_TAGREAD_TEMP(LICENSE_PLATE2);

	--5. Update ATR OR MES read info(GID,TAG_READ_TIME,TAG_READ_LOCATION) into final table
	UPDATE SBB
	SET SBB.GID=ITT.GID,SBB.TAG_READ_TIME=ITT.TIME_STAMP,SBB.TAG_READ_LOCATION=LOC.LOCATION
	FROM #BT_TAGREAD_TEMP ITT, #SBB_STANDBY_BAGGAGE_TEMP SBB, LOCATIONS LOC
	WHERE ITT.LICENSE_PLATE=SBB.LICENSE_PLATE
		AND ITT.LOCATION=LOC.LOCATION_ID

	CREATE INDEX #SBB_STANDBY_BAGGAGE_TEMP_IDXGID ON #SBB_STANDBY_BAGGAGE_TEMP(GID);

	--6. Update Flight Allocation Make-up carousel(ALLOC_MU) into final table
	UPDATE SBB
	SET SBB.ALLOC_MU=FPA.RESOURCE
	FROM FLIGHT_PLAN_ALLOC FPA, #SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE FPA.AIRLINE=SBB.AIRLINE AND FPA.FLIGHT_NUMBER=SBB.FLIGHT_NUMBER
		AND FPA.SDO=SBB.SDO;

	--7. Update sorted MU(SORTED_MU) into final table
	UPDATE SBB
	SET SBB.SORTED_MU=LOC.LOCATION
	FROM ITEM_PROCEEDED IPR, LOCATIONS LOC,#SBB_STANDBY_BAGGAGE_TEMP SBB WITH(NOLOCK)
	WHERE IPR.GID=SBB.GID AND SBB.GID IS NOT NULL
		AND IPR.PROCEED_LOCATION = LOC.LOCATION_ID
		AND LOC.SUBSYSTEM LIKE 'MU%'
		AND IPR.TIME_STAMP BETWEEN DATEADD(DAY,-@DATERANGE,@DTFROM) AND DATEADD(DAY,@DATERANGE,@DTTO);


	SELECT * FROM #SBB_STANDBY_BAGGAGE_TEMP;

END


--DECLARE @DTFROM datetime='2014-1-1';
--DECLARE @DTTO datetime='2014-1-3';
--EXEC stp_RPT_STANDBY_BAGGAGE_GWYTEST @DTFROM,@DTTO;