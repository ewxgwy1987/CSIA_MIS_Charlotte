GO
USE [BHSDB];
GO

ALTER PROCEDURE dbo.stp_RPT_CLT_RUNOUT
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
	--0. Find the Dump carousel
	DECLARE @DUMPLOC VARCHAR(20) = (SELECT TOP 1 FAL.RESOURCE FROM FUNCTION_ALLOC_LIST FAL WHERE FAL.FUNCTION_TYPE='DUMP');

	--1. Find all the bags which is proceeded to dump carousel
	SELECT	IPR.TIME_STAMP,IPR.GID, PRDLOC.LOCATION
	INTO	#RO_DUMPBAG_TEMP
	FROM	ITEM_PROCEEDED IPR, 
			LOCATIONS PRDLOC
	WHERE	IPR.PROCEED_LOCATION=PRDLOC.LOCATION_ID
		--AND IPR.PROCEED_TYPE<>'7' --7	Proceeded to run-out pier
		AND PRDLOC.LOCATION LIKE (@DUMPLOC+'%')
		AND IPR.TIME_STAMP BETWEEN @DTFrom AND @DTTo;

	--2. Insert the bag GID into temp table except the bags of ITEM_REDIRECT and ITEM_ENCODING_REQUEST(Destination)
	INSERT INTO #RO_RUNOUT_LIST
	SELECT DISTINCT GID, '' AS LICENSE_PLATE,'' AS SUBSYSTEM,'' AS LOCATION,NULL AS TIME_STAMP,'' AS REASON
	FROM #RO_DUMPBAG_TEMP RDT
	WHERE NOT EXISTS(SELECT IRD.GID 
					 FROM	ITEM_REDIRECT IRD,LOCATIONS LOC WITH (NOLOCK)
					 WHERE	IRD.GID=RDT.GID
						AND IRD.DESTINATION_1=LOC.LOCATION_ID AND LOC.LOCATION=@DUMPLOC
						AND IRD.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
					)
	  AND NOT EXISTS(SELECT IEC.GID 
					 FROM	ITEM_ENCODED IEC,LOCATIONS LOC WITH (NOLOCK)
					 WHERE	IEC.GID=RDT.GID
						AND IEC.ENCODING_TYPE='3'--Encoded by Destination
						AND IEC.DEST=LOC.LOCATION_ID AND LOC.LOCATION=@DUMPLOC
						AND IEC.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
					)

	--3. Query the ATR read info into temp table #BT_ITEM_TAGREAD_TEMP
	SELECT ISC.GID, ISC.LICENSE_PLATE1, ISC.LICENSE_PLATE2, ISC.LOCATION, ISC.TIME_STAMP 
	INTO #RO_ITEM_TAGREAD_TEMP
	FROM ITEM_SCANNED ISC, #RO_RUNOUT_LIST RNOT WITH(NOLOCK)
	WHERE ISC.GID=RNOT.GID
		AND ISC.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)
		AND (ISC.STATUS_TYPE='1' OR ISC.STATUS_TYPE='3' OR ISC.STATUS_TYPE='7');
	--ORDER BY ISC.TIME_STAMP DESC; 

	--4. Query the MES read info into temp table #BT_ITEM_TAGREAD_TEMP 
	INSERT INTO #RO_ITEM_TAGREAD_TEMP
	SELECT IEC.GID,IEC.LICENSE_PLATE AS LICENSE_PLATE1,'0000000000' AS LICENSE_PLATE2,IEC.LOCATION,IEC.TIME_STAMP 
	FROM ITEM_ENCODED IEC,#RO_RUNOUT_LIST RNOT WITH(NOLOCK)
	WHERE IEC.GID=RNOT.GID
		AND IEC.LICENSE_PLATE IS NOT NULL AND LEN(IEC.LICENSE_PLATE)<>0
		AND IEC.TIME_STAMP BETWEEN DATEADD(DAY,-@HOURRANGE,@DTFROM) AND DATEADD(DAY,@HOURRANGE,@DTTO)

	--5. The latest sortation event timestamp for each gid
	SELECT ISE.GID,ISE.LOCATION,ISE.SORT_DESTINATION,ISE.SORT_EVENT_TYPE,ISE.TIME_STAMP
	INTO #RO_ITEM_SORTATION_EVENT_TEMP
	FROM ITEM_SORTATION_EVENT ISE
	WHERE ISE.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
		AND EXISTS(SELECT GID FROM #RO_RUNOUT_LIST RRL WHERE ISE.GID=RRL.GID)

	SELECT ISE.GID,ISE.TIME_STAMP,LOC.SUBSYSTEM,LOC.LOCATION,ISET.DESCRIPTION
	INTO #RO_ISE_LATEST_TEMP
	FROM #RO_ITEM_SORTATION_EVENT_TEMP ISE, #RO_RUNOUT_LIST RRL, ITEM_SORTATION_EVENT_TYPES ISET, LOCATIONS LOC
	WHERE RRL.GID=ISE.GID
		AND ISE.SORT_EVENT_TYPE=ISET.TYPE
		AND ISE.LOCATION=LOC.LOCATION_ID
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@Subsystem))
		AND ISE.TIME_STAMP=(SELECT MAX(ISE2.TIME_STAMP) FROM #RO_ITEM_SORTATION_EVENT_TEMP ISE2 WHERE ISE2.GID=ISE.GID);

	--6. Update the sortation infomation according to #RO_ISE_LATEST_TEMP
	UPDATE	RRL
	SET		RRL.SUBSYSTEM=ISEL.SUBSYSTEM,
			RRL.TIME_STAMP=ISEL.TIME_STAMP,
			RRL.LICENSE_PLATE=
			CASE
				--IATA TAG
				WHEN TGR.LICENSE_PLATE1 LIKE '0%' AND TGR.LICENSE_PLATE1<>'0000000000' AND TGR.LICENSE_PLATE1<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
					THEN TGR.LICENSE_PLATE1
				WHEN TGR.LICENSE_PLATE2 LIKE '0%' AND TGR.LICENSE_PLATE2<>'0000000000' AND TGR.LICENSE_PLATE2<>'999999999' AND LEN(TGR.LICENSE_PLATE1)=10
					THEN TGR.LICENSE_PLATE2
				--FALLBACK TAG
				WHEN LEN(TGR.LICENSE_PLATE1)=10 AND TGR.LICENSE_PLATE1 LIKE '1%'
					THEN TGR.LICENSE_PLATE1 --NULL
				WHEN LEN(TGR.LICENSE_PLATE2)=10 AND TGR.LICENSE_PLATE2 LIKE '1%'
					THEN TGR.LICENSE_PLATE2 --NULL
				--4 DIGIT TAG
				WHEN LEN(TGR.LICENSE_PLATE1)=4
					THEN TGR.LICENSE_PLATE1
				WHEN LEN(TGR.LICENSE_PLATE2)=4
					THEN TGR.LICENSE_PLATE2
				ELSE TGR.LICENSE_PLATE1
			END, 
			RRL.LOCATION=ISEL.LOCATION,
			RRL.REASON=ISEL.DESCRIPTION
	FROM #RO_RUNOUT_LIST RRL, #RO_ISE_LATEST_TEMP ISEL
	LEFT JOIN #RO_ITEM_TAGREAD_TEMP TGR WITH(NOLOCK)
		ON ISEL.GID=TGR.GID
	WHERE RRL.GID=ISEL.GID
		

	--7. ITEM_LOST TO DUMP
	UPDATE	RRL
	SET		RRL.SUBSYSTEM=LOC.SUBSYSTEM,
			RRL.TIME_STAMP=GID.TIME_STAMP,
			RRL.LICENSE_PLATE='GID: ' + GID.GID,
			RRL.LOCATION=LOC.LOCATION,
			RRL.REASON='Stray Bag'--'Lost Tracking'
	FROM #RO_RUNOUT_LIST RRL, GID_USED GID WITH(NOLOCK)
	INNER JOIN LOCATIONS LOC ON GID.LOCATION=LOC.LOCATION_ID
	WHERE RRL.GID=GID.GID
		AND GID.BAG_TYPE='02'--STRAY BAG
		AND RRL.TIME_STAMP IS NULL
		AND GID.TIME_STAMP BETWEEN DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo)
		AND LOC.SUBSYSTEM IN (SELECT * FROM DBO.RPT_GETPARAMETERS(@Subsystem))

	SELECT GID,SUBSYSTEM,TIME_STAMP,LICENSE_PLATE,LOCATION AS EUIPMENT_ID,REASON
	FROM #RO_RUNOUT_LIST
	--WHERE TIME_STAMP<>''
	ORDER BY SUBSYSTEM,TIME_STAMP;

END

--DECLARE @DTFrom datetime='2014-03-01';
--DECLARE @DTTo datetime='2014-03-25';
--DECLARE @Subsystem varchar(max)='ML1';
--EXEC stp_RPT_OKC_RUNOUT @DTFrom,@DTTo,@Subsystem;
