GO
USE [BHSDB];
GO

ALTER PROCEDURE dbo.stp_RPT0501_EquipMalfunction
		  @DTFrom datetime, 
		  @DTTo datetime,
		  @Subsystem varchar(max),
		  @EquipmentID varchar(max),
		  @FaultType varchar(max)
AS
BEGIN
	SELECT	ALM_ALMAREA1 AS ALM_SUBSYSTEM, 
			ALM_ALMEXTFLD2 AS ALM_EQUIPID, 
			ALM_STARTTIME AS ALM_TIMESET, 
			ALM_MSGDESC AS ALM_DESCRIPTION
	FROM	MDS_ALARMS WITH(NOLOCK)
	WHERE	ALM_UNCERTAIN = 0
			AND ALM_STARTTIME BETWEEN @DTFrom AND @DTTo 
			AND ALM_ALMAREA1 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@Subsystem)) 
			AND ALM_ALMEXTFLD2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@EquipmentID)) 
			AND ALM_ALMAREA2 IN (SELECT * FROM dbo.RPT_GETPARAMETERS(@FaultType))
	ORDER BY ALM_STARTTIME

END

--DECLARE @DTFrom datetime='2009-11-01';
--DECLARE @DTTo datetime='2009-12-31';
--DECLARE @Subsystem varchar(max)='AL1,CS1,CL3';
--DECLARE @EquipmentID varchar(max)='AL1-01,AL1-07,AL1-08,CS1-01,CS1-02,CS1-04,CL3-01,CL3-11,CL3-12';
--DECLARE @FaultType varchar(max)='AA_ENUS,AA_BJAM,AA_ESTP,AA_ENUS,AA_ISOF,AA_CNFT';
--EXEC stp_RPT0501_EquipMalfunction @DTFrom,@DTTo,@Subsystem,@EquipmentID,@FaultType
--EXEC stp_RPT0502_EquipCorrection @DTFrom,@DTTo,@Subsystem,@EquipmentID,@FaultType