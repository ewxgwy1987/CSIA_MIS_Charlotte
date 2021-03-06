GO
USE [BHSDB];
GO

ALTER PROCEDURE dbo.stp_RPT11_RUNOUT
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @Subsystem varchar(max)
AS
BEGIN
--Run out is the bags which are proceeded to Dump carousel, 
--but not included in item redirect and manual encoded request(destination) telegram

	DECLARE @HOURRANGE INT=1;
	

	CREATE TABLE #RO_RUNOUT_LIST
	(
		GID VARCHAR(10),
		LICENSE_PLATE VARCHAR(20),
		SUBSYSTEM VARCHAR(20),
		LOCATION VARCHAR(20),
		TIME_STAMP DATETIME,
		REASON VARCHAR(200)
	)

	--1. Find all the bags which is proceeded to dump carousel
	SELECT	IPR.TIME_STAMP,IPR.GID, PRDLOC.LOCATION
	INTO	#RO_DUMPBAG_TEMP
	FROM	ITEM_PROCEEDED IPR, 
			LOCATIONS PRDLOC, 
			FUNCTION_ALLOC_LIST FAL,
			FUNCTION_TYPES FT
	WHERE	IPR.PROCEED_LOCATION=PRDLOC.LOCATION_ID
		AND IPR.PROCEED_TYPE<>'7'
		AND PRDLOC.LOCATION=FAL.RESOURCE
		AND FAL.FUNCTION_TYPE=FT.TYPE 
		AND FT.DESCRIPTION LIKE '%DUMP%'
		AND IPR.TIME_STAMP BETWEEN @DTFrom AND @DTTo;

	--2. Insert the bag GID into temp table except the bags of ITEM_REDIRECT and ITEM_ENCODING_REQUEST(Destination)
	INSERT INTO #RO_RUNOUT_LIST
	SELECT DISTINCT GID, '' AS LICENSE_PLATE,'' AS SUBSYSTEM,'' AS LOCATION,'' AS TIME_STAMP,'' AS REASON
	FROM #RO_DUMPBAG_TEMP RDT
	WHERE NOT EXISTS(SELECT IRD.GID 
					 FROM	ITEM_REDIRECT IRD WITH (NOLOCK)
					 WHERE	IRD.GID=RDT.GID
						AND IRD.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
					)
	  AND NOT EXISTS(SELECT IER.GID 
					 FROM	ITEM_ENCODING_REQUEST IER WITH (NOLOCK)
					 WHERE	IER.GID=RDT.GID
						AND IER.ENCODING_TYPE='3'--Encoded by Destination
						AND IER.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
					)

	--3. Update the sortation infomation according to ITEM_SORTATION_EVENT
	UPDATE	RRL
	SET		RRL.SUBSYSTEM=LOC.SUBSYSTEM,
			RRL.TIME_STAMP=ISE.TIME_STAMP,
			RRL.LICENSE_PLATE=
			CASE
				WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
					THEN ISC.LICENSE_PLATE1
				WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
					THEN ISC.LICENSE_PLATE2
				WHEN LEN(ISC.LICENSE_PLATE1)=10 AND ISC.LICENSE_PLATE1 LIKE '1%'
					THEN ISC.LICENSE_PLATE1 --NULL
				WHEN LEN(ISC.LICENSE_PLATE2)=10 AND ISC.LICENSE_PLATE2 LIKE '1%'
					THEN ISC.LICENSE_PLATE2 --NULL
				ELSE ISC.LICENSE_PLATE1
			END, 
			RRL.LOCATION=LOC.LOCATION,
			RRL.REASON=ISET.DESCRIPTION
	FROM #RO_RUNOUT_LIST RRL, ITEM_SORTATION_EVENT ISE WITH(NOLOCK)
	LEFT JOIN ITEM_SORTATION_EVENT_TYPES ISET  WITH(NOLOCK)
		ON ISE.SORT_EVENT_TYPE=ISET.TYPE
	LEFT JOIN ITEM_SCANNED ISC WITH(NOLOCK)
		ON ISE.GID=ISC.GID
		AND ISC.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
	INNER JOIN LOCATIONS LOC
		ON ISE.LOCATION=LOC.LOCATION_ID
	WHERE RRL.GID=ISE.GID
		AND ISE.TIME_STAMP BETWEEN @DTFrom AND @DTTo
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@Subsystem))

	UPDATE	RRL
	SET		RRL.SUBSYSTEM=LOC.SUBSYSTEM,
			RRL.TIME_STAMP=GID.TIME_STAMP,
			RRL.LICENSE_PLATE='GID: ' + GID.GID,
			RRL.LOCATION=LOC.LOCATION,
			RRL.REASON='Lost Tracking'
	FROM #RO_RUNOUT_LIST RRL, GID_USED GID WITH(NOLOCK)
	LEFT JOIN LOCATIONS LOC ON GID.LOCATION=LOC.LOCATION_ID
	WHERE RRL.GID=GID.GID
		AND GID.BAG_TYPE='02'--STRAY BAG
		AND RRL.TIME_STAMP=''
		AND GID.TIME_STAMP BETWEEN @DTFrom AND @DTTo
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@Subsystem))

	SELECT SUBSYSTEM,TIME_STAMP,LICENSE_PLATE,LOCATION AS EUIPMENT_ID,REASON
	FROM #RO_RUNOUT_LIST
	--WHERE TIME_STAMP<>''
	ORDER BY SUBSYSTEM,TIME_STAMP;

END

--DECLARE @DTFrom datetime='2013-12-16';
--DECLARE @DTTo datetime='2014-1-17';
--DECLARE @Subsystem varchar(max)='MF5,MF6,ML01,ML02,ML03,ML04';
--EXEC stp_RPT11_RUNOUT @DTFrom,@DTTo,@Subsystem;
