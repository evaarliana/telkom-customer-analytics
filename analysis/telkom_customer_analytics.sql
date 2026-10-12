-- EDA-01: Calculate baseline customer, revenue, and churn metrics

SELECT
  (SELECT COUNT(DISTINCT customer_id)
    FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean
  ) AS total_customers
 , (SELECT SUM(bill_amount)
      FROM vi-project-telkom.telkomsel_vi_p1.billing_monthly_clean
   ) AS total_revenue
  , (SELECT AVG(bill_amount)
      FROM vi-project-telkom.telkomsel_vi_p1.billing_monthly_clean
    ) AS average_monthly_bill
  , (SELECT COUNTIF(churn = 1)
      FROM vi-project-telkom.telkomsel_vi_p1.customer_churn_clean
    ) AS churned_customers
  , (SELECT SAFE_DIVIDE(
      COUNTIF(churn = 1)
      , COUNT(*)
      )
      FROM vi-project-telkom.telkomsel_vi_p1.customer_churn_clean
    ) AS churn_rate;

-- Finding: 10% of customers churned during the observation period, establishing a baseline for retention analysis.



-- EDA-02: Analyze monthly customer growth based on customer join date
-- ⭐ Key Insight

WITH monthly_customers AS (
  SELECT
    DATE_TRUNC(join_date, MONTH) AS month
    , COUNT(DISTINCT customer_id) AS new_customers
  FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean
  GROUP BY month
)
    , customer_base AS (
      SELECT
        month
        , new_customers
        , SUM(new_customers) OVER (
            ORDER BY month
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS total_customers
      FROM monthly_customers
    )

SELECT
  month
  , new_customers
  , total_customers
  , ROUND(
      SAFE_DIVIDE(
        total_customers - LAG(total_customers) OVER (ORDER BY month)
        , LAG(total_customers) OVER (ORDER BY month)
      ) * 100
      , 2
  ) AS mom_growth_pct
FROM customer_base
ORDER BY 1;

-- Finding: Customer growth remained positive throughout the period, but its momentum gradually weakened as the customer base expanded.



-- EDA-03: Analyze monthly revenue and month-over-month revenue growth
-- ⭐ Key Insight

WITH revenue_by_month AS (
  SELECT
    month
    , SUM(bill_amount) AS total_revenue
  FROM vi-project-telkom.telkomsel_vi_p1.billing_monthly_clean
  GROUP BY month
)

SELECT
  month
  , total_revenue
  , ROUND(
      SAFE_DIVIDE(
        total_revenue - LAG(total_revenue) OVER (ORDER BY month)
        , LAG(total_revenue) OVER (ORDER BY month)
      ) * 100
      , 2
  ) AS mom_revenue_growth_pct
FROM revenue_by_month
ORDER BY 1;

-- Finding: Monthly revenue increased consistently to Rp5.17B, while MoM revenue growth decelerated from 104.88% to 3.49%.



-- EDA-04: Analyze revenue and customer contribution by package
-- ⭐ Key Insight

WITH package_performance AS (
  SELECT
    s.package_speed_mbps
    , COUNT(DISTINCT s.customer_id) AS total_customers
    , SUM(b.bill_amount) AS total_revenue
  FROM vi-project-telkom.telkomsel_vi_p1.subscription_clean s
  LEFT JOIN vi-project-telkom.telkomsel_vi_p1.billing_monthly_clean b
    ON s.customer_id = b.customer_id
  GROUP BY s.package_speed_mbps
)

SELECT
  package_speed_mbps
  , total_customers
  , total_revenue
  , ROUND(
      SAFE_DIVIDE(
        total_revenue
        , SUM(total_revenue) OVER ()
      ) * 100
      , 2
  ) AS revenue_contribution_pct
  , ROUND(
      SAFE_DIVIDE(
        total_revenue
        , total_customers
      )
      , 2
    ) AS revenue_per_customer
FROM package_performance
ORDER BY 3 DESC;

-- Finding: Lower-speed packages drive customer volume, while higher-speed packages generate higher revenue per customer. The 50 Mbps package contributes the largest revenue share (38.34%) due to its large customer base, while the 200 Mbps package has the highest revenue per customer (Rp4.00M).



-- EDA-05: Analyze customer distribution by district

WITH district_customers AS (
  SELECT
    district
    , COUNT(DISTINCT customer_id) AS total_customers
  FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean
  GROUP BY district
)

SELECT
  district
  , total_customers
  , ROUND(
      SAFE_DIVIDE(
        total_customers
        , SUM(total_customers) OVER ()
      ) * 100
      , 2
  ) AS customer_contribution_pct
FROM district_customers
ORDER BY 2 DESC;

-- Finding: Customer distribution is relatively broad across districts, with Ciracas contributing the largest share at 6.07%, while the top five districts collectively account for 29.24% of the customer base.



-- EDA-06: Analyze overall network quality score

SELECT
  ROUND(AVG(connection_quality_score),2) AS avg_network_quality_score
  , ROUND(MIN(connection_quality_score),2) AS min_network_quality_score
  , ROUND(MAX(connection_quality_score),2) AS max_network_quality_score
FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean

-- Finding: The overall network quality score averaged 81.68 during the observation period, although scores varied considerably across customer-month observations, ranging from 40.4 to 100.



-- EDA-07: Analyze network quality score by district
-- ⭐ Key Insight

SELECT
  cm.district
  , COUNT(DISTINCT nq.customer_id) AS total_customers
  , ROUND(AVG(nq.connection_quality_score), 2) AS avg_network_quality_score
FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean nq
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
  ON nq.customer_id = cm.customer_id
GROUP BY cm.district
ORDER BY 3 DESC;

-- Finding: Network quality varies substantially across districts, ranging from 69.95 to 94.95, indicating that customer network experience differs considerably by location and highlighting potential areas for targeted network improvement.



-- EDA-08: Analyze overall average network latency

SELECT
  ROUND(AVG(avg_latency_ms), 2) AS avg_latency_ms
  , ROUND(MIN(avg_latency_ms), 2) AS min_latency_ms
  , ROUND(MAX(avg_latency_ms), 2) AS max_latency_ms
FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean;

-- Finding: Average network latency was 22.84 ms, indicating relatively low overall latency, although individual observations ranged from 3.4 ms to 64.9 ms.



-- EDA-09: Analyze overall network downtime

SELECT
  ROUND(SUM(downtime_hours), 2) AS total_downtime_hours
  , ROUND(AVG(downtime_hours), 2) AS avg_downtime_hours
  , ROUND(MIN(downtime_hours), 2) AS min_downtime_hours
  , ROUND(MAX(downtime_hours), 2) AS max_downtime_hours
FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean;

-- Finding: Customers experienced an average of 3.21 hours of network downtime per customer-month, with downtime ranging from 0 to 16.78 hours.



-- EDA-10: Analyze network downtime by district and month

SELECT
  cm.district
  , nq.month
  , ROUND(SUM(nq.downtime_hours), 2) AS total_downtime_hours
  , ROUND(AVG(nq.downtime_hours), 2) AS avg_downtime_hours
FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean nq
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
  ON nq.customer_id = cm.customer_id
GROUP BY 1, 2
ORDER BY 2, 3 DESC;



-- EDA-10.1: Identify missing district-month combinations

WITH expected AS (
  SELECT
    district
    , month
  FROM (
    SELECT DISTINCT
      district
    FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean
    )
  CROSS JOIN (
    SELECT DISTINCT
      month
    FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean
  )
)

, actual AS (
    SELECT DISTINCT
      cm.district
      , nq.month
  FROM vi-project-telkom.telkomsel_vi_p1.network_quality_monthly_clean nq
  LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
    ON nq.customer_id = cm.customer_id
)

SELECT
  e.district
  , e.month
FROM expected e
LEFT JOIN actual a
  ON e.district = a.district
  AND e.month = a.month
WHERE a.district IS NULL;



-- EDA-10.2: Check customer join dates for the missing district-month

SELECT
  cm.district
  , MIN(cm.join_date) AS earliest_join_date
  , MAX(cm.join_date) AS latest_join_date
  , COUNT(DISTINCT cm.customer_id) AS total_customers
FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
WHERE cm.district = 'Kepulauan Seribu Utara'
GROUP BY 1;

-- Finding: Network quality data covered 485 of 486 expected district-month combinations. The only missing combination was Kepulauan Seribu Utara in January 2025, which is explained by the district's earliest customer joining in February 2025 rather than missing network data.



-- EDA-11: Analyze complaint distribution by category
-- ⭐ Key Insight

WITH complaint_categories AS (
  SELECT
    complaint_category
    , COUNT(*) AS total_complaints
  FROM vi-project-telkom.telkomsel_vi_p1.complaint_ticket_clean
  GROUP BY complaint_category
)

SELECT
  complaint_category
  , total_complaints
  , ROUND(
      SAFE_DIVIDE(
        total_complaints
        , SUM(total_complaints) OVER ()
      ) * 100
      , 2
  ) AS complaint_contribution_pct
FROM complaint_categories
ORDER BY 2 DESC;

-- Finding: Network reliability and speed appear to be the primary sources of customer complaints, highlighting network performance as a key area for customer experience improvement.



-- EDA-12: Analyze complaint distribution by district

SELECT
  cm.district
  , COUNT(DISTINCT cm.customer_id) AS total_customers
  , COUNT(ct.ticket_id) AS total_complaints
  , ROUND(
      SAFE_DIVIDE(
        COUNT(ct.ticket_id)
        , COUNT(DISTINCT cm.customer_id)
      )
      , 2
  ) AS complaints_per_customer
FROM vi-project-telkom.telkomsel_vi_p1.complaint_ticket_clean ct
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
  ON ct.customer_id = cm.customer_id
GROUP BY 1
ORDER BY 3 DESC;



-- EDA-12.1: Calculate complaints per customer by district

WITH district_customers AS (
  SELECT
    district
    , COUNT(DISTINCT customer_id) AS total_customers
  FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean
  GROUP BY district
)

, district_complaints AS (
    SELECT
      cm.district
      , COUNT(ct.ticket_id) AS total_complaints
    FROM vi-project-telkom.telkomsel_vi_p1.complaint_ticket_clean ct
    LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
      ON ct.customer_id = cm.customer_id
    GROUP BY cm.district
)

SELECT
  dc.district
  , dc.total_customers
  , COALESCE(dcp.total_complaints, 0) AS total_complaints
  , ROUND(
      SAFE_DIVIDE(
        COALESCE(dcp.total_complaints, 0)
        , dc.total_customers
      )
      , 2
  ) AS complaints_per_customer
FROM district_customers dc
LEFT JOIN district_complaints dcp
  ON dc.district = dcp.district
ORDER BY 4 DESC;

--  Finding: Complaint intensity varies substantially across districts. Penjaringan records the highest complaint intensity at 1.85 complaints per customer, while several districts with larger customer bases show lower complaint intensity.



-- EDA-13: Analyze complaint resolution time

SELECT
  ROUND(AVG(resolution_days), 2) AS avg_resolution_days
  , APPROX_QUANTILES(resolution_days, 100)[OFFSET(50)] AS median_resolution_days
  , MIN(resolution_days) AS min_resolution_days
  , MAX(resolution_days) AS max_resolution_days
FROM vi-project-telkom.telkomsel_vi_p1.complaint_ticket_clean;

--  Finding: Complaint resolution was relatively consistent, averaging 4.4 days with a median of 4 days and no extreme resolution delays.



-- EDA-14: Analyze overall customer satisfaction score

SELECT
  ROUND(AVG(satisfaction_score), 2) AS avg_satisfaction_score
  , ROUND(MIN(satisfaction_score), 2) AS min_satisfaction_score
  , ROUND(MAX(satisfaction_score), 2) AS max_satisfaction_score
FROM vi-project-telkom.telkomsel_vi_p1.complaint_ticket_clean;

-- Finding: Customer satisfaction averaged 3.1 out of 5, indicating moderate satisfaction among customers who submitted complaints and highlighting room for customer experience improvement.



-- EDA-15: Calculate overall customer retention rate

SELECT
  COUNT(*) AS total_customers
  , COUNTIF(churn = 0) AS retained_customers
  , COUNTIF(churn = 1) AS churned_customers
  , ROUND(
      SAFE_DIVIDE(
        COUNTIF(churn = 0)
        , COUNT(*)
      ) * 100
      , 2
  ) AS retention_rate
FROM vi-project-telkom.telkomsel_vi_p1.customer_churn_clean;

-- Finding: Customer retention stood at 90%, with 18,000 customers retained and 2,000 customers churned during the observation period.



-- EDA-16: Analyze monthly churn trend

WITH monthly_churn AS (
  SELECT
    DATE_TRUNC(churn_date, MONTH) AS month
    , COUNTIF(churn = 1) AS churned_customers
  FROM vi-project-telkom.telkomsel_vi_p1.customer_churn_clean
  WHERE churn = 1
  GROUP BY month
)

SELECT
  month
  , churned_customers
  , ROUND(
      SAFE_DIVIDE(
        churned_customers
        , SUM(churned_customers) OVER ()
      ) * 100
      , 2
   ) AS churn_contribution_pct
FROM monthly_churn
ORDER BY 1;


-- Finding: Churn volume increased substantially over time, from 210 customers in H1 2025 to 1,202 in H1 2026, peaking at 233 churned customers in January 2026.



-- EDA-17: Analyze churn rate by district

SELECT
  cm.district
  , COUNT(DISTINCT cm.customer_id) AS total_customers
  , COUNTIF(cc.churn = 1) AS churned_customers
  , ROUND(
      SAFE_DIVIDE(
        COUNTIF(cc.churn = 1)
        , COUNT(DISTINCT cm.customer_id)
      ) * 100
      , 2
  ) AS churn_rate_pct
FROM vi-project-telkom.telkomsel_vi_p1.customer_master_clean cm
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_churn_clean cc
  ON cm.customer_id = cc.customer_id
GROUP BY cm.district
ORDER BY 4 DESC;

-- Finding: Churn rates vary substantially across districts, ranging from 3.00% to 24.24% versus the 10% overall baseline. Among districts with larger customer bases, Cakung, Penjaringan, Cilincing, and Koja show notably elevated churn rates, highlighting potential retention hotspots.



-- EDA-18: Analyze churn rate by contract type
-- ⭐ Key Insight

SELECT
  s.contract_type
  , COUNT(DISTINCT s.customer_id) AS total_customers
  , COUNTIF(cc.churn = 1) AS churned_customers
  , ROUND(
      SAFE_DIVIDE(
        COUNTIF(cc.churn = 1)
        , COUNT(DISTINCT s.customer_id)
      ) * 100
      , 2
  ) AS churn_rate_pct
FROM vi-project-telkom.telkomsel_vi_p1.subscription_clean s
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_churn_clean cc
  ON s.customer_id = cc.customer_id
GROUP BY s.contract_type
ORDER BY 4 DESC;

-- Finding: Monthly-contract customers show higher churn risk, with an 11.49% churn rate compared with 6.02% for 6-month and 3.18% for 12-month contracts, highlighting monthly customers as a key retention segment.



-- EDA-19: Analyze churn rate by package speed

SELECT
  s.package_speed_mbps
  , COUNT(DISTINCT s.customer_id) AS total_customers
  , COUNTIF(cc.churn = 1) AS churned_customers
  , ROUND(
      SAFE_DIVIDE(
        COUNTIF(cc.churn = 1)
        , COUNT(DISTINCT s.customer_id)
      ) * 100
      , 2
  ) AS churn_rate_pct
FROM vi-project-telkom.telkomsel_vi_p1.subscription_clean s
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_churn_clean cc
  ON s.customer_id = cc.customer_id
GROUP BY 1
ORDER BY 4 DESC;

-- Finding: Churn varies by package, with the largest 50 Mbps customer segment recording a slightly above-baseline churn rate of 10.73%, while 200 Mbps has the lowest rate at 7.97%.



-- EDA-20: Analyze churn reasons among churned customers
-- ⭐ Key Insight

SELECT
  churn_reason
  , COUNT(*) AS churned_customers
  , ROUND(
      SAFE_DIVIDE(
        COUNT(*)
          , SUM(COUNT(*)) OVER ()
        ) * 100
      , 2
  ) AS churn_contribution_pct
FROM vi-project-telkom.telkomsel_vi_p1.customer_churn_clean
WHERE churn = 1
GROUP BY 1
ORDER BY 2 DESC;

-- Finding: Network Quality is the primary churn reason, accounting for 43.45% of churned customers, highlighting network experience as a key area for retention improvement.



-- EDA-21: Calculate monthly ARPU

SELECT
  month
  , SUM(bill_amount) AS monthly_revenue
  , COUNT(DISTINCT customer_id) AS active_customers
  , ROUND(
      SAFE_DIVIDE(
        SUM(bill_amount)
        , COUNT(DISTINCT customer_id)
      )
      , 2
  ) AS arpu
FROM vi-project-telkom.telkomsel_vi_p1.billing_monthly_clean
GROUP BY 1
ORDER BY 1;

-- Finding: Revenue growth was primarily driven by the expansion of the customer base, while ARPU remained relatively stable at around Rp260K per month.



-- EDA-22: Compare usage behavior across package speeds

SELECT
  s.package_speed_mbps
  , COUNT(DISTINCT s.customer_id) AS total_customers
  , ROUND(AVG(u.internet_usage_gb), 2) AS avg_monthly_usage_gb
  , ROUND(AVG(u.active_days), 2) AS avg_active_days
  , ROUND(AVG(u.peak_hour_usage_pct), 2) AS avg_peak_hour_usage_pct
FROM vi-project-telkom.telkomsel_vi_p1.subscription_clean s
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.usage_monthly_clean u
  ON s.customer_id = u.customer_id
GROUP BY 1
ORDER BY 1;



-- EDA-23: Identify high-usage customers within the 50 Mbps segment

WITH customer_usage AS (
  SELECT
    s.customer_id
    , AVG(u.internet_usage_gb) AS avg_monthly_usage_gb
  FROM vi-project-telkom.telkomsel_vi_p1.subscription_clean s
  INNER JOIN vi-project-telkom.telkomsel_vi_p1.usage_monthly_clean u
    ON s.customer_id = u.customer_id
  WHERE s.package_speed_mbps = 50
  GROUP BY s.customer_id
)

, usage_threshold AS (
    SELECT
      APPROX_QUANTILES(avg_monthly_usage_gb, 100)[OFFSET(75)] AS p75_usage_gb
      , APPROX_QUANTILES(avg_monthly_usage_gb, 100)[OFFSET(90)] AS p90_usage_gb
    FROM customer_usage
)

SELECT
  CASE
    WHEN cu.avg_monthly_usage_gb >= ut.p90_usage_gb THEN 'Top 10% Usage'
    WHEN cu.avg_monthly_usage_gb >= ut.p75_usage_gb THEN 'Top 11-25% Usage'
    ELSE 'Bottom 75% Usage'
  END AS usage_segment
  , COUNT(*) AS customers
  , COUNTIF(cc.churn = 1) AS churned_customers
  , ROUND(
      SAFE_DIVIDE(
        COUNTIF(cc.churn = 1)
        , COUNT(*)
      ) * 100
      , 2
  ) AS churn_rate_pct
  , ROUND(AVG(cu.avg_monthly_usage_gb), 2) AS avg_usage_gb
FROM customer_usage cu
CROSS JOIN usage_threshold ut
LEFT JOIN vi-project-telkom.telkomsel_vi_p1.customer_churn_clean cc
  ON cu.customer_id = cc.customer_id
GROUP BY usage_segment
ORDER BY
  CASE usage_segment
    WHEN 'Top 10% Usage' THEN 1
    WHEN 'Top 11-25% Usage' THEN 2
  ELSE 3
  END;
