GO
USE [BHSDB_CLT]
GO

ALTER PROCEDURE dbo.stp_RPT_CLT_INDIVIDUAL_PLC
		  @PLCNAME VARCHAR(20)
AS
BEGIN

	CREATE TABLE #INDIV_PLC_STATUS
	(
		PLC_LOCATION VARCHAR(20) NOT NULL,
		PLC_NAME varchar(50) NULL,
		SW_TYPE varchar(50) NULL,
		SW_REV varchar(50) NULL,
		KEY_POS varchar(30) NULL,
		PLC_STATUS varchar(30) NULL,
		LED_CPU varchar(10) NULL,
		LED_FORCE varchar(10) NULL,
		LED_COMM varchar(10) NULL,
		LED_BATT varchar(10) NULL,
		MEM_SIZE int NULL,
		MEM_USED int NULL,
		MEM_CMPL int NULL,
		RUN_CNT int NULL,
		SCAN_TIME int NULL,
		CPU_ERR int NULL,
		NWK_ERR int NULL
	)

	--1. GET DATA OF THIS PLC
	SELECT	STATUS_ID, TYPE, TYPE_STATUS, LAST_UPDATE, STATUS, SUBSYSTEM, LOCATION, PLC_ZONE, DESCRIPTION
	INTO	#INDIV_PLC_DATA
	FROM	MDS_STATUS MSTA
	WHERE	MSTA.LOCATION=@PLCNAME AND MSTA.TYPE='PLC';

	--2. INSERT PLC NAME
	INSERT	INTO #INDIV_PLC_STATUS
	SELECT	PLC.LOCATION AS PLC_LOCATION,
			LTRIM(RTRIM(PLC.STATUS)) AS PLC_NAME,
			'' AS SW_TYPE,'' AS SW_REV,'' AS KEY_POS,'' AS PLC_STATUS,'' AS LED_CPU,'' AS LED_FORCE,'' AS LED_COMM,
			'' AS LED_BATT,0 AS MEM_SIZE,0 AS MEM_USED,0 AS MEM_CMPL,0 AS RUN_CNT,0 AS SCAN_TIME, 0 AS CPU_ERR, 0 AS NWK_ERR
	FROM	#INDIV_PLC_DATA PLC
	WHERE	PLC.STATUS_ID LIKE '%NAME';

	--3. UPDATE SW_TYPE
	UPDATE	#INDIV_PLC_STATUS
	SET		SW_TYPE=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%SWTYPE' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--4. UPDATE SW_REV
	UPDATE	#INDIV_PLC_STATUS
	SET		SW_REV=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%SWVERSION' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--5. UPDATE KEY_POS
	UPDATE	#INDIV_PLC_STATUS
	SET		KEY_POS=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%KEYPOS' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--6. UPDATE PLC_STATUS
	UPDATE	#INDIV_PLC_STATUS
	SET		PLC_STATUS=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%STATUS' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--7. UPDATE LED_CPU
	UPDATE	#INDIV_PLC_STATUS
	SET		LED_CPU=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%LED_PROCR' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--8. UPDATE LED_FORCE
	UPDATE	#INDIV_PLC_STATUS
	SET		LED_FORCE=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%LED_FORCE' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--9. UPDATE LED_COMM
	UPDATE	#INDIV_PLC_STATUS
	SET		LED_COMM=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%LED_COMMUNICATION' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--10. UPDATE LED_BATT
	UPDATE	#INDIV_PLC_STATUS
	SET		LED_BATT=LTRIM(RTRIM(PLC.STATUS))
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%LED_BATT' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--11. UPDATE MEM_SIZE
	UPDATE	#INDIV_PLC_STATUS
	SET		MEM_SIZE=CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%MEMSZ' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--12. UPDATE MEM_USED
	UPDATE	#INDIV_PLC_STATUS
	SET		MEM_USED=MEM_SIZE - CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%MEMFREE' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--13. UPDATE MEM_CMPL
	UPDATE	#INDIV_PLC_STATUS
	SET		MEM_CMPL=CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%MEMCOMP' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--14. UPDATE RUN_CNT
	UPDATE	#INDIV_PLC_STATUS
	SET		RUN_CNT=CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%RUNGCNT' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--15. UPDATE SCAN_TIME
	UPDATE	#INDIV_PLC_STATUS
	SET		SCAN_TIME=CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%SCANTIME%' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--16. UPDATE CPU_ERR
	UPDATE	#INDIV_PLC_STATUS
	SET		CPU_ERR=CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%FAULTCODE' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	--17. UPDATE NWK_ERR
	UPDATE	#INDIV_PLC_STATUS
	SET		NWK_ERR=CAST(PLC.STATUS AS INT)
	FROM	#INDIV_PLC_DATA PLC, #INDIV_PLC_STATUS PLCSTA
	WHERE	PLC.STATUS_ID LIKE '%NWKERR' AND PLC.LOCATION=PLCSTA.PLC_LOCATION;

	SELECT * FROM #INDIV_PLC_STATUS;
END


--DECLARE @PLCNAME VARCHAR(20)='PLC-EM2';
--EXEC dbo.stp_RPT_CLT_INDIVIDUAL_PLC @PLCNAME;