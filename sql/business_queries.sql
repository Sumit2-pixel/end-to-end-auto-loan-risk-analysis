-- =====================================================
-- Business Question: 1
-- What is the total outstanding loan balance of the portfolio?
-- =====================================================

SELECT
    round(SUM("CurrentBalance")::numeric,2) AS total_outstanding_balance
FROM auto_loan;

-- Business Insight
-- The total outstanding loan balance of
-- the portfolio is 317.79 million. This represents the total value of active loans currently owed by borrowers and indicates the
-- overall size of the loan portfolio.



-- =====================================================
-- Business Question: 2
-- What is the total number of auto loans in the portfolio?
-- =====================================================

select
   COUNT(DISTINCT "LoanID") as total_auto_loans
from auto_loan;

-- Business Insight
-- The portfolio contains 500 unique auto loans. 
-- This metric represents the total number of active loan
-- accounts in the portfolio and serves as the foundation for analyzing portfolio size, credit risk,
-- and performance.



-- =====================================================
-- Business Question: 3
-- What is the total Expected Credit Loss (ECL) of the portfolio?
-- =====================================================

SELECT ROUND(SUM("ECL_Provision")::NUMERIC,2) as total_expected_credit_loss
FROM auto_loan;

-- Business Insight
-- The portfolio has a total Expected Credit Loss
-- (ECL) of 11.66 million. This represents the estimated
-- amount the lender expects to lose due to potential loan 
-- defaults based on the current risk profile of the portfolio.



-- =====================================================
-- Business Question: 4
-- What percentage of the loan portfolio is classified as 
-- risky (IFRS 9 Stage 2 and Stage 3)?
-- =====================================================

SELECT
    COUNT(DISTINCT "LoanID") AS total_loans,

    COUNT(
        CASE
            WHEN "IFRS9_Stage" IN (2,3) THEN 1
        END
    ) AS risky_loans,

    ROUND(
        COUNT(
            CASE
                WHEN "IFRS9_Stage" IN (2,3) THEN 1
            END
        ) * 100.0
        / COUNT(DISTINCT "LoanID"),
        2
    ) AS risky_loan_percent
FROM auto_loan;

-- Business Insight
-- 15.60% of the total loan portfolio is classified as risky (IFRS 9 Stage 2 & Stage 3), 
-- indicating that approximately one out of every six loans requires closer monitoring
-- due to elevated credit risk.



-- =====================================================
-- Business Question: 5
-- What is the average outstanding loan balance per loan?
-- =====================================================

SELECT ROUND(SUM("CurrentBalance")::NUMERIC,2) as total_outstanding_amount,
COUNT(DISTINCT "LoanID") as total_loan,
ROUND(SUM("CurrentBalance")::NUMERIC / COUNT(DISTINCT "LoanID"),2) as avg_outstanding_balance
FROM auto_loan;

-- Business Insight
-- The portfolio has an average outstanding loan balance of ₹635,570.40 
-- per loan, indicating that each active loan carries an average unpaid 
-- balance of approximately ₹6.36 lakh. This metric helps assess the average 
-- portfolio exposure per borrower and is useful for monitoring credit risk and portfolio size.



-- =====================================================
-- Business Question: 6
-- Which vehicle type has the highest total outstanding 
-- loan balance?
-- =====================================================

select "VehicleType",
sum("CurrentBalance") as outstanding_amount
from auto_loan
group by "VehicleType"
order by outstanding_amount desc
LIMIT 1;

-- Business Insight
-- SUV loans have the highest outstanding loan balance 
-- in the portfolio, with a total exposure of ₹95.31 million.
-- This indicates that SUVs contribute the largest share of the bank's outstanding auto
-- loan portfolio and represent the highest financial exposure among all vehicle categories.



-- =====================================================
-- Business Question: 7
-- Which state has the highest Risky Loan Percentage
-- (IFRS 9 Stage 2 & Stage 3)?
-- =====================================================

SELECT
    "State",
    COUNT(DISTINCT "LoanID") AS total_loans,

    COUNT(
        CASE
            WHEN "IFRS9_Stage" IN (2,3) THEN 1
        END
    ) AS risky_loans,

    ROUND(
        COUNT(
            CASE
                WHEN "IFRS9_Stage" IN (2,3) THEN 1
            END
        ) * 100.0
        / COUNT(DISTINCT "LoanID"),
        2
    ) AS risky_loan_percent
FROM auto_loan
group by "State"
order by risky_loan_percent desc
limit 1;

-- Business Insight
-- Chhattisgarh has the highest risky loan percentage in 
-- the portfolio, with 26.09% of its loans classified under 
-- IFRS 9 Stage 2 and Stage 3. This indicates that approximately 1 
-- out of every 4 loans in the state is considered risky, making it a
-- high-priority region for credit monitoring, collection efforts, and risk management.




-- =====================================================
-- Business Question: 8
-- How is the outstanding loan balance distributed across 
-- different DPD buckets?
-- =====================================================

select
dsh."DPD_Bucket" as buckects,
sum(al."CurrentBalance" )as outstanding_balance
from
auto_loan al
join dpd_snapshot_history dsh
on al."LoanID" = dsh."LoanID"
group by "DPD_Bucket"
order by outstanding_balance desc;
;

-- Business Insight
-- The majority of the outstanding loan balance (₹3.31 billion)
-- is concentrated in the Current DPD bucket, indicating that most borrowers
-- are making timely payments. However, a significant amount of outstanding balance
-- still exists in overdue buckets, particularly the 1–29 DPD segment, which requires close
-- monitoring to prevent loans from progressing into higher-risk delinquency categories.




-- =====================================================
-- Business Question: 9
-- What is the current DPD distribution of loans across 
-- the portfolio?
-- =====================================================

select
dsh."DPD_Bucket" as buckects,
COUNT(DISTINCT al."LoanID") as total_loans,
COUNT(DISTINCT al."LoanID") *  100.0
/
(
select COUNT(DISTINCT al."LoanID")
from auto_loan al
join dpd_snapshot_history dsh
on al."LoanID" = dsh."LoanID"

)  as percent
from
auto_loan al
join dpd_snapshot_history dsh
on al."LoanID" = dsh."LoanID"
WHERE "SnapshotDate" = (
    SELECT MAX("SnapshotDate")
    FROM dpd_snapshot_history
)
group by "DPD_Bucket"
order by total_loans desc;

-- Bussiness Insights
-- The portfolio appears healthy because most loans are in
-- the Current bucket. However, the 1–29 DPD segment requires immediate
-- attention, as timely collection at this stage can prevent loans from 
-- progressing into higher-risk delinquency buckets, ultimately reducing expected credit losses.




-- =====================================================
-- Business Question: 10
-- Which vehicle types contribute the most to the 
-- outstanding loan portfolio and credit risk?
-- =====================================================

select
"VehicleType",
ROUND(SUM("CurrentBalance")::NUMERIC,2) as outstanding_amount,
COUNT(
        CASE
            WHEN "IFRS9_Stage" IN (2,3) THEN 1
        END
    ) AS risky_loans,

   ROUND(
        COUNT(
            CASE
                WHEN "IFRS9_Stage" IN (2,3) THEN 1
            END
        ) * 100.0
        / COUNT(DISTINCT "LoanID"),
        2
    ) AS risky_loan_percent
	
from auto_loan
group by "VehicleType"
order by risky_loan_percent desc;

-- Bussiness Insights
-- SUV contributes the highest outstanding loan portfolio (95.31M) 
-- while maintaining the lowest risky loan percentage (10.10%), 
-- indicating a relatively healthy lending segment.
-- Hatchback has the highest risky loan percentage (19.78%),
-- suggesting that this segment requires closer credit monitoring and 
-- stricter risk management.




-- =====================================================
-- Business Question: 11
-- Which combination of Region, VehicleType, and 
-- DelinquencyStatus represents the highest overall 
-- portfolio risk?
-- =====================================================

select "Region",
"VehicleType",
"DelinquencyStatus",
sum("CurrentBalance") as outstanding_balance,
count(DISTINCT "LoanID") as loan_count,
sum("ECL_Provision") as ecl_provision,
round(sum("ECL_Provision")::numeric  * 100/ sum("CurrentBalance")::numeric,2)  as ecl_percent
from auto_loan
group by "Region",
"VehicleType",
"DelinquencyStatus"
HAVING SUM("CurrentBalance") > 0
order by ecl_percent desc
;

-- Bussiness Insights
-- I grouped the portfolio by Region, Vehicle Type, and Delinquency Status. 
-- For each combination, I calculated Outstanding Balance, Loan Count, Total
-- Expected Credit Loss, and ECL %. I excluded combinations with zero outstanding 
-- balance because they no longer represent active portfolio risk. Finally, I sorted by
-- ECL % to identify the highest-risk segments that require immediate monitoring.





-- =====================================================
-- Business Question: 12
-- Which vintage pools exhibit the highest cumulative 
-- net loss rates?
-- =====================================================

SELECT
    "VintageID",
    "MonthsOnBook",
    ROUND("OriginalPoolBalance"::NUMERIC,2) AS original_pool_balance,
    ROUND("RemainingPoolBalance"::NUMERIC,2) AS remaining_pool_balance,
    ROUND("CumulativeNetLoss"::NUMERIC,2) AS cumulative_net_loss,
    ROUND("CumulativeNetLossRate"::NUMERIC * 100,2) AS cumulative_net_loss_rate
FROM static_pool_vintage
ORDER BY "CumulativeNetLossRate" DESC;

-- Bussiness Insights
-- Vintage pools with the highest cumulative net loss
-- rates indicate weaker long-term portfolio performance 
-- and higher realized credit losses. These pools require closer 
-- monitoring and can help improve future underwriting and securitisation strategies.




-- =====================================================
-- Business Question: 13
-- Which origination channels generate the highest 
-- credit risk?
-- =====================================================

SELECT
    "OriginationChannel",
    ROUND(SUM("CurrentBalance")::NUMERIC,2) AS outstanding_balance,
    COUNT(DISTINCT "LoanID") AS loan_count,
    ROUND(SUM("ECL_Provision")::NUMERIC,2) AS total_ecl,
    ROUND(
        SUM("ECL_Provision")::NUMERIC * 100 /
        SUM("CurrentBalance")::NUMERIC,
        2
    ) AS ecl_percent
FROM auto_loan
GROUP BY "OriginationChannel"
HAVING SUM("CurrentBalance") > 0
ORDER BY ecl_percent DESC;

-- Bussiness Insights
-- Origination channels with higher ECL percentages 
-- are contributing riskier borrowers to the portfolio.
-- Monitoring channel-wise credit quality helps improve sourcing strategies
-- and underwriting standards.





-- =====================================================
-- Business Question: 14
-- Which servicers manage the riskiest loan portfolio?
-- =====================================================

SELECT
    "ServicerName",
    ROUND(SUM("CurrentBalance")::NUMERIC,2) AS outstanding_balance,
    COUNT(DISTINCT "LoanID") AS loan_count,
    ROUND(SUM("ECL_Provision")::NUMERIC,2) AS total_ecl,
    ROUND(
        SUM("ECL_Provision")::NUMERIC * 100 /
        SUM("CurrentBalance")::NUMERIC,
        2
    ) AS ecl_percent
FROM auto_loan
GROUP BY "ServicerName"
HAVING SUM("CurrentBalance") > 0
ORDER BY ecl_percent DESC;

-- Bussiness Insights
-- Servicers with higher ECL percentages
-- manage comparatively weaker loan portfolios and
-- may require stronger collection efforts, operational improvements,
-- or closer performance monitoring.





-- =====================================================
-- Business Question: 15
-- Which employment segments have the highest portfolio
-- credit risk?
-- =====================================================


SELECT
    "EmploymentType",
    COUNT(DISTINCT "LoanID") AS loan_count,
    ROUND(AVG("CIBIL_Score_Current")::NUMERIC,0) AS avg_current_cibil,
    ROUND(SUM("CurrentBalance")::NUMERIC,2) AS outstanding_balance,
    ROUND(SUM("ECL_Provision")::NUMERIC,2) AS total_ecl,
    ROUND(
        SUM("ECL_Provision")::NUMERIC * 100 /
        SUM("CurrentBalance")::NUMERIC,
        2
    ) AS ecl_percent
FROM auto_loan
GROUP BY "EmploymentType"
HAVING SUM("CurrentBalance") > 0
ORDER BY ecl_percent DESC;

-- Bussiness Insights
-- Employment segments with lower average credit scores 
-- and higher ECL percentages represent comparatively higher
-- portfolio risk. These insights support better credit policy
-- decisions and targeted risk management.


