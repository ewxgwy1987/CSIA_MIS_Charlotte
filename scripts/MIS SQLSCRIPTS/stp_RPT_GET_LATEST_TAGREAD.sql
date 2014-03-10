USE [BHSDB]
GO
/****** Object:  UserDefinedFunction [dbo].[GET_LATEST_TAGREAD]  */
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TYPE TAGREAD_TABLETYPE AS TABLE
( 
	GID VARCHAR(10),
	LICENSE_PLATE1 VARCHAR(10), 
	LICENSE_PLATE2 VARCHAR(10), 
	LOCATION VARCHAR(20), 
	TIME_STAMP DATETIME
);
GO

CREATE PROCEDURE dbo.stp_RPT_GET_LATEST_TAGREAD
	@TAGREAD_TABLE AS TAGREAD_TABLETYPE readonly
AS
BEGIN
	
	--In Charlotte project, there are 2 ATRs and MES a bag may goes through. 
	--So stored procedure must find the lastest location where item_scanned telegram is sent ordered by time_stamp
	SELECT 
		CASE
			WHEN TGR.LICENSE_PLATE1 LIKE '0%' AND TGR.LICENSE_PLATE1<>'0000000000' AND TGR.LICENSE_PLATE1<>'999999999'
				THEN TGR.LICENSE_PLATE1
			WHEN TGR.LICENSE_PLATE2 LIKE '0%' AND TGR.LICENSE_PLATE2<>'0000000000' AND TGR.LICENSE_PLATE2<>'999999999'
				THEN TGR.LICENSE_PLATE2
			ELSE
				TGR.LICENSE_PLATE1
		END AS LICENSE_PLATE,MAX(TIME_STAMP) AS TIME_STAMP
	INTO #BT_TAGREAD_LATESTTIME
	FROM @TAGREAD_TABLE TGR
	GROUP BY 
		CASE
			WHEN TGR.LICENSE_PLATE1 LIKE '0%' AND TGR.LICENSE_PLATE1<>'0000000000' AND TGR.LICENSE_PLATE1<>'999999999'
				THEN TGR.LICENSE_PLATE1
			WHEN TGR.LICENSE_PLATE2 LIKE '0%' AND TGR.LICENSE_PLATE2<>'0000000000' AND TGR.LICENSE_PLATE2<>'999999999'
				THEN TGR.LICENSE_PLATE2
			ELSE
				TGR.LICENSE_PLATE1
		END

	SELECT DISTINCT GID, LICENSE_PLATE1, LICENSE_PLATE2, LOCATION, TRLT.TIME_STAMP AS TIME_STAMP 
	FROM @TAGREAD_TABLE TGR,#BT_TAGREAD_LATESTTIME TRLT
	WHERE (TGR.LICENSE_PLATE1=TRLT.LICENSE_PLATE OR TGR.LICENSE_PLATE2=TRLT.LICENSE_PLATE)
		AND TGR.TIME_STAMP=TRLT.TIME_STAMP
END