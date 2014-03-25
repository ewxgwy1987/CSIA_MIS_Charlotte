GO
USE [BHSDB];
GO

alter PROCEDURE [dbo].[stp_RPT22_CRITICALTRACKINGPEC_GWYTEST]
	@DTFrom DATETIME,
	@DTTo DATETIME
AS
BEGIN
	SET NOCOUNT ON;
	
	DECLARE @HOURRANGE INT=1;
	DECLARE @msgEnter varchar(50)
	DECLARE @msgExit varchar (50)

	set @msgEnter = 'Entering EDS at'
	set @msgExit = 'Exited from EDS at'

	SELECT DISTINCT ITI.GID,
		--CASE 
		--		WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999'
		--			THEN ISC.LICENSE_PLATE1
		--		WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999'
		--			THEN ISC.LICENSE_PLATE2
		--		ELSE 
		--			ITI.GID
		--END AS LICENSE_PLATE 
		CASE
			WHEN ISC.LICENSE_PLATE1 LIKE '0%' AND ISC.LICENSE_PLATE1<>'0000000000' AND ISC.LICENSE_PLATE1<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE1
			WHEN ISC.LICENSE_PLATE2 LIKE '0%' AND ISC.LICENSE_PLATE2<>'0000000000' AND ISC.LICENSE_PLATE2<>'999999999' AND LEN(LICENSE_PLATE1)=10
				THEN ISC.LICENSE_PLATE2
			WHEN LEN(ISC.LICENSE_PLATE1)=10 AND ISC.LICENSE_PLATE1 LIKE '1%'
				THEN ISC.LICENSE_PLATE1 --NULL
			WHEN LEN(ISC.LICENSE_PLATE2)=10 AND ISC.LICENSE_PLATE2 LIKE '1%'
				THEN ISC.LICENSE_PLATE2 --NULL
			ELSE ITI.GID
		END AS LICENSE_PLATE
	INTO #CTP_GID2LPMAP_TEMP
	FROM (	SELECT GID FROM ITEM_TRACKING WITH(NOLOCK) 
			WHERE TIME_STAMP BETWEEN  @DTFrom AND @DTTo
			UNION
			SELECT GID FROM ITEM_PROCEEDED IPR,LOCATIONS LOC WITH(NOLOCK) 
			WHERE TIME_STAMP BETWEEN  @DTFrom AND @DTTo
				AND IPR.LOCATION=LOC.LOCATION_ID
				AND EXISTS(
								SELECT DIVERT_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() 
								WHERE SUBSYSTEM=LOC.SUBSYSTEM AND DIVERT_LOCATION=LOC.LOCATION
						  )
		 ) AS ITI
	LEFT JOIN ITEM_SCANNED ISC WITH(NOLOCK) 
		ON ITI.GID=ISC.GID
		AND ISC.TIME_STAMP BETWEEN  DATEADD(HOUR,-@HOURRANGE,@DTFrom) AND DATEADD(HOUR,@HOURRANGE,@DTTo);

	UPDATE #CTP_GID2LPMAP_TEMP
	SET LICENSE_PLATE=GID
	WHERE LICENSE_PLATE IS NULL;

	CREATE NONCLUSTERED INDEX #CTP_GID2LPMAP_TEMP_IDXGID ON #CTP_GID2LPMAP_TEMP(GID);
	CREATE NONCLUSTERED INDEX #CTP_GID2LPMAP_TEMP_IDXLP ON #CTP_GID2LPMAP_TEMP(LICENSE_PLATE);
	
	/**Upstream of Xray**/
	SELECT	G2L.LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			@msgEnter +' '+ LOC.LOCATION AS ACT, 
			ITI.TIME_STAMP, 
			'Entered' AS XRAY_STAT
	FROM ITEM_TRACKING AS ITI, LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	WHERE ITI.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		AND ITI.LOCATION=LOC.LOCATION_ID
		AND ITI.GID=G2L.GID
		AND EXISTS(
					SELECT PRE_XM_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() 
					WHERE SUBSYSTEM=LOC.SUBSYSTEM AND PRE_XM_LOCATION=LOC.LOCATION
				  )
		--AND (LOC.LOCATION IN('SS1-06','SS2-06','SS3-06','SS4-06'))
	

	/**Downstream of Xray**/
	UNION ALL
	SELECT	G2L.LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			@msgExit + ' '+ LOC.LOCATION AS ACT, 
			ITI.TIME_STAMP, 
			(	SELECT TOP 1 
					CASE 
						WHEN (ITI.TIME_STAMP < ICR.TIME_STAMP)OR (ICR_TYPE.DESCRIPTION) IS NULL 
							THEN '-'
						ELSE 
							(/*'Screen Level ' + ICR.SCREEN_LEVEL + CHAR(10) + CHAR(13) +*/ ICR_TYPE.DESCRIPTION) 
					END 
				FROM ITEM_SCREENED AS ICR WITH(NOLOCK)
				INNER JOIN ITEM_SCREEN_RESULT_TYPES AS ICR_TYPE ON ICR.RESULT_TYPE = ICR_TYPE.TYPE
				WHERE ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo
					AND ITI.GID = ICR.GID
				ORDER BY ICR.TIME_STAMP DESC
			) AS XRAY_STAT
		FROM ITEM_TRACKING AS ITI , LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
		WHERE ITI.TIME_STAMP BETWEEN @DTFrom AND @DTTo
			AND ITI.LOCATION=LOC.LOCATION_ID
			AND ITI.GID=G2L.GID
			AND EXISTS(
						SELECT POST_XM_LOCATION FROM GET_RPT_EDS_LINE_DEVICE() 
						WHERE SUBSYSTEM=LOC.SUBSYSTEM AND POST_XM_LOCATION=LOC.LOCATION
					  )
			--AND LOC.LOCATION IN ('SS1-EXT','SS2-EXT','SS3-EXT','SS4-EXT')
	
	
	/**After Divert Point**/
	UNION ALL
	SELECT	G2L.LICENSE_PLATE AS LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			'At Divert Point: '+ LOC.LOCATION + CHAR(10) + CHAR(13) +'Diverted to ' + PRD_LOC.LOCATION  AS ACT, 
			IPR.TIME_STAMP, 
			(	SELECT TOP 1 
					CASE 
						WHEN (IPR.TIME_STAMP < ICR.TIME_STAMP) OR (ICR_TYPE.DESCRIPTION) IS NULL 
							THEN '-' 
						ELSE 
							(/*'Screen Level ' + ICR.SCREEN_LEVEL + CHAR(10) + CHAR(13) +*/ ICR_TYPE.DESCRIPTION)
					END
				FROM ITEM_SCREENED AS ICR 
				INNER JOIN ITEM_SCREEN_RESULT_TYPES AS ICR_TYPE ON ICR.RESULT_TYPE = ICR_TYPE.TYPE
				WHERE (ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo) AND (ICR.GID = IPR.GID)
				ORDER BY ICR.TIME_STAMP
			) AS XRAY_STAT
	FROM ITEM_PROCEEDED AS IPR , LOCATIONS LOC, LOCATIONS PRD_LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	WHERE IPR.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		AND IPR.LOCATION=LOC.LOCATION_ID
		AND IPR.GID=G2L.GID
		AND IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		AND EXISTS(
						SELECT DIVERT_LOCATION 
						FROM GET_RPT_EDS_LINE_DEVICE() ELD
						WHERE ((ELD.SUBSYSTEM=LOC.SUBSYSTEM AND ELD.DIVERT_LOCATION=LOC.LOCATION)
							OR LOC.LOCATION IN ('OOG1-15A','OOG2-17A','ED9-33A'))
				  )
		--AND (PRD_LOC.LOCATION IN ('CL1-02','AL1-02','CL2-02','AL2-02','CL3-02','AL3-02','CL4-02','AL4-02','CL6-01','AL1-11')) 
	
	
	--/**Before divert point**/
	--UNION ALL	
	--SELECT	G2L.LICENSE_PLATE AS LICENSE_PLATE, 
	--		(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
	--		'Prior to Divert Point at' + ' '+ ITI.LOCATION AS ACT, ITI.TIME_STAMP,
	--		(	SELECT TOP 1 
	--				CASE 
	--					WHEN (ITI.TIME_STAMP < ICR.TIME_STAMP)OR (ICR_TYPE.DESCRIPTION) IS NULL 
	--						THEN '-'	 
	--					ELSE 
	--						('Screen Level ' + ICR.SCREEN_LEVEL + ':' + ICR_TYPE.DESCRIPTION) 
	--				END 
	--			 FROM ITEM_SCREENED AS ICR WITH(NOLOCK)
	--			 INNER JOIN ITEM_SCREEN_RESULT_TYPES AS ICR_TYPE ON ICR.RESULT_TYPE = ICR_TYPE.TYPE
	--			 WHERE (ICR.TIME_STAMP BETWEEN @DTFrom AND @DTTo)AND(ITI.GID = ICR.GID)
	--			 ORDER BY ICR.TIME_STAMP
	--		) AS XRAY_STAT
	--FROM ITEM_TRACKING AS ITI , LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	--WHERE ITI.TIME_STAMP BETWEEN @DTFrom AND @DTTo
	--	AND ITI.LOCATION=LOC.LOCATION_ID
	--	AND ITI.GID=G2L.GID
	--	AND LOC.LOCATION IN ('SS1-12','SS2-12','SS3-12','SS4-12','AL1-08A')
	
	
	/**Lost Track**/
	UNION ALL	
	SELECT	G2L.LICENSE_PLATE AS LICENSE_PLATE, 
			LOC.SUBSYSTEM AS SUBSYSTEM,
			--(SELECT XRAY_ID FROM GET_RPT_EDS_LINE_DEVICE() WHERE SUBSYSTEM = LOC.SUBSYSTEM) AS XRAY_ID,
			'Lost tracking at '+ LOC.LOCATION as ACT,
			ILT.TIME_STAMP, '-' AS STAT		
	FROM ITEM_LOST AS ILT, LOCATIONS LOC, #CTP_GID2LPMAP_TEMP G2L WITH(NOLOCK)
	WHERE ILT.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
		AND ILT.LOCATION=LOC.LOCATION_ID
		AND ILT.GID=G2L.GID
		AND LOC.LOCATION LIKE 'ED%'
	
	ORDER BY TIME_STAMP,LICENSE_PLATE,SUBSYSTEM;
		
END

--DECLARE @DTFrom [datetime]='2014-1-11';
--DECLARE @DTTo [datetime]='2014-1-12';
--EXEC stp_RPT22_CRITICALTRACKINGPEC_GWYTEST @DTFrom,@DTTo;