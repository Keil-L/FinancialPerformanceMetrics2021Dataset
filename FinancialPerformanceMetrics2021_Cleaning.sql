
-- Start transaction for data cleaning
BEGIN TRANSACTION;

-- Step 1: Handle Null Values in Metrics 5 to 8
UPDATE FinancialPerformanceMetrics2021
SET 
    Metric_5 = COALESCE(Metric_5, (SELECT AVG(Metric_5) FROM FinancialPerformanceMetrics2021 WHERE Metric_5 IS NOT NULL)),
    Metric_6 = COALESCE(Metric_6, (SELECT AVG(Metric_6) FROM FinancialPerformanceMetrics2021 WHERE Metric_6 IS NOT NULL)),
    Metric_7 = COALESCE(Metric_7, (SELECT AVG(Metric_7) FROM FinancialPerformanceMetrics2021 WHERE Metric_7 IS NOT NULL)),
    Metric_8 = COALESCE(Metric_8, (SELECT AVG(Metric_8) FROM FinancialPerformanceMetrics2021 WHERE Metric_8 IS NOT NULL));

-- Step 2: Normalize Metrics 1 to 4 (Min-Max Normalization)
DECLARE @MinMetric1 FLOAT, @MaxMetric1 FLOAT, @MinMetric2 FLOAT, @MaxMetric2 FLOAT, @MinMetric3 FLOAT, @MaxMetric3 FLOAT, @MinMetric4 FLOAT, @MaxMetric4 FLOAT;

SELECT @MinMetric1 = MIN(Metric_1), @MaxMetric1 = MAX(Metric_1),
       @MinMetric2 = MIN(Metric_2), @MaxMetric2 = MAX(Metric_2),
       @MinMetric3 = MIN(Metric_3), @MaxMetric3 = MAX(Metric_3),
       @MinMetric4 = MIN(Metric_4), @MaxMetric4 = MAX(Metric_4)
FROM FinancialPerformanceMetrics2021;

UPDATE FinancialPerformanceMetrics2021
SET 
    Metric_1 = (Metric_1 - @MinMetric1) / (@MaxMetric1 - @MinMetric1),
    Metric_2 = (Metric_2 - @MinMetric2) / (@MaxMetric2 - @MinMetric2),
    Metric_3 = (Metric_3 - @MinMetric3) / (@MaxMetric3 - @MinMetric3),
    Metric_4 = (Metric_4 - @MinMetric4) / (@MaxMetric4 - @MinMetric4);

-- Step 3: Outlier Detection and Handling in Metric_9 and Metric_10
DECLARE @MedianMetric9 FLOAT, @MedianMetric10 FLOAT, @StdDevMetric9 FLOAT, @StdDevMetric10 FLOAT;

SELECT @MedianMetric9 = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Metric_9) OVER (),
       @MedianMetric10 = PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY Metric_10) OVER (),
       @StdDevMetric9 = STDEV(Metric_9),
       @StdDevMetric10 = STDEV(Metric_10)
FROM FinancialPerformanceMetrics2021;

UPDATE FinancialPerformanceMetrics2021
SET 
    Metric_9 = CASE 
                  WHEN ABS(Metric_9 - @MedianMetric9) > 3 * @StdDevMetric9 THEN @MedianMetric9 
                  ELSE Metric_9 
               END,
    Metric_10 = CASE 
                   WHEN ABS(Metric_10 - @MedianMetric10) > 3 * @StdDevMetric10 THEN @MedianMetric10 
                   ELSE Metric_10 
                END;

-- Step 4: Add a new column OverallScore
ALTER TABLE FinancialPerformanceMetrics2021 ADD OverallScore DECIMAL(10,2);

UPDATE FinancialPerformanceMetrics2021
SET OverallScore = (Metric_1 + Metric_2 + Metric_3 + Metric_4 + Metric_5 + Metric_6 + Metric_7 + Metric_8 + Metric_9 + Metric_10 + Metric_11 + Metric_12 + Metric_13 + Metric_14 + Metric_15) / 15;

-- Commit the transaction to finalize changes
COMMIT TRANSACTION;
