GO
USE [BHSDB_CLT];
GO


ALTER PROCEDURE dbo.stp_RPT_CLT_EquipCorrection
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @Subsystem varchar(max),
		  @EquipmentID varchar(max),
		  @FaultType varchar(max),
		  @MessageType varchar(max),
		  @ReportType varchar(5)
AS
BEGIN

	SELECT	ALM_ALMAREA1 AS ALM_SUBSYSTEM, 
			ALM_ALMEXTFLD2 AS ALM_EQUIPID, 
			ALM_STARTTIME AS ALM_TIMESET,
			ALM_ENDTIME AS ALM_TIMECLEAR, 
			ALM_MSGDESC AS ALM_DESCRIPTION,
			CASE
				WHEN ALM_ENDTIME IS NOT NULL THEN DATEDIFF(SECOND,ALM_STARTTIME,ALM_ENDTIME)
				ELSE 0
			END  AS ALM_DURATION,
			LOC.INTERNAL_LOC AS HIDDEN_LOC
	INTO	#TMP_EC_REPORT_FAULTEVENT
	FROM	MDS_ALARMS, LOCATIONS LOC WITH(NOLOCK)
	WHERE	ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND ALM_ALMAREA1 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@Subsystem)) 
			AND ALM_ALMEXTFLD2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@EquipmentID)) 
			AND ALM_ALMAREA2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@FaultType))
			AND ALM_MSGDESC IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@MessageType))
			AND ALM_ALMAREA1=LOC.SUBSYSTEM AND ALM_ALMEXTFLD2=LOC.LOCATION
	--ORDER BY LOC.SUBSYSTEM,LOC.INTERNAL_LOC,ALM_STARTTIME

	IF @ReportType='FAULT' AND EXISTS(SELECT * FROM dbo.RPT_GETPARAMETERS(@MessageType) WHERE PAR='Bag Lost Track')
	BEGIN
		INSERT INTO #TMP_EC_REPORT_FAULTEVENT
		SELECT	LOC.SUBSYSTEM,LOC.LOCATION,ILT.TIME_STAMP,ILT.TIME_STAMP,'Bag Lost Track. GID:' + ILT.GID,0,LOC.INTERNAL_LOC
		FROM	ITEM_LOST ILT, LOCATIONS LOC WITH(NOLOCK)
		WHERE	ILT.LOCATION=LOC.LOCATION_ID
			AND ILT.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
			AND	LOC.SUBSYSTEM IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@Subsystem))
			AND LOC.LOCATION IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@EquipmentID)) 
	END
	ELSE IF @ReportType='EVENT' AND EXISTS(SELECT * FROM dbo.RPT_GETPARAMETERS(@MessageType) WHERE PAR='Stray Bag Found')
	BEGIN
		INSERT INTO #TMP_EC_REPORT_FAULTEVENT
		SELECT	LOC.SUBSYSTEM,LOC.LOCATION,GID.TIME_STAMP,GID.TIME_STAMP,'Stray Bag Found. GID:' + GID.GID,0,LOC.INTERNAL_LOC
		FROM	GID_USED GID, LOCATIONS LOC WITH(NOLOCK)
		WHERE	GID.LOCATION=LOC.LOCATION_ID
			AND GID.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
			AND GID.BAG_TYPE='02'--STRAY BAG
			AND	LOC.SUBSYSTEM IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@Subsystem))
			AND LOC.LOCATION IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@EquipmentID)) 
	END

	SELECT * FROM #TMP_EC_REPORT_FAULTEVENT
	ORDER BY ALM_SUBSYSTEM,HIDDEN_LOC,ALM_TIMESET
END

--DECLARE @DTFrom datetime='2014/1/11 18:56:26' 
--DECLARE @DTTo datetime='2014/1/12 19:26:32'
--DECLARE @Subsystem varchar(max)='RI1'
--DECLARE @EquipmentID varchar(max)='RI1-04SD'
--DECLARE @FaultType varchar(max)='AA_SDAL'
--EXEC stp_RPT0502_EquipCorrection @DTFrom,@DTTo,@Subsystem,@EquipmentID,@FaultType;