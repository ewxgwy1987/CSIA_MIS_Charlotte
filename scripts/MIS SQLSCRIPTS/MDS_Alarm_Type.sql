--select * from REPORT_FAULT WHERE FAULT_NAME IN ('AA_RDRV','AA_EXFL','AA_REFL','AA_PTPH')

GO 
USE [BHSDB_CLT]
GO

IF EXISTS (SELECT NAME FROM sys.sysobjects WHERE NAME LIKE 'MDS_ALARM_MESSAGE_TYPE')
BEGIN
	DROP TABLE MDS_ALARM_MESSAGE_TYPE;
END

IF NOT EXISTS (SELECT FAULT_NAME FROM REPORT_FAULT WHERE FAULT_NAME='AA_EXFL')
BEGIN
	INSERT INTO REPORT_FAULT VALUES('AA_EXFL','HSPD Fail Extended','ALARM',1,1,1,GETDATE(),NULL)
END

IF NOT EXISTS (SELECT FAULT_NAME FROM REPORT_FAULT WHERE FAULT_NAME='AA_REFL')
BEGIN
	INSERT INTO REPORT_FAULT VALUES('AA_REFL','HSPD Fail Home','ALARM',1,1,1,GETDATE(),NULL)
END

IF NOT EXISTS (SELECT FAULT_NAME FROM REPORT_FAULT WHERE FAULT_NAME='AA_PTPH')
BEGIN
	INSERT INTO REPORT_FAULT VALUES('AA_PTPH','Panel Temperature High','ALARM',1,1,1,GETDATE(),NULL)
END

create table MDS_ALARM_MESSAGE_TYPE
(
	[FAULT_NAME] [varchar](10) NOT NULL,
	[MESSAGE] [varchar](500) NOT NULL,
	[ALARM_TYPE_FAULT] BIT NOT NULL,
	[ALARM_TYPE_EVENT] BIT NOT NULL,
	CONSTRAINT [MDS_ALARM_MESSAGE_TYPE_PK] PRIMARY KEY CLUSTERED([FAULT_NAME],[MESSAGE]),
	CONSTRAINT [MDS_ALARM_MESSAGE_TYPE_FK] FOREIGN KEY ([FAULT_NAME]) REFERENCES REPORT_FAULT([FAULT_NAME])
)

INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ESTP','E-STOP',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_CNFT','MOTOR CONTACTOR FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BJAM','PHOTO-EYE A FAULT/BAG JAM',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ISOF','MOTOR DISCONNECT OFF',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_MSBJ','MISSING BAG JAM',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_MTTR','MOTOR OVERLOAD',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BJAM','PHOTO-EYE B FAULT/BAG JAM',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_IVFT','VFD FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ENUS','ENCODER UNDER SPEED',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ENFT','ENCODER SENSOR FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ENOS','ENCODER OVER SPEED',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_FIRE','FIRE ALARM',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_FSAL','FAIL SAFE',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_SDAL','SECURITY ALARM',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_PTPH','MCP / RCP TEMPERATURE HIGH',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','PLC A IN PROGRAM MODE',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','PLC B IN PROGRAM MODE',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','LOSS OF REDUNDANCY LINK',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','COMM. FAILURE WITH SAC/BTS',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','PLC A IN ERROR/FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','PLC B IN ERROR/FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','LOSS OF REDUNDANCY',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NIPS','NOT IN POSITION (PROXIMITY SENSOR FAILED)',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_EXFL','FAILED TO EXTEND ',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_REFL','FAILED TO RETRACT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_EXFL','FAILED TO RAISE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_REFL','FAILED TO LOWER',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_GNAL','SAFETY DOOR OPEN',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_XMAL','EDS MACHINE COMM. FAILURE WITH PLC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_XMAL','MACHINE FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_IVFT','MOTOR SOFT STARTER FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_EXFL','FAILED TO OPEN ',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_REFL','FAILED TO CLOSE ',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_XMAL','POWER FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','LOW READ RATE',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','COMM. FAILURE WITH PLC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','NO SCANNER IN NETWORK DETECTED',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','MISSING SCANNER IN PRI. NETWORK',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','MISSING SCANNER IN SEC. NETWORK',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','ATR SYSTEM FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','DC 24V POWER SUPPLY FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','LIGHT BEAM SWITCH HARDWARE FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','BAD CHECK SUM IN INDEX TELEGRAM',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','NO CHECK SUM IN INDEX TELEGRAM',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','FRAME ERROR IN INDEX TELEGRAM',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 01 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 02 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 03 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 04 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 05 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 06 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 07 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 08 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 09 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 10 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','OTC NOT READY',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BJAM','PHOTO-EYE C FAULT/BAG JAM (DIVERT)',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','SERVER DISCONNECTED',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','WORKSTATION DISCONNECTED',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BHS','PLC CONNECTION A COMM. FAILURE (UNREACHABLE)',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BHS','PLC CONNECTION B COMM. FAILURE (UNREACHABLE)',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BOVH','PHOTO-EYE FAULT/BAG JAM (OVER HEIGHT)',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BOVL','PHOTO-EYE FAULT/BAG JAM (OVER LENGHT)',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BJAM','SAFETY SENSOR FAULT/BAG JAM',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_XMAL','CONVEYOR MOTOR FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_XMAL','GANTRY MOTOR FAULT',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BJAM','ENTRY BAG JAM',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BJAM','EXIT BAG JAM',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_RDRV','READY TO RECEIVE',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_NDAL','CONTROL NET FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','ATR ERROR',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 11 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SCANNER 12 NETWORK FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','NO INDEX',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','NO PRI. OTC DETECTED',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','NO SEC. OTC DETECTED',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','ENCODER A FAILURE AT PRIMARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','ENCODER B FAILURE AT PRIMARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','ENCODER A FAILURE AT SECONDARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','ENCODER B FAILURE AT SECONDARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','TRIGGER A FAILURE AT PRIMARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','TRIGGER B FAILURE AT PRIMARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','TRIGGER A FAILURE AT SECONDARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','TRIGGER B FAILURE AT SECONDARY. OTC',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','PRI. OTC FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SEC. OTC FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','PRI. POWER SUPPLY FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ARAL','SEC. POWER SUPPLY FAILURE',1,0)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_ESTP','E-STOP RESET REQUIRED',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_FSAL','FAIL SAFE RESET REQUIRED',0,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_FSAL','SAFETY FAULT ON CONVEYOR A',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_FSAL','SAFETY FAULT ON CONVEYOR B',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_FSAL','SAFETY FAULT ON CONVEYOR C',1,1)
INSERT INTO MDS_ALARM_MESSAGE_TYPE VALUES('AA_BHS','OUT OF SERVICE',1,0)

UPDATE REPORT_FAULT
SET MDS_USED = 1
WHERE FAULT_NAME IN (SELECT DISTINCT FAULT_NAME FROM MDS_ALARM_MESSAGE_TYPE)

SELECT * FROM MDS_ALARM_MESSAGE_TYPE