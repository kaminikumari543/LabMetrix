USE [Fly_Emirates]
GO
--1: Project Setup & Data Ingestion

--SELECT * FROM flights



SELECT 
    f.*,

    -- Combine YEAR, MONTH, DAY, and extract time from SCHEDULED_DEPARTURE (HHMM)
    CAST(
        STUFF(STUFF(
            FORMAT(f.YEAR, '0000') + FORMAT(f.MONTH, '00') + FORMAT(f.DAY, '00') +
            RIGHT('0000' + CAST(f.SCHEDULED_DEPARTURE AS VARCHAR), 4),
        9, 0, ' '), 12, 0, ':') AS DATETIME
    ) AS FLIGHT_DATETIME,

    -- Extract just the DATE
    CAST(
        FORMAT(f.YEAR, '0000') + '-' + FORMAT(f.MONTH, '00') + '-' + FORMAT(f.DAY, '00')
        AS DATE
    ) AS FLIGHT_DATE,

    -- Extract only TIME portion from SCHEDULED_DEPARTURE
    CAST(
        LEFT(RIGHT('0000' + CAST(f.SCHEDULED_DEPARTURE AS VARCHAR), 4), 2) + ':' +
        RIGHT(RIGHT('0000' + CAST(f.SCHEDULED_DEPARTURE AS VARCHAR), 4), 2)
        AS TIME
    ) AS SCHEDULED_TIME

FROM flights f;

SELECT 
    f.*,

    -- 2. Handle missing delay/cancellation values
    ISNULL(f.DEPARTURE_DELAY, 0) AS CLEANED_DEPARTURE_DELAY,
    ISNULL(f.ARRIVAL_DELAY, 0) AS CLEANED_ARRIVAL_DELAY,
    ISNULL(f.CANCELLED, 0) AS CLEANED_CANCELLED,

    -- 3. Add cancellation reason description
    CASE f.CANCELLATION_REASON
        WHEN 'A' THEN 'Airline Issue'
        WHEN 'B' THEN 'Weather'
        WHEN 'C' THEN 'National Air System'
        WHEN 'D' THEN 'Security'
        ELSE 'Not Cancelled / Unknown'
    END AS CANCELLATION_REASON_DESC

FROM flights f;

-- Drop the table if it already exists
IF OBJECT_ID('Cleaned_Flight_Data', 'U') IS NOT NULL
    DROP TABLE Cleaned_Flight_Data;

-- Now safely create the table with SELECT INTO
SELECT 
    f.*,
    a.AIRLINE AS AIRLINE_NAME,
    ao.AIRPORT AS ORIGIN_AIRPORT_NAME,
    ao.CITY AS ORIGIN_CITY,
    ao.STATE AS ORIGIN_STATE,
    ad.AIRPORT AS DESTINATION_AIRPORT_NAME,
    ad.CITY AS DESTINATION_CITY,
    ad.STATE AS DESTINATION_STATE
INTO Cleaned_Flight_Data
FROM flights f
LEFT JOIN airlines a ON f.AIRLINE = a.IATA_CODE
LEFT JOIN airports ao ON f.ORIGIN_AIRPORT = ao.IATA_CODE
LEFT JOIN airports ad ON f.DESTINATION_AIRPORT = ad.IATA_CODE;


select * from Cleaned_Flight_Data

--1 Total Flights, Cancellations, and Diversions
SELECT 
    COUNT(*) AS Total_Flights,
    SUM(CASE WHEN CANCELLED = 1 THEN 1 ELSE 0 END) AS Total_Cancelled,
    SUM(CASE WHEN DIVERTED = 1 THEN 1 ELSE 0 END) AS Total_Diverted
FROM Cleaned_Flight_Data;

--2 Cancellations by Reason
SELECT 
    CASE CANCELLATION_REASON
        WHEN 'A' THEN 'Airline Issue'
        WHEN 'B' THEN 'Weather'
        WHEN 'C' THEN 'National Air System'
        WHEN 'D' THEN 'Security'
        ELSE 'Not Cancelled / Unknown'
    END AS CANCELLATION_REASON_DESC,
    COUNT(*) AS Cancelled_Flights
FROM Cleaned_Flight_Data
WHERE CANCELLED = 1
GROUP BY 
    CASE CANCELLATION_REASON
        WHEN 'A' THEN 'Airline Issue'
        WHEN 'B' THEN 'Weather'
        WHEN 'C' THEN 'National Air System'
        WHEN 'D' THEN 'Security'
        ELSE 'Not Cancelled / Unknown'
    END;
	--Data Cleaning, Preparation & Integration (SQL)
	-- Departure & Arrival Delay Statistics
	--2.1 Basic Stats: Departure Delay
	SELECT
    AVG(CAST(DEPARTURE_DELAY AS FLOAT)) AS Avg_Departure_Delay,
    MIN(DEPARTURE_DELAY) AS Min_Departure_Delay,
    MAX(DEPARTURE_DELAY) AS Max_Departure_Delay
FROM Cleaned_Flight_Data
WHERE DEPARTURE_DELAY IS NOT NULL;

--2.2Basic Stats: Arrival Delay
SELECT
    AVG(CAST(ARRIVAL_DELAY AS FLOAT)) AS Avg_Arrival_Delay,
    MIN(ARRIVAL_DELAY) AS Min_Arrival_Delay,
    MAX(ARRIVAL_DELAY) AS Max_Arrival_Delay
FROM Cleaned_Flight_Data
WHERE ARRIVAL_DELAY IS NOT NULL;

--2.3 Median Delays
SELECT DISTINCT
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY DEPARTURE_DELAY) 
        OVER () AS Median_Departure_Delay,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY ARRIVAL_DELAY) 
        OVER () AS Median_Arrival_Delay
FROM Cleaned_Flight_Data;


SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Cleaned_Flight_Data';
--3.Exploratory Data Analysis (EDA) & KPI Definition (SQL)
--.1 Total & Avg by Delay Type
SELECT
    SUM(AIRLINE_DELAY) AS Total_Airline_Delay,
    SUM(WEATHER_DELAY) AS Total_Weather_Delay,
    SUM(AIR_SYSTEM_DELAY) AS Total_AirSystem_Delay,
    SUM(SECURITY_DELAY) AS Total_Security_Delay,
    SUM(LATE_AIRCRAFT_DELAY) AS Total_LateAircraft_Delay,
    
    AVG(AIRLINE_DELAY) AS Avg_Airline_Delay,
    AVG(WEATHER_DELAY) AS Avg_Weather_Delay,
    AVG(AIR_SYSTEM_DELAY) AS Avg_AirSystem_Delay,
    AVG(SECURITY_DELAY) AS Avg_Security_Delay,
    AVG(LATE_AIRCRAFT_DELAY) AS Avg_LateAircraft_Delay
FROM Cleaned_Flight_Data;
--3.Define Key Performance Indicators (KPIs)
--1. On-Time Performance (OTP) Rate
--Flights are considered on-time if ARRIVAL_DELAY <= 15.
SELECT 
    COUNT(*) AS Total_Flights,
    SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) AS OnTime_Flights,
    ROUND(100.0 * SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS OTP_Rate_Percentage
FROM Cleaned_Flight_Data
WHERE CANCELLED = 0 AND DIVERTED = 0;
--2. Average Arrival & Departure Delay
SELECT
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    ROUND(AVG(DEPARTURE_DELAY), 2) AS Avg_Departure_Delay
FROM Cleaned_Flight_Data
WHERE CANCELLED = 0 AND DIVERTED = 0;

--3. Cancellation Rate
SELECT 
    COUNT(*) AS Total_Flights,
    SUM(CAST(CANCELLED AS INT)) AS Cancelled_Flights,
    ROUND(100.0 * SUM(CAST(CANCELLED AS INT)) / COUNT(*), 2) AS Cancellation_Rate_Percentage
FROM Cleaned_Flight_Data;
-- 4. Percentage Contribution of Each Delay Type
SELECT 
    'Airline Delay' AS Delay_Type,
    SUM(AIRLINE_DELAY) AS Total_Minutes,
    ROUND(100.0 * SUM(AIRLINE_DELAY) / NULLIF(SUM(
        AIRLINE_DELAY + WEATHER_DELAY + AIR_SYSTEM_DELAY + SECURITY_DELAY + LATE_AIRCRAFT_DELAY), 0), 2) AS Percentage_Contribution
FROM Cleaned_Flight_Data

UNION ALL

SELECT 
    'Weather Delay',
    SUM(WEATHER_DELAY),
    ROUND(100.0 * SUM(WEATHER_DELAY) / NULLIF(SUM(
        AIRLINE_DELAY + WEATHER_DELAY + AIR_SYSTEM_DELAY + SECURITY_DELAY + LATE_AIRCRAFT_DELAY), 0), 2)
FROM Cleaned_Flight_Data

UNION ALL

SELECT 
    'Air System Delay',
    SUM(AIR_SYSTEM_DELAY),
    ROUND(100.0 * SUM(AIR_SYSTEM_DELAY) / NULLIF(SUM(
        AIRLINE_DELAY + WEATHER_DELAY + AIR_SYSTEM_DELAY + SECURITY_DELAY + LATE_AIRCRAFT_DELAY), 0), 2)
FROM Cleaned_Flight_Data

UNION ALL

SELECT 
    'Security Delay',
    SUM(SECURITY_DELAY),
    ROUND(100.0 * SUM(SECURITY_DELAY) / NULLIF(SUM(
        AIRLINE_DELAY + WEATHER_DELAY + AIR_SYSTEM_DELAY + SECURITY_DELAY + LATE_AIRCRAFT_DELAY), 0), 2)
FROM Cleaned_Flight_Data

UNION ALL

SELECT 
    'Late Aircraft Delay',
    SUM(LATE_AIRCRAFT_DELAY),
    ROUND(100.0 * SUM(LATE_AIRCRAFT_DELAY) / NULLIF(SUM(
        AIRLINE_DELAY + WEATHER_DELAY + AIR_SYSTEM_DELAY + SECURITY_DELAY + LATE_AIRCRAFT_DELAY), 0), 2)
FROM Cleaned_Flight_Data;
-- KPI Breakdowns by Category
--A. By Airline
SELECT 
    AIRLINE_NAME,
    COUNT(*) AS Total_Flights,
    100.0 * SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) / COUNT(*) AS OTP_Rate,
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    ROUND(AVG(DEPARTURE_DELAY), 2) AS Avg_Departure_Delay,
    100.0 * SUM(CAST(CANCELLED AS INT)) / COUNT(*) AS Cancellation_Rate
FROM Cleaned_Flight_Data
GROUP BY AIRLINE_NAME;

--B. By Origin & Destination Airport
SELECT 
    ORIGIN_AIRPORT_NAME,
    DESTINATION_AIRPORT_NAME,
    COUNT(*) AS Total_Flights,
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    ROUND(AVG(DEPARTURE_DELAY), 2) AS Avg_Departure_Delay,
    100.0 * SUM(CAST(CANCELLED AS INT)) / COUNT(*) AS Cancellation_Rate
FROM Cleaned_Flight_Data
GROUP BY ORIGIN_AIRPORT_NAME, DESTINATION_AIRPORT_NAME;

-- C. By Month
SELECT 
    MONTH,
    COUNT(*) AS Total_Flights,
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    ROUND(100.0 * SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS OTP_Rate,
    ROUND(100.0 * SUM(CAST(CANCELLED AS INT)) / COUNT(*), 2) AS Cancellation_Rate
FROM Cleaned_Flight_Data
GROUP BY MONTH
ORDER BY MONTH;
--D. By Day of Week
SELECT 
    DAY_OF_WEEK,
    COUNT(*) AS Total_Flights,
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    ROUND(100.0 * SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) / COUNT(*), 2) AS OTP_Rate,
    ROUND(100.0 * SUM(CAST(CANCELLED AS INT)) / COUNT(*), 2) AS Cancellation_Rate
FROM Cleaned_Flight_Data
GROUP BY DAY_OF_WEEK
ORDER BY DAY_OF_WEEK;
--E. By Time of Day (Using Scheduled Departure Hour)
SELECT 
    FLOOR(SCHEDULED_DEPARTURE / 100) AS Departure_Hour,
    COUNT(*) AS Total_Flights,
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS OTP_Rate
FROM Cleaned_Flight_Data
GROUP BY FLOOR(SCHEDULED_DEPARTURE / 100)
ORDER BY Departure_Hour;

-- E. By Time of Day (Using Scheduled Departure Hour)
SELECT 
    FLOOR(SCHEDULED_DEPARTURE / 100) AS Departure_Hour,
    COUNT(*) AS Total_Flights,
    ROUND(AVG(ARRIVAL_DELAY), 2) AS Avg_Arrival_Delay,
    SUM(CASE WHEN ARRIVAL_DELAY <= 15 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS OTP_Rate
FROM Cleaned_Flight_Data
GROUP BY FLOOR(SCHEDULED_DEPARTURE / 100)
ORDER BY Departure_Hour;














