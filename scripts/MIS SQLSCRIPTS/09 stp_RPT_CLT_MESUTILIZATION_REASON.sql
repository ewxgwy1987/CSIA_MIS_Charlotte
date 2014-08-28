GO
USE [BHSDB_CLT];
GO


ALTER PROCEDURE dbo.stp_RPT_CLT_MESUTILIZATION_REASON
		  @DTFROM datetime, 
		  @DTTO datetime
AS
BEGIN
	DECLARE @MINUTERANGE INT=10;

	--0	Sorted by Unknown --USE
	--1	Sorted by Flight Allocation
	--2	Sorted by Fallback Sortation
	--3	Sorted by Early Bag Functional Allocation
	--4	Sorted by Rush Bag Functional Allocation
	--5	Sorted by Too Late Bag Functional Allocation
	--6	Sorted by No Read Bag Functional Allocation --USE
	--7	Sorted by Standby Passenger Bag Functional Allocation
	--8	Sorted by First Class Bag Functional Allocation
	--9	Sorted by Business Class Bag Functional Allocation
	--10	Sorted by Multiple Tag Bag Functional Allocation --USE
	--11	Sorted by Unknown Flight Bag Functional Allocation --USE
	--12	Sorted by Unknown License Plate Bag Functional Allocation --USE
	--13	Sorted by No Allocation Bag Functional Allocation --USE
	--14	Sorted by Problem Bag Functional Allocation --USE
	--15	Sorted by Dump Discharge Functional Allocation 
	--16	Sorted by Carrier Allocation
	--17	Sorted by 4 Digits Tag Allocation
	--18	Sorted by Too Early Bag Functional Allocation
	--19	Sorted by Multiple BSM Functional Allocation --USE
	--20	Sorted by Invalid Fallback Tag

	--Create temp table for final result
	CREATE TABLE #MUR_MESUTILIZATION_REASON_TEMP
	(
		ME_STATION VARCHAR(10),
		CNT_UNKNOWN INT,
		CNT_NOREAD INT,
		CNT_MULTI_TAG INT,
		CNT_UNKNOWN_FLIGHT INT,
		CNT_UNKNOWN_LICENSE_PLATE INT,
		CNT_NOALLOCATION INT,
		CNT_PROBLEM_BAG INT,
		CNT_MULTI_BSM INT,
		CNT_OTHER INT
	);

	--Create temp table for all the required MES data from ITEM_ENCODING_REQUEST 
	--And mark the encoding type
	CREATE TABLE #MUR_MESMARKLIST_REASON_TEMP
	(
		GID VARCHAR(10),
		TIME_STAMP DATETIME,
		MES_SUBSYSTEM VARCHAR(10),
		REASON VARCHAR(2),
		MARK_UNKNOWN INT,--0
		MARK_NOREAD INT,--6
		MARK_MULTI_TAG INT,--10
		MARK_UNKNOWN_FLIGHT INT,--11
		MARK_UNKNOWN_LICENSE_PLATE INT,--12
		MARK_NOALLOCATION INT,--13
		MARK_PROBLEM_BAG INT,--14
		MARK_MULTI_BSM INT,--19
		MARK_OTHER INT	--OTHER
	);

	INSERT INTO #MUR_MESMARKLIST_REASON_TEMP
	SELECT	IPR.GID,IRD.TIME_STAMP,
			CASE LOC.SUBSYSTEM
				WHEN 'ML1' THEN 'ME1'
				WHEN 'ML2' THEN 'ME2'
				WHEN 'ML3' THEN 'ME3'
				WHEN 'ML4' THEN 'ME3'
			END,
			IRD.REASON,
			0 AS MARK_UNKNOWN, 0 AS MARK_NOREAD, 0 AS MARK_MULTI_TAG,
			0 AS MARK_UNKNOWN_FLIGHT, 0 AS MARK_UNKNOWN_LICENSE_PLATE, 0 AS MARK_NOALLOCATION,
			0 AS MARK_PROBLEM_BAG, 0 AS MARK_MULTI_BSM, 0 AS MARK_OTHER
	FROM	LOCATIONS PRDLOC, LOCATIONS LOC,ITEM_PROCEEDED IPR
	LEFT JOIN ITEM_REDIRECT IRD 
			ON IPR.GID=IRD.GID 
			AND IRD.TIME_STAMP BETWEEN DATEADD(MINUTE,-@MINUTERANGE,@DTFROM) AND DATEADD(MINUTE,@MINUTERANGE,@DTTO)
	WHERE	IPR.TIME_STAMP BETWEEN @DTFROM AND @DTTO
			AND IPR.LOCATION=LOC.LOCATION_ID
			--AND EXISTS(SELECT IPR_TOMES_SUBSYSTEM FROM MIS_MAINLINE_DEVICE MMD WHERE MMD.IPR_TOMES_SUBSYSTEM =PRDLOC.SUBSYSTEM)
			AND IPR.PROCEED_LOCATION=PRDLOC.LOCATION_ID
			AND PRDLOC.SUBSYSTEM LIKE 'ME%';

	UPDATE MMR
	SET 
		MARK_UNKNOWN				= CASE MMR.REASON WHEN '0' THEN 1 ELSE 0 END, 
		MARK_NOREAD					= CASE MMR.REASON WHEN '6' THEN 1 ELSE 0 END, 
		MARK_MULTI_TAG				= CASE MMR.REASON WHEN '10' THEN 1 ELSE 0 END, 
		MARK_UNKNOWN_FLIGHT			= CASE MMR.REASON WHEN '11' THEN 1 ELSE 0 END, 
		MARK_UNKNOWN_LICENSE_PLATE	= CASE MMR.REASON WHEN '12' THEN 1 ELSE 0 END, 
		MARK_NOALLOCATION			= CASE MMR.REASON WHEN '13' THEN 1 ELSE 0 END,
		MARK_PROBLEM_BAG			= CASE MMR.REASON WHEN '14' THEN 1 ELSE 0 END,
		MARK_MULTI_BSM				= CASE MMR.REASON WHEN '19' THEN 1 ELSE 0 END,
		MARK_OTHER					= CASE WHEN MMR.REASON NOT IN ('0','6','10','11','12','13','14','19','20') OR MMR.REASON IS NULL THEN 1 ELSE 0 END
	FROM #MUR_MESMARKLIST_REASON_TEMP MMR

	--SELECT * FROM #MUR_MESMARKLIST_REASON_TEMP;

	INSERT INTO #MUR_MESUTILIZATION_REASON_TEMP
	SELECT MMR.MES_SUBSYSTEM AS ME_STATION,
		   SUM(MARK_UNKNOWN) AS CNT_UNKNOWN,
		   SUM(MARK_NOREAD) AS CNT_NOREAD,
		   SUM(MARK_MULTI_TAG) AS CNT_MULTI_TAG,
		   SUM(MARK_UNKNOWN_FLIGHT) AS CNT_UNKNOWN_FLIGHT,
		   SUM(MARK_UNKNOWN_LICENSE_PLATE) AS CNT_UNKNOWN_LICENSE_PLATE,
		   SUM(MARK_NOALLOCATION) AS CNT_NOALLOCATION,
		   SUM(MARK_PROBLEM_BAG) AS CNT_PROBLEM_BAG,
		   SUM(MARK_MULTI_BSM) AS CNT_MULTI_BSM,
		   SUM(MARK_OTHER) AS CNT_OTHER
	FROM #MUR_MESMARKLIST_REASON_TEMP MMR
	GROUP BY MMR.MES_SUBSYSTEM;

	SELECT * FROM #MUR_MESUTILIZATION_REASON_TEMP;
END

--declare @DTFROM datetime='2014-01-02';
--declare @DTTO datetime='2014-01-03';
--exec stp_RPT09_MESUTILIZATION_REASON @DTFROM,@DTTO;