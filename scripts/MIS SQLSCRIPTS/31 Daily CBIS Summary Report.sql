--31 Daily CBIS Summary Report

--Total Throughput
SELECT	SUM(MBC.DIFFERENT) AS TotalThroughput
FROM	MDS_COUNT MBC, MDS_COUNTERS MBCR WITH(NOLOCK)
WHERE	MBC.COUNTER_ID=MBCR.COUNTER_ID
	AND MBC.TIME_STAMP BETWEEN @DTFrom AND @DTTo 
	AND (MBCR.SUBSYSTEM LIKE '%TC%' OR MBCR.SUBSYSTEM LIKE '%IC%' OR MBCR.SUBSYSTEM LIKE '%CS%' OR MBCR.SUBSYSTEM LIKE 'OS%')
	AND MBCR.TYPE='CV'

--BAG VOLUME
stp_RPT_CLT_Simple_BagVolume

--CBIS/BHS Faults/Events
stp_RPT_CLT_Simple_STAT_FAULTEVENT

--Bag Time in CBIS (Minutes)
stp_RPT_CLT_Simple_TimeInSystem