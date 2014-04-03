GO
USE [BHSDB];
GO

insert into PICTURES
select 'Charlotte-ReportLogo','Charlotte Douglas International Airport','Logo Used On all reports for Oklahoma',
BulkColumn FROM OPENROWSET(Bulk 'D:\PALS\MIS\MIS SQLSCRIPTS\logo.jpg', SINGLE_BLOB) AS BLOB;

--update PICTURES set PIC_TITLE='Charlotte Douglas International Airpot' where pic_name='Charlotte-ReportLogo'
--select * from PICTURES;

--SET USA date and time format

--Tuesday, December 17, 2013 6:00 AM
update SYS_CONFIG set SYS_VALUE='MM/dd/yyyy' where SYS_KEY='DEFAULT_DATE_FORMAT';
update SYS_CONFIG set SYS_VALUE='hh:mm:ss tt' where SYS_KEY='DEFAULT_TIME_FORMAT';

--SELECT * FROM SYS_CONFIG;
--select * from MIS_DATE_BASIC;

GO
USE [BHSDB];
GO

/****** Object:  Table [dbo].[MIS_DATE_BASIC]    Script Date: 19-Dec-13 5:59:06 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[MIS_DATE_BASIC](
	[DATE_BASIC_VALUE] [varchar](20) NOT NULL,
	[DATE_BASIC_LABEL] [varchar](20) NULL,
	[IS_DEFAULT] [bit] NULL,
 CONSTRAINT [PK_MIS_DATE_BASIC] PRIMARY KEY CLUSTERED 
(
	[DATE_BASIC_VALUE] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
INSERT [dbo].[MIS_DATE_BASIC] ([DATE_BASIC_VALUE], [DATE_BASIC_LABEL], [IS_DEFAULT]) VALUES (N'15MINUTES', N'15 MINUTES', 0)
GO
INSERT [dbo].[MIS_DATE_BASIC] ([DATE_BASIC_VALUE], [DATE_BASIC_LABEL], [IS_DEFAULT]) VALUES (N'1DAY', N'1 DAY', 1)
GO
INSERT [dbo].[MIS_DATE_BASIC] ([DATE_BASIC_VALUE], [DATE_BASIC_LABEL], [IS_DEFAULT]) VALUES (N'1HOUR', N'1 HOUR', 0)
GO
INSERT [dbo].[MIS_DATE_BASIC] ([DATE_BASIC_VALUE], [DATE_BASIC_LABEL], [IS_DEFAULT]) VALUES (N'1MONTH', N'1 MONTH', 0)
GO
INSERT [dbo].[MIS_DATE_BASIC] ([DATE_BASIC_VALUE], [DATE_BASIC_LABEL], [IS_DEFAULT]) VALUES (N'1WEEK', N'1 WEEK', 0)
GO
INSERT [dbo].[MIS_DATE_BASIC] ([DATE_BASIC_VALUE], [DATE_BASIC_LABEL], [IS_DEFAULT]) VALUES (N'1YEAR', N'1 YEAR', 0)
GO


--@AIRLINE
SELECT DISTINCT(AIRLINE)
FROM FLIGHT_PLAN_SORTING 
WHERE (SDO BETWEEN CONVERT(VARCHAR(10), @DTFrom,111) 
AND  CONVERT(VARCHAR(10), @DTTo,111)) 
--AND AIRLINE IN (SELECT * FROM DBO.RPT_GETAIRLINE(@UserID))

--@FLIGHT_NUMBER
SELECT DISTINCT(FLIGHT_NUMBER) AS 'FLIGHTNUMBER' 
FROM FLIGHT_PLAN_SORTING 
WHERE AIRLINE IN (@Airline) 
AND (SDO BETWEEN CONVERT(VARCHAR(10), @DTFrom,111) 
AND  CONVERT(VARCHAR(10), @DTTo,111))

GO
USE [BHSDB];
GO
drop table EDS_SN2LOCATION_MAP;
CREATE TABLE MIS_EDS_SN2LOCATION_MAP
(
	LOCATION varchar(20),
	EDS_SN varchar(50)
);

INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED1-13','EDS01-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED2-12','EDS02-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED3-11','EDS03-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED4-11','EDS04-S########');

INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED7-11','EDS07-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED8-11','EDS04-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED9-11','EDS09-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED10-11','EDS10-S########');
INSERT INTO MIS_EDS_SN2LOCATION_MAP VALUES('ED11-11','EDS11-S########');

GO
USE [BHSDB];
GO
drop table CBRA_ETD#2LOCATION_MAP;
CREATE TABLE MIS_CBRA_ETD#2LOCATION_MAP
(
	LOCATION VARCHAR(20),
	ETD_STATION_NUM varchar(50)
);

INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-6','WCBRA01-ETD01');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-7','WCBRA01-ETD02');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-9','WCBRA01-ETD03');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-10','WCBRA01-ETD04');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-12','WCBRA01-ETD05');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-13','WCBRA01-ETD06');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB1-15','WCBRA01-ETD07');

INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-5','ECBRA03-ETD01');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-6','ECBRA03-ETD02');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-8','ECBRA03-ETD03');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-9','ECBRA03-ETD04');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-11','ECBRA03-ETD05');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-12','ECBRA03-ETD06');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-14','ECBRA03-ETD07');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-15','ECBRA03-ETD08');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-17','ECBRA03-ETD09');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB3-18','ECBRA03-ETD10');

INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-5','ECBRA04-ETD01');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-6','ECBRA04-ETD02');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-8','ECBRA04-ETD03');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-9','ECBRA04-ETD04');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-11','ECBRA04-ETD05');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-12','ECBRA04-ETD06');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-14','ECBRA04-ETD07');
INSERT INTO MIS_CBRA_ETD#2LOCATION_MAP VALUES('SB4-15','ECBRA04-ETD08');

GO
USE [BHSDB];
GO
drop table IFS_INDIVIDUAL_FLIGHT_DETAIL
CREATE TABLE MIS_IFS_INDIVIDUAL_FLIGHT_DETAIL
(
	LICENSE_PLATE VARCHAR(10),
	PAX_NAME VARCHAR(200),
	BSM_TIME_STAMP DATETIME,
	TAG_READ_TIME DATETIME,
	SORTED_TIMESTAMP DATETIME
)

GO

/****** Object:  UserDefinedFunction [dbo].[GET_RPT_POST_XM]    Script Date: 10/07/2009 11:38:12 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

GO
USE [BHSDB];
GO

DROP FUNCTION [dbo].[GET_RPT_POST_XM];

CREATE FUNCTION [dbo].[GET_RPT_EDS_LINE_DEVICE]--[GET_RPT_POST_XM]
(
)
RETURNS 
@POST_XM_TABLE  TABLE 
(
	-- Add the column definitions for the TABLE variable here
	XRAY_ID  VARCHAR(15),			--EDS ID
	DIVERT_LOCATION VARCHAR(15),	--ITEM_PROCEED LOCATION
	REJECT_LOCATION VARCHAR (15),	--ITEM_PROCEED ALARM
	CLEAR_LOCATION VARCHAR (15),	--ITEM_PROCEED CLEAR
	PRE_XM_LOCATION VARCHAR (15),	--ITEM_TRACKING BEFORE EDS
	EDS_LOCATION VARCHAR(15),
	POST_XM_LOCATION VARCHAR (15),	--ITEM_TRACKING AFTER EDS
	SUBSYSTEM VARCHAR(20)			--EDS LINE SUBSYSTEM NAME
)
AS
BEGIN

	--Need update
	INSERT INTO @POST_XM_TABLE VALUES('EDS01', 'ED1-19A', 'ED1-19C', 'ED1-19B','ED1-12','ED1-13', 'ED1-14','ED1');
	INSERT INTO @POST_XM_TABLE VALUES('EDS02', 'ED2-18A', 'ED2-18C', 'ED2-18B','ED2-11','ED2-12', 'ED2-13','ED2');
	INSERT INTO @POST_XM_TABLE VALUES('EDS03', 'ED3-17A', 'ED3-17C', 'ED3-17B','ED3-10','ED3-11', 'ED3-12','ED3');
	INSERT INTO @POST_XM_TABLE VALUES('EDS04', 'ED4-17A', 'ED4-17C', 'ED4-17B','ED4-10','ED4-11', 'ED4-12','ED4');
	INSERT INTO @POST_XM_TABLE VALUES('EDS07', 'ED7-18A', 'ED7-18C', 'ED7-18B','ED7-10','ED7-11', 'ED7-12','ED7');
	INSERT INTO @POST_XM_TABLE VALUES('EDS08', 'ED8-17A', 'ED8-17C', 'ED8-17B','ED8-10','ED8-11', 'ED8-12','ED8');
	INSERT INTO @POST_XM_TABLE VALUES('EDS09', 'ED9-18A', 'ED9-18C', 'ED9-18B','ED9-10','ED9-11', 'ED9-12','ED9');
	INSERT INTO @POST_XM_TABLE VALUES('EDS10', 'ED10-17A', 'ED10-17C', 'ED10-17B','ED10-10','ED10-11', 'ED10-12','ED10');
	INSERT INTO @POST_XM_TABLE VALUES('EDS11', 'ED11-17A', 'ED11-17C', 'ED11-17B','ED11-10','ED11-11', 'ED11-12','ED11');
	RETURN 
END

GO

GO
USE [BHSDB];
GO
drop table MIS_SS_LINE_DEVICE;
--Create a table used to map between BMA location and GID location on the same lines
CREATE TABLE MIS_SS_LINE_DEVICE --GID_BMA_MAP 
(
	SUBSYSTEM VARCHAR(20),		--SUBSYSTEM 
	GID_LOCATION VARCHAR(20),	--First GID generated location
	ATR_LOCATION  VARCHAR(20),	--ATR LOCATION
	BMA_LOCATION VARCHAR(20)	--BMA LOCATION
);

insert into MIS_SS_LINE_DEVICE values('SS1','SS1-1','SS1-2','SS1-2');
insert into MIS_SS_LINE_DEVICE values('SS2','SS2-1','SS2-2','SS2-2');
insert into MIS_SS_LINE_DEVICE values('SS3','SS3-1','SS3-2','SS3-2');
insert into MIS_SS_LINE_DEVICE values('SS4','SS4-1','SS4-2','SS4-2');


GO
USE [BHSDB];
GO
drop table MIS_MAINLINE_DEVICE;
--Create a table used to map between BMA location and GID location on the same lines
CREATE TABLE MIS_MAINLINE_DEVICE --GID_BMA_MAP 
(
	SUBSYSTEM VARCHAR(20),		--SUBSYSTEM 
	GID_LOCATION VARCHAR(20),	--MAINLINE GID LOCATION
	ATR_LOCATION  VARCHAR(20),	--MAINLINE ATR LOCATION
	IPR_TOMES_SUBSYSTEM VARCHAR(20)
);

insert into MIS_MAINLINE_DEVICE values('ML01','ML1-1','ML1-2','ME1');
insert into MIS_MAINLINE_DEVICE values('ML02','ML2-1','ML2-2','ME2');
insert into MIS_MAINLINE_DEVICE values('ML03','ML3-1','ML3-2','ME3');
insert into MIS_MAINLINE_DEVICE values('ML04','ML4-1','ML4-2','ME3');

GO
USE [BHSDB];
GO
drop table MIS_CBRA_CLEARLINE_DEVICE;
--Create a table used to map between BMA location and GID location on the same lines
CREATE TABLE MIS_CBRA_CLEARLINE_DEVICE --GID_BMA_MAP 
(
	CBRA_ID VARCHAR(20),		--THE SUBSYSTEM NAME FOR EACH CBRA AREA
	CLEARLINE_ID VARCHAR(20),	--THE SUBSYSTEM NAME FOR CLEAR LINE OF EACH CBRA AREA
);

insert into MIS_CBRA_CLEARLINE_DEVICE values('SB1','CB1B');
insert into MIS_CBRA_CLEARLINE_DEVICE values('SB3','CB6B');
insert into MIS_CBRA_CLEARLINE_DEVICE values('SB4','CB9B');


GO
USE [BHSDB];
GO
drop table MIS_SubsystemCatalog;
CREATE TABLE MIS_SubsystemCatalog
(
	SUBSYSTEM_TYPE VARCHAR(30),
	SUBSYSTEM VARCHAR(20),
	DETECT_LOCATION VARCHAR(20),
	MDS_DATA INT,
	CONSTRAINT [PK_SC] PRIMARY KEY (SUBSYSTEM_TYPE,DETECT_LOCATION)
)
--INSERT INTO MIS_SubsystemCatalog VALUES('','','','');
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED1','ED1-14',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED2','ED2-13',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED3','ED3-12',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED4','ED4-12',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED7','ED7-12',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED8','ED8-12',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED9','ED9-12',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED10','ED10-12',0);
INSERT INTO MIS_SubsystemCatalog VALUES('EDS','ED11','ED11-12',0);

INSERT INTO MIS_SubsystemCatalog VALUES('MAINLINE','ML01','ML1-5',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAINLINE','ML02','ML2-5',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAINLINE','ML03','ML3-5',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAINLINE','ML04','ML4-6',0);

INSERT INTO MIS_SubsystemCatalog VALUES('MAKE-UP','MU1','MU1',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAKE-UP','MU2','MU2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAKE-UP','MU3','MU3',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAKE-UP','MU4','MU4',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAKE-UP','MU5','MU5',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MAKE-UP','MU6','MU6',0);

INSERT INTO MIS_SubsystemCatalog VALUES('MES','ME1','ME1-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MES','ME2','ME2-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('MES','ME3','ME3-2',0);

INSERT INTO MIS_SubsystemCatalog VALUES('ATR','SS1','SS1-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','SS2','SS2-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','SS3','SS3-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','SS4','SS4-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML01','ML1-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML02','ML2-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML03','ML3-2',0);
INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);

--INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);
--INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);
--INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);
--INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);
--INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);
--INSERT INTO MIS_SubsystemCatalog VALUES('ATR','ML04','ML4-2',0);
--1TC	1TC-06
--3TC	3TC-06
--5TC	5TC-06
--TC1	TC1-08
--TC2	TC2-04
--TC3	TC3-06
--TC4	TC4-09
GO
USE [BHSDB];
GO
DROP TABLE MIS_DEVICE_PLC_MAP;
CREATE TABLE MIS_DEVICE_PLC_MAP
(
	EQUIP_SUBSYSTEM VARCHAR(20),
	PLC_ID VARCHAR(20),
	PLC_OTHERNAME VARCHAR(20)
)

INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED1','PLCA61','PLCWM1');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED2','PLCA61','PLCWM1');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED3','PLCB61','PLCWM2');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED4','PLCB61','PLCWM2');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED7','PLCA11','PLCEM1');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED8','PLCB11','PLCEM2');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED9','PLCA11','PLCEM1');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED10','PLCB11','PLCEM2');
INSERT INTO MIS_DEVICE_PLC_MAP VALUES('ED11','PLCB11','PLCEM2');

GO
USE [BHSDB];
GO

DROP TABLE MIS_EQUIP_STATUS_CLASS
CREATE TABLE MIS_EQUIP_STATUS_CLASS
(
	STATUS_CLASS VARCHAR(20),
	TAGNAME NVARCHAR(255),
	DESCRIPTION VARCHAR(200),
	DATATYPE VARCHAR(20),
	CONSTRAINT [PK_ESC_STATUSCLASS] PRIMARY KEY (STATUS_CLASS),
	CONSTRAINT [FK_ESC_TAGNAME] FOREIGN KEY (TAGNAME) REFERENCES MDS_TAG_IDX(TAGNAME),
)

DROP TABLE MIS_EQUIP_STATUS_VALUEMAP
CREATE TABLE MIS_EQUIP_STATUS_VALUEMAP
(
	STATUS_CLASS VARCHAR(20),
	STATUS_VALUE FLOAT,
	STATUS_NAME VARCHAR(30),
	CONSTRAINT [PK_ESV_STATUSCLASS] PRIMARY KEY (STATUS_CLASS,STATUS_VALUE)
);

drop table MIS_EQUIP_LIVE_MONITOR;
CREATE TABLE MIS_EQUIP_LIVE_MONITOR
(
	SUBSYSTEM VARCHAR(20),
	EQUIP_ID VARCHAR(20),
	STATUS_CLASS VARCHAR(20),
	UPDATE_TIME_STAMP DATETIME,
	CURRENT_STATUS VARCHAR(30),
	CONSTRAINT [PK_ELM_STATUS] PRIMARY KEY (EQUIP_ID,STATUS_CLASS),
	--CONSTRAINT [FK_ELM_STATUS_CLASS] FOREIGN KEY (STATUS_CLASS) REFERENCES MIS_EQUIP_STATUS_CLASS(STATUS_CLASS),
	--CONSTRAINT [FK_ELM_CRRSTATUS] FOREIGN KEY (CURRENT_STATUS) REFERENCES MIS_EQUIP_STATUS_VALUEMAP(STATUS_NAME)
);

USE [BHSDB]
GO

/****** Object:  Table [dbo].[MIS_STATUS_EDS]    Script Date: 2014/1/5 14:44:40 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[MIS_STATUS_EDS](
	[EDS_NAME] [varchar](50) NULL,
	[SW_TYPE] [varchar](50) NULL,
	[SW_REV] [varchar](50) NULL,
	[KEY_POS] [varchar](50) NULL,
	[EDS_STATUS] [varchar](20) NULL,
	[PLC_SCAN_TIME] [int] NULL,
	[ESTOP] [int] NULL,
	[FAULTS] [int] NULL,
	[RTR_HIGH] [int] NULL,
	[RTR_LOW] [int] NULL,
	[JAMS] [int] NULL,
	[BAGS_SCR] [int] NULL,
	[BAGS_CLR] [int] NULL,
	[BAGS_ALM] [int] NULL,
	[BAGS_EDS_UNKNOWN] [int] NULL,
	[BAGS_SEEN] [int] NULL,
	[BAGS_BHS_UNKNOWN] [int] NULL,
	[BAGS_BHS_UNKNOWN_PER] [float] NULL,
	[TIMEOUTS] [int] NULL,
	[AVG_L2_DECISION_TIME] [float] NULL,
	[AVG_BAG_PROC_TIME] [float] NULL,
	[COMM_IF_STATUS] [int] NULL,
	[COMM_PLC_NAME] [varchar](30) NULL
) ON [PRIMARY]

CREATE TABLE [dbo].[MIS_STATUS_PLC](
	[PLC_NAME] [varchar](50) NULL,
	[SW_TYPE] [varchar](50) NULL,
	[SW_REV] [varchar](50) NULL,
	[KEY_POS] [varchar](30) NULL,
	[PLC_STATUS] [varchar](30) NULL,
	[LED_CPU] [varchar](3) NULL,
	[LED_FORCE] [varchar](3) NULL,
	[LED_COMM] [varchar](3) NULL,
	[LED_BATT] [varchar](3) NULL,
	[MEM_SIZE] [int] NULL,
	[MEM_USED] [int] NULL,
	[MEM_CMPL] [int] NULL,
	[RUN_CNT] [int] NULL,
	[SCAN_TIME] [int] NULL,
	[CPU_ERR] [int] NULL,
	[NWK_ERR] [int] NULL
) ON [PRIMARY]

GO

SET ANSI_PADDING OFF
GO

SELECT DISTINCT ALM_ALMAREA1 AS SUBSYSTEM,ALM_ALMEXTFLD2 AS LOCATION
INTO MDS_LOCATIONS_GWY
FROM MDS_ALARMS

SELECT DISTINCT SUBSYSTEM 
FROM(
	SELECT SUBSYSTEM 
	FROM  SUBSYSTEMS
	UNION
	SELECT SUBSYSTEM
	FROM MDS_LOCATIONS_GWY
	) AS ALL_LOCATIONS


SELECT DISTINCT LOCATION
FROM(
	SELECT   DBO.RPT_FORMAT_LOCATION(LOCATION) AS LOCATION
	FROM    LOCATIONS
	WHERE   (SUBSYSTEM IN (@Subsystem))
	UNION ALL
	SELECT LOCATION
	FROM MDS_LOCATIONS_GWY
	WHERE (SUBSYSTEM IN (@Subsystem))
	) AS ALL_LOCATIONS
ORDER BY LOCATION

SELECT DISTINCT SUBSYSTEM
FROM (
		SELECT SUBSYSTEM FROM SUBSYSTEMS
		UNION ALL
		SELECT SUBSYSTEM FROM MDS_BAG_COUNTERS
	  ) AS ALL_SUBSYSTEM