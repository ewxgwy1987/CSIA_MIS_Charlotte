GO
USE [BHSDB];
GO


CREATE PROCEDURE dbo.stp_RPT09_MESUTILIZATION_GWYTEST
		  @DTFROM datetime, 
		  @DTTO datetime
AS
BEGIN
	PRINT 'BAGTAG STORED PROCEDURE BEGIN';
	DECLARE @HOURRANGE INT=1;

	--Create temp table for final result
	CREATE TABLE #MU_MESUTILIZATION_TEMP
	(
		ME_STATION VARCHAR(10),
		CNT_FLIGHT INT,
		CNT_SCANNING INT,
		CNT_DEST_AIRLINE INT,
		CNT_MU INT,
		CNT_BSM INT,
		CNT_RUNOUT INT,
		CNT_PROBLEM_BAG INT,
		CNT_LATEBSMS INT
	);

	--Create temp table for all the required MES data from ITEM_ENCODING_REQUEST 
	--And mark the encoding type
	CREATE TABLE #MU_MESMARKLIST_TEMP
	(
		GID VARCHAR(10),
		TIME_STAMP DATETIME,
		LOCATION VARCHAR(10),
		ENCODING_TYPE VARCHAR(2),
		MARK_FLIGHT INT,
		MARK_SCANNING INT,
		MARK_DEST_AIRLINE INT,
		MARK_MU INT,
		MARK_BSM INT,
		MARK_RUNOUT INT,
		MARK_PROBLEM_BAG INT,
		MARK_LATEBSMS INT
	);

	--1. Query MES detail data into #MU_ITEM_ENCODING_REQUEST_TEMP
	SELECT MAX(IER.TIME_STAMP) AS TIME_STAMP,IER.GID,IER.LOCATION,IER.ENCODING_TYPE INTO #MU_ITEM_ENCODING_REQUEST_TEMP
	FROM ITEM_ENCODING_REQUEST IER WITH(NOLOCK)
	WHERE IER.TIME_STAMP BETWEEN @DTFROM AND @DTTO
	GROUP BY IER.GID,IER.LOCATION,IER.ENCODING_TYPE;

	--select * from #MU_ITEM_ENCODING_REQUEST_TEMP;

	--2. Initialize MES encoding mark of #MU_MESMARKLIST_TEMP
	INSERT INTO #MU_MESMARKLIST_TEMP
	SELECT IER.GID, IER.TIME_STAMP, LOC.SUBSYSTEM AS LOCATION, IER.ENCODING_TYPE,
		   0 AS MARK_FLIGHT, 0 AS MARK_SCANNING, 0 AS MARK_DEST_AIRLINE, 0 AS MARK_MU, 
		   0 AS MARK_BSM, 0 AS MARK_RUNOUT, 0 AS MARK_PROBLEM_BAG, 0 AS MARK_LATEBSMS
	FROM #MU_ITEM_ENCODING_REQUEST_TEMP IER, LOCATIONS LOC
	WHERE IER.LOCATION=LOC.LOCATION_ID		
		AND LOC.SUBSYSTEM LIKE 'ME%';

	--3	Query ITEM_REDIRECT with Reason: Unknown License Plate into temp table
	SELECT IRD.GID INTO #MU_ITEM_REDIRECT_TEMP
	FROM ITEM_REDIRECT IRD, LOCATIONS LOC
	WHERE IRD.REASON='12'
		AND IRD.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFROM) AND DATEADD(HOUR,@HOURRANGE,@DTTO)
		AND (IRD.DESTINATION_1=LOC.LOCATION_ID OR IRD.DESTINATION_2=LOC.LOCATION_ID)
		AND LOC.SUBSYSTEM LIKE 'ME%';
	
	CREATE INDEX #MU_ITEM_REDIRECT_TEMP_IDXGID ON #MU_ITEM_REDIRECT_TEMP(GID);

	--3. Update each mark of #MU_MESMARKLIST_TEMP according to ENCODING_TYPE

	--FLIGHT			2	Encoded by Flight Number
	--SCANNING			1	Encoded by License Plate Number
	--DESTINATION		6	Encoded by Airline
	--MAKE-UP			3	Encoded by Destination
	--BSM				SCANNING - LATE BSMS
	--RUNOUT			5	Encoded by Bag Removed
	--PROBLEM STATION	4	Encoded by Problem Bag
	--LATE BSMS			BSM - IRD 12	Sorted by Unknown License Plate Bag Functional Allocation

	UPDATE MMT
	SET 
		MARK_FLIGHT			= CASE MMT.ENCODING_TYPE WHEN '2' THEN 1 ELSE 0 END, 
		MARK_SCANNING		= CASE MMT.ENCODING_TYPE WHEN '1' THEN 1 ELSE 0 END, 
		MARK_DEST_AIRLINE	= CASE MMT.ENCODING_TYPE WHEN '6' THEN 1 ELSE 0 END, 
		MARK_MU				= CASE MMT.ENCODING_TYPE WHEN '3' THEN 1 ELSE 0 END, 
		MARK_BSM			= 0, 
		MARK_RUNOUT			= CASE MMT.ENCODING_TYPE WHEN '5' THEN 1 ELSE 0 END, 
		MARK_PROBLEM_BAG	= CASE MMT.ENCODING_TYPE WHEN '4' THEN 1 ELSE 0 END, 
		MARK_LATEBSMS		= CASE 
									WHEN MMT.ENCODING_TYPE='1' AND  EXISTS (SELECT GID FROM #MU_ITEM_REDIRECT_TEMP MIRD WHERE MMT.GID=MIRD.GID) THEN 1 
									ELSE 0 
							  END 
	FROM #MU_MESMARKLIST_TEMP MMT

	--UPDATE MMT
	--SET MARK_BSM=MARK_SCANNING-MARK_LATEBSMS
	--FROM #MU_MESMARKLIST_TEMP MMT;

	INSERT INTO #MU_MESUTILIZATION_TEMP
	SELECT MMT.LOCATION AS ME_STATION,
		   SUM(MARK_FLIGHT) AS CNT_FLIGHT,
		   SUM(MARK_SCANNING) AS CNT_SCANNING,
		   SUM(MARK_DEST_AIRLINE) AS CNT_DEST_AIRLINE,
		   SUM(MARK_MU) AS CNT_MU,
		   SUM(MARK_SCANNING)-SUM(MARK_LATEBSMS) AS CNT_BSM,
		   SUM(MARK_RUNOUT) AS CNT_RUNOUT,
		   SUM(MARK_PROBLEM_BAG) AS CNT_PROBLEM_BAG,
		   SUM(MARK_LATEBSMS) AS CNT_LATEBSMS
	FROM #MU_MESMARKLIST_TEMP MMT
	GROUP BY MMT.LOCATION;

	SELECT * FROM #MU_MESUTILIZATION_TEMP;
END


--declare @DTFROM datetime='2013-12-19';
--declare @DTTO datetime='2013-12-21';
--exec stp_RPT09_MESUTILIZATION_GWYTEST @DTFROM,@DTTO;
