GO
USE [BHSDB];
GO

alter PROCEDURE dbo.stp_RPT_CLT_BAGTRACE
		  @DTFROM DATETIME,
		  @DTTO DATETIME,
		  @GID VARCHAR(10),
		  @LICENSE_PLATE VARCHAR (10),
		  @LOGIC VARCHAR(10)
AS
BEGIN
	PRINT 'BAG TRACE REPORT BEGIN';

	SET NOCOUNT ON;

	DECLARE @MINUTERANGE INT=0;
	DECLARE @SECONDRANGE INT=10;

	--Create a temp table used to store all the gid belonging to the searched bag
	CREATE TABLE #BT_BAG_GIDLIST_TEMP
	(
		--TIME_STAMP DATETIME,
		GID VARCHAR(10)
	);

	--Create a temp table used to store all the event
	CREATE TABLE #BT_BAG_TRACE_TEMP
	(
		TIME_STAMP DATETIME,
		BAG_GID VARCHAR(10),
		BAG_EVENT VARCHAR(2000)
	);

	--QUERY ALL 
	
	DECLARE @STD_LICENSE_PLATE VARCHAR(10)=NULL;

	--1. If the license plate is Fall Back tag, then find the corresponding IATA tag
	IF @LICENSE_PLATE IS NOT NULL AND @LICENSE_PLATE<>'' AND @LICENSE_PLATE LIKE '1%'
	BEGIN 
		SET @STD_LICENSE_PLATE =
		(  SELECT DISTINCT TOP 1
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
				END AS LICENSE_PLATE
			FROM ITEM_SCANNED ISC WITH(NOLOCK)
			WHERE (ISC.LICENSE_PLATE1=@LICENSE_PLATE OR ISC.LICENSE_PLATE2=@LICENSE_PLATE)
				AND ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO
		)

		
	END
	ELSE IF @LICENSE_PLATE LIKE '0%' AND @LICENSE_PLATE<>'0000000000'
	BEGIN
		SET @STD_LICENSE_PLATE = @LICENSE_PLATE;
	END
	

	IF @STD_LICENSE_PLATE IS NULL AND (@GID IS NULL OR @GID='')
	BEGIN
		SELECT * FROM #BT_BAG_TRACE_TEMP;
		RETURN;
	END

	--SELECT * FROM GID_USED;
	--SELECT * FROM ITEM_SCANNED;
	--SELECT * FROM ITEM_SCAN_STATUS_TYPES;
	--SELECT * FROM ITEM_MEASURED im;
	--SELECT * FROM ITEM_MEASURED_TYPES imt;
	--SELECT * FROM ITEM_TRACKING it;
	--SELECT * FROM ITEM_SCREENED ;
	--SELECT * FROM ITEM_SCREEN_RESULT_TYPES isrt;
	--SELECT * FROM ITEM_PROCEEDED;
	--SELECT * FROM ITEM_PROCEED_TYPES;
	--SELECT * FROM ITEM_1500P ip;
	--SELECT * FROM ITEM_1500P_BAGSTATS ipb;
	--SELECT * FROM ITEM_REDIRECT ir;
	--SELECT * FROM SORTATION_REASON sr;
	--SELECT * FROM ITEM_ENCODING_REQUEST;
	--SELECT * FROM ITEM_ENCODING_REQUEST_TYPES;
	--SELECT * FROM ITEM_SORTATION_EVENT ise;
	--SELECT * FROM ITEM_SORTATION_EVENT_TYPES iset;
	--SELECT * FROM ITEM_LOST il;
	
	--3. Find all the GID belonging to STD_LICENSE_PLATE, and insert them into #BT_BAG_GIDLIST_TEMP
	IF @STD_LICENSE_PLATE IS NOT NULL
	BEGIN
		INSERT INTO #BT_BAG_GIDLIST_TEMP(GID)
		SELECT DISTINCT GID FROM
		(
			SELECT DISTINCT TIME_STAMP, GID
			FROM ITEM_SCANNED ISC WITH(NOLOCK)
			WHERE (ISC.LICENSE_PLATE1=@STD_LICENSE_PLATE OR ISC.LICENSE_PLATE2=@STD_LICENSE_PLATE)
				AND ISC.TIME_STAMP BETWEEN @DTFROM AND @DTTO

			UNION ALL
			SELECT DISTINCT TIME_STAMP,GID
			FROM ITEM_1500P P1500 WITH(NOLOCK)
			WHERE P1500.LICENSE_PLATE=@STD_LICENSE_PLATE
				AND P1500.TIME_STAMP BETWEEN @DTFROM AND @DTTO

			UNION ALL
			SELECT DISTINCT TIME_STAMP,GID
			FROM ITEM_ENCODED IEC WITH(NOLOCK)
			WHERE IEC.LICENSE_PLATE=@STD_LICENSE_PLATE
				AND IEC.TIME_STAMP BETWEEN @DTFROM AND @DTTO

			UNION ALL
			SELECT DISTINCT TIME_STAMP,GID
			FROM ITEM_REMOVED IRM WITH(NOLOCK)
			WHERE IRM.LICENSE_PLATE=@STD_LICENSE_PLATE
				AND IRM.TIME_STAMP BETWEEN @DTFROM AND @DTTO

		) AS GIDLIST
	END

	--SELECT * FROM #BT_BAG_GIDLIST_TEMP;
	--4. If the @LOGIC is 'AND', then search bag trace info by @GID AND @STD_LICENSE_PLATE
	--   If the @LOGIC is 'OR', then search bag trace info by @GID or @STD_LICENSE_PLATE
	IF NOT EXISTS(SELECT * FROM #BT_BAG_GIDLIST_TEMP WHERE GID=@GID)
	BEGIN
		INSERT INTO #BT_BAG_GIDLIST_TEMP
		VALUES (@GID);
	END

	IF @LOGIC='AND' AND (@GID IS NOT NULL AND @GID<>'')
	BEGIN
		DELETE FROM #BT_BAG_GIDLIST_TEMP
		WHERE GID<>@GID
	END
	--ELSE IF @LOGIC='OR' AND (@GID IS NOT NULL AND @GID<>'')
	--BEGIN
	--	IF NOT EXISTS(SELECT * FROM #BT_BAG_GIDLIST_TEMP WHERE GID=@GID)
	--	BEGIN
	--		INSERT INTO #BT_BAG_GIDLIST_TEMP
	--		VALUES (@GID);
	--	END
	--END

	--SELECT * FROM #BT_BAG_GIDLIST_TEMP;
	--Find all corresponding GID for the searched license plate

	INSERT INTO #BT_BAG_TRACE_TEMP(TIME_STAMP,BAG_GID,BAG_EVENT)
		--SELECT * FROM GID_USED;
		SELECT	GUD.TIME_STAMP,
				GUD.GID,
				/*'Bag[GID:'+ GUD.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'GID generated at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+GUD.LOCATION+']') + ' as ' + 
				CASE GUD.BAG_TYPE
					WHEN '01' THEN 'Normal Bag.'
					WHEN '02' THEN 'Stray Bag.' 
						+	CASE --FAIL SAFE: STAY BAG IN DIVERTER TO CLEAR LINE
								WHEN EXISTS(SELECT MALM.ALM_STARTTIME
											FROM GET_RPT_EDS_LINE_DEVICE() EDSL,MDS_ALARMS MALM WITH(NOLOCK)
											WHERE MALM.ALM_ALMAREA2 ='AA_FSAL'
												AND LOC.LOCATION IS NOT NULL
												AND EDSL.CLEAR_LOCATION=LOC.LOCATION
												AND MALM.ALM_ALMEXTFLD2=
													SUBSTRING(LOC.LOCATION,1,CHARINDEX('B',LOC.LOCATION)-1)
												AND MALM.ALM_STARTTIME BETWEEN DATEADD(SECOND,-@SECONDRANGE,GUD.TIME_STAMP) AND DATEADD(SECOND,@SECONDRANGE,GUD.TIME_STAMP)
											)
								THEN '[Fail Safe]'
							ELSE ''
						END
				END AS BAG_EVENT
 		FROM	#BT_BAG_GIDLIST_TEMP BBG, GID_USED GUD WITH (NOLOCK)
		LEFT JOIN  LOCATIONS LOC ON GUD.LOCATION=LOC.LOCATION_ID
		WHERE	GUD.GID=BBG.GID
				AND GUD.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_MEASURED im;
		--SELECT * FROM ITEM_MEASURED_TYPES imt;
		UNION ALL
		SELECT	BMAM.TIME_STAMP,
				BMAM.GID,
				/*'Bag[GID:'+ BMAM.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Measured at '
				+ COALESCE(LOC.LOCATION,'Invalid location['+BMAM.LOCATION+']') + ' ' 
				+ '[' + IMT.DESCRIPTION + ']. ' + CHAR(10) + CHAR(13) +
				+ 'Length: ' + CAST(FORMAT(BMAM.LENGTH,'00') AS VARCHAR) + 'mm, ' 
				+ 'Width: ' + CAST(FORMAT(BMAM.WIDTH,'00') AS VARCHAR) + 'mm, ' 
				+ 'Height: ' + CAST(FORMAT(BMAM.HEIGHT,'00') AS VARCHAR) + 'mm'
				+ '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_MEASURED_TYPES IMT, ITEM_MEASURED BMAM WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON BMAM.LOCATION=LOC.LOCATION_ID
		WHERE	BMAM.TYPE=IMT.TYPE
				AND BMAM.GID=BBG.GID
				AND BMAM.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		
		--SELECT * FROM ITEM_SCANNED;
		--SELECT * FROM ITEM_SCAN_STATUS_TYPES;
		UNION ALL
		SELECT	ISC.TIME_STAMP,
				ISC.GID,
				/*'Bag[GID:'+ ISC.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Scanned at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+ISC.LOCATION+']') + ' ' 
				+ '[' + ISCT.DESCRIPTION + ']. '
				+ CASE 
						WHEN ISC.LICENSE_PLATE1 IS NOT NULL AND RTRIM(LTRIM(ISC.LICENSE_PLATE1))<>''
							THEN 'License Plate1:' + ISC.LICENSE_PLATE1 + '   ' 
						ELSE ''
				  END
				+ CASE 
						WHEN ISC.LICENSE_PLATE1 IS NOT NULL AND RTRIM(LTRIM(ISC.LICENSE_PLATE2))<>''
							THEN 'License Plate2:' + ISC.LICENSE_PLATE2 + '   ' 
						ELSE ''
				  END
				+ '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_SCAN_STATUS_TYPES ISCT, ITEM_SCANNED ISC WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ISC.LOCATION=LOC.LOCATION_ID
		WHERE	ISC.STATUS_TYPE=ISCT.TYPE
				AND ISC.GID=BBG.GID
				AND ISC.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_TRACKING it;
		UNION ALL
		SELECT	ITI.TIME_STAMP,
				ITI.GID,
				/*'Bag[GID:'+ ITI.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Bag Reached at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+ITI.LOCATION+']') + '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_TRACKING ITI WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ITI.LOCATION=LOC.LOCATION_ID
		WHERE	ITI.GID=BBG.GID
				AND ITI.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_SCREENED ;
		--SELECT * FROM ITEM_SCREEN_RESULT_TYPES isrt;
		UNION ALL
		SELECT	ICR.TIME_STAMP,
				ICR.GID,
				/*'Bag[GID:'+ ICR.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Screened at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+ICR.LOCATION+']') +  ' ' 
				/*+ 'with Screen Level [' + ICR.SCREEN_LEVEL+ ']. '*/
				+ 'Screen Result ['+ ICRT.DESCRIPTION + '].' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_SCREEN_RESULT_TYPES ICRT, ITEM_SCREENED ICR WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ICR.LOCATION=LOC.LOCATION_ID
		WHERE	ICR.RESULT_TYPE=ICRT.TYPE
				AND ICR.GID=BBG.GID
				AND ICR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_PROCEEDED;
		--SELECT * FROM ITEM_PROCEED_TYPES;
		UNION ALL
		SELECT	IPR.TIME_STAMP,
				IPR.GID,
				/*'Bag[GID:'+ IPR.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Proceed from ' 
				+ COALESCE(AT_LOC.LOCATION,'Invalid location['+IPR.LOCATION+']')+ ' to ' 
				+ COALESCE(PRD_LOC.LOCATION,'Invalid location['+IPR.PROCEED_LOCATION+']') + ' '
				+ '[' + IPRT.DESCRIPTION + '].' AS BAG_EVENT
		FROM	 #BT_BAG_GIDLIST_TEMP BBG, ITEM_PROCEED_TYPES IPRT, ITEM_PROCEEDED IPR WITH(NOLOCK)
		LEFT JOIN LOCATIONS AT_LOC ON IPR.LOCATION=AT_LOC.LOCATION_ID
		LEFT JOIN LOCATIONS PRD_LOC ON IPR.PROCEED_LOCATION=PRD_LOC.LOCATION_ID
		WHERE	IPR.PROCEED_TYPE=IPRT.TYPE
				AND IPR.GID=BBG.GID
				AND IPR.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_1500P ip;
		--SELECT * FROM ITEM_1500P_BAGSTATS ipb;
		UNION ALL
		SELECT	IP.TIME_STAMP,
				IP.GID,
				/*'Bag[GID:'+ IP.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Reached CBRA Area at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+IP.LOCATION+']') + ' '
				+ '[' +COALESCE(IPT.DESCRIPTION,'Invalid TYPE:'+IP.BAG_STATUS) + ']. ' 
				+ 'CBRA XRAY_ID:' + IP.XRAY_ID + ' BIT Station:' + IP.BIT_STATION + ' ETD Station:' + IP.ETD_STATION + '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG,  ITEM_1500P IP WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IP.LOCATION=LOC.LOCATION_ID
		LEFT JOIN ITEM_1500P_BAGSTATS IPT ON IP.BAG_STATUS=IPT.TYPE
		WHERE	IP.GID=BBG.GID
				AND IP.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_REDIRECT ir;
		--SELECT * FROM SORTATION_REASON sr;
		UNION ALL
		SELECT	IRD.TIME_STAMP,
				IRD.GID,
				/*'Bag[GID:'+ IRD.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Redirected to ' 
				+ CASE WHEN DES1_LOC.LOCATION IS NOT NULL THEN ' Destination1: '+ DES1_LOC.LOCATION + ' '
					   WHEN IRD.DESTINATION_1='4500' THEN  ' Destination1: MES ' ELSE '' END
				+ CASE WHEN DES2_LOC.LOCATION IS NOT NULL THEN ' Destination2: '+ DES2_LOC.LOCATION + '. '
					   WHEN IRD.DESTINATION_2='4500' THEN  ' Destination2: MES. ' ELSE '. ' END
				--+ COALESCE(' Destination1: '+DES1_LOC.LOCATION,IRD.DESTINATION_1)  + ' '
				--+ COALESCE(', Destination2: '+DES2_LOC.LOCATION,IRD.DESTINATION_1) + '. '
				+ 'Reason: [' + IRDR.DESCRIPTION + '].' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, SORTATION_REASON IRDR, ITEM_REDIRECT IRD WITH(NOLOCK)
		LEFT JOIN LOCATIONS DES1_LOC ON IRD.DESTINATION_1=DES1_LOC.LOCATION_ID
		LEFT JOIN LOCATIONS DES2_LOC ON IRD.DESTINATION_2=DES2_LOC.LOCATION_ID
		WHERE	IRD.REASON=IRDR.REASON
				AND IRD.GID=BBG.GID
				AND IRD.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_ENCODING_REQUEST;
		--SELECT * FROM ITEM_ENCODING_REQUEST_TYPES;
		--UNION ALL
		--SELECT	MER.TIME_STAMP,
		--		MER.GID,
		--		/*'Bag[GID:'+ MER.GID + ']'+ CHAR(10) + CHAR(13) +*/
		--		'Encoded at ' 
		--		+ COALESCE(LOC.LOCATION,'Invalid location ['+MER.LOCATION+']') + ' '
		--		+ '[' + ISNULL(MERT.DESCRIPTION,'') + ']. ' 
		--		+ CASE MER.ENCODING_TYPE
		--			WHEN '1' THEN ISNULL('LICENSE PLATE[' + MER.LICENSE_PLATE + '] , ','') 
		--			WHEN '2' THEN ISNULL('AIRLINE[' + UPPER(MER.AIRLINE) + '] , ' ,'')+ISNULL('FLIGHT NUMBER[' + MER.FLIGHT_NUMBER + '] , ' ,'')
		--			WHEN '3' THEN ''
		--			WHEN '4' THEN ''
		--			WHEN '5' THEN ''
		--			WHEN '6' THEN ISNULL('AIRLINE[' + UPPER(MER.AIRLINE) + '] , ' ,'')
		--			ELSE ''
		--		  END
		--		--ISNULL('SDO[' + MER.SDO + '] , ','')
		--		+ ISNULL('DESTINATION[' + DETLOC.LOCATION + ']. ','')
		--		 AS BAG_EVENT
		--FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_ENCODING_REQUEST_TYPES MERT, ITEM_ENCODING_REQUEST MER WITH(NOLOCK)
		--LEFT JOIN LOCATIONS LOC ON MER.LOCATION=LOC.LOCATION_ID
		--LEFT JOIN LOCATIONS DETLOC ON MER.DESTINATION=DETLOC.LOCATION_ID
		--WHERE	MER.ENCODING_TYPE=MERT.TYPE
		--		AND MER.GID=BBG.GID
		--		AND MER.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
		--		AND MER.TIME_STAMP=( SELECT MAX(TIME_STAMP) FROM ITEM_ENCODING_REQUEST MER2 WITH(NOLOCK) WHERE MER.GID=MER2.GID )
		
		--SELECT * FROM ITEM_READY;
		UNION ALL
		SELECT	IRY.TIME_STAMP,
				IRY.GID,
				/*'Bag[GID:'+ IPR.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Bag Ready for encoding at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+IRY.LOCATION+']') AS BAG_EVENT
		FROM	 #BT_BAG_GIDLIST_TEMP BBG, ITEM_READY IRY WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IRY.LOCATION=LOC.LOCATION_ID
		WHERE	IRY.GID=BBG.GID
				AND IRY.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_REMOVED;
		UNION ALL
		SELECT	IRM.TIME_STAMP,
				IRM.GID,
				/*'Bag[GID:'+ ITI.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Bag Removed at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location['+IRM.LOCATION+']') + '.' AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_REMOVED IRM WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IRM.LOCATION=LOC.LOCATION_ID
		WHERE	IRM.GID=BBG.GID
				AND IRM.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_ENCODED;
		--SELECT * FROM ITEM_ENCODING_REQUEST_TYPES;
		UNION ALL
		SELECT	IEC.TIME_STAMP,
				IEC.GID,
				/*'Bag[GID:'+ MER.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Encoded at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location ['+IEC.LOCATION+']') + ' '
				+ '[' + ISNULL(IERT.DESCRIPTION,'') + ']. ' 
				+ CASE IEC.ENCODING_TYPE
					WHEN '1' THEN ISNULL('LICENSE PLATE[' + IEC.LICENSE_PLATE + '] , ','') 
					WHEN '2' THEN ISNULL('AIRLINE[' + UPPER(IEC.AIRLINE) + '] , ' ,'')+ISNULL('FLIGHT NUMBER[' + IEC.FLIGHT_NUMBER + '] , ' ,'')
					WHEN '3' THEN ''
					WHEN '4' THEN ''
					WHEN '5' THEN ''
					WHEN '6' THEN ISNULL('AIRLINE[' + UPPER(IEC.AIRLINE) + '] , ' ,'')
					ELSE ''
				  END
				--ISNULL('SDO[' + MER.SDO + '] , ','')
				+ ISNULL('DESTINATION[' + DETLOC.LOCATION + ']. ','')
				 AS BAG_EVENT
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_ENCODING_REQUEST_TYPES IERT, ITEM_ENCODED IEC WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON IEC.LOCATION=LOC.LOCATION_ID
		LEFT JOIN LOCATIONS DETLOC ON IEC.DEST=DETLOC.LOCATION_ID
		WHERE	IEC.ENCODING_TYPE=IERT.TYPE
				AND IEC.GID=BBG.GID
				AND IEC.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
				AND IEC.TIME_STAMP=( SELECT MAX(TIME_STAMP) FROM ITEM_ENCODED IEC2 WITH(NOLOCK) WHERE IEC.GID=IEC2.GID )

		--SELECT * FROM ITEM_SORTATION_EVENT ise;
		--SELECT * FROM ITEM_SORTATION_EVENT_TYPES iset;
		UNION ALL
		SELECT	ISE.TIME_STAMP,
				ISE.GID,
				/*'Bag[GID:'+ ISE.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Sortation event at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location ['+ISE.LOCATION+']') + ' '
				+ '[' + ISET.DESCRIPTION + '], ' 
				+ 'and new destination is ' + COALESCE(SORT_LOC.LOCATION,'['+ISE.SORT_DESTINATION+']') + '.' AS BAG_EVENT 
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_SORTATION_EVENT_TYPES ISET, ITEM_SORTATION_EVENT ISE WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ISE.LOCATION=LOC.LOCATION_ID
		LEFT JOIN LOCATIONS SORT_LOC ON ISE.SORT_DESTINATION=SORT_LOC.LOCATION_ID
		WHERE	ISE.SORT_EVENT_TYPE=ISET.TYPE
				AND ISE.GID=BBG.GID
				AND ISE.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		--SELECT * FROM ITEM_LOST il;
		UNION ALL
		SELECT	ITL.TIME_STAMP,
				ITL.GID,
				/*'Bag[GID:'+ ITL.GID + ']'+ CHAR(10) + CHAR(13) +*/
				'Lost tracking at ' 
				+ COALESCE(LOC.LOCATION,'Invalid location ['+ITL.LOCATION+']') + '.' 
				--FAIL SAFE: BAG LOST IN DIVERTER TO ALARM LINE
				+ CASE 
					 WHEN EXISTS(SELECT MALM.ALM_STARTTIME
								 FROM	GET_RPT_EDS_LINE_DEVICE() EDSL,MDS_ALARMS MALM WITH(NOLOCK)
								 WHERE  MALM.ALM_ALMAREA2 ='AA_FSAL'
									AND LOC.LOCATION IS NOT NULL
									AND EDSL.REJECT_LOCATION=LOC.LOCATION
									AND MALM.ALM_ALMEXTFLD2=
										SUBSTRING(LOC.LOCATION,1,CHARINDEX('C',LOC.LOCATION)-1)
									AND MALM.ALM_STARTTIME BETWEEN DATEADD(SECOND,-@SECONDRANGE,ITL.TIME_STAMP) AND DATEADD(SECOND,@SECONDRANGE,ITL.TIME_STAMP)
								)
						 THEN '[Fail Safe]'
					 ELSE ''
				 END 
				 AS BAG_EVENT 
		FROM	#BT_BAG_GIDLIST_TEMP BBG, ITEM_LOST ITL WITH(NOLOCK)
		LEFT JOIN LOCATIONS LOC ON ITL.LOCATION=LOC.LOCATION_ID
		WHERE	ITL.GID=BBG.GID
				AND ITL.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)

		SELECT * FROM #BT_BAG_TRACE_TEMP bbtt
		ORDER BY bbtt.TIME_STAMP;
END

--DECLARE @GID VARCHAR(10)='';--3211000413
--DECLARE @LICENSE_PLATE VARCHAR(10)='1131578207';--0612100122
--DECLARE @DTFROM DATETIME='2014/1/1 19:35:40';
--DECLARE @DTTO DATETIME='2014/1/2 19:35:40';
--DECLARE @LOGIC VARCHAR(10)='OR';
--EXEC stp_RPT27_BAGTRACE_GWYTEST @DTFROM,@DTTO,@GID,@LICENSE_PLATE,@LOGIC;