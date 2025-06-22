use uber_request
go

--select top 10 *,CONVERT(DATETIME, request_timestamp, 103) from [dbo].[UberRequestDataCleaned]
--select *,DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103)) AS Hour from [dbo].[UberRequestDataCleaned]
---1.cancellation rate by peakup points
SELECT 
    Pickup_point,
    COUNT(*) AS Total,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS Cancelled,
    ROUND(100.0 * SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) / COUNT(*), 2) AS Cancelled_Rate_Percent
FROM UberRequestDataCleaned
GROUP BY Pickup_point;

--2.Peak Request Hour

SELECT 
    DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103)) AS Hour,
    COUNT(*) AS Total_Requests
FROM UberRequestDataCleaned
GROUP BY DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103))
ORDER BY DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103));



---3. Status Breakdown By Count

SELECT
Status,
        COUNT(Status) AS Total_Requests
		,DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103)) AS Hour
    
FROM UberRequestDataCleaned

GROUP BY Status,DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103)) 

order by status,DATEPART(HOUR,CONVERT(DATETIME, request_timestamp, 103)) 

--4. Conversion Rate( Completed Vs Total Requests)
SELECT 
    COUNT(*) AS Total_Requests,
    SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END) AS Completed,
    ROUND(100.0 * SUM(CASE WHEN Status = 'Trip Completed' THEN 1 ELSE 0 END) / CAST(COUNT(*) AS FLOAT), 2) AS Completion_Rate_Percent

FROM UberRequestDataCleaned;


