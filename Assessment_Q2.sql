/* 
 ====================================
 Q2 –  Transaction Frequency Analysis
 ====================================
 * Action Plan
=================

 - For each customer, I will calculate, the ttoal number of transactions.
 - then, calculate their average number of transactions per month.
 - Categorize them based on frequency:
 

 * Reasoning
 ============
 - Initially, I thought dividing total transactions by 30 days would suffice.
 - However, a user might only be active for 1 month and make 200 transactions,
   while another is active for 2 years with 300 transactions.
 - So, calculating transactions per month based on each user’s active duration gives a fair comparison.
 - That’s why it will be better I calculate active months per user based on their first and last transaction.
 
 * Required Tables
 	- users_customuser
	- savings_savingsaccount
	
*/


-- ---- Check if transaction_date and created_on are the same
-- SELECT owner_id, transaction_date, created_on  FROM savings_savingsaccount  LIMIT 10

-- --------- Get total transactions and active months for each user --------------
WITH transaction_per_user AS (
    SELECT 
        owner_id,
        COUNT(*) AS total_transactions,
        TIMESTAMPDIFF(MONTH, MIN(transaction_date ), MAX(transaction_date)) + 1 AS active_months -- added 1 to avoid 0 for a month old users
    FROM savings_savingsaccount
    GROUP BY owner_id
),
-- --------- Compute average transactions per month ------------
average_per_month AS (
    SELECT 
        t.owner_id,
        t.total_transactions,
        t.active_months,
        ROUND(t.total_transactions * 1.0 / t.active_months, 1) AS avg_transactions_per_month
    FROM transaction_per_user AS t
),
-- --------- Categorize based on frequency --------------------
category AS (
    SELECT 
        owner_id,
        total_transactions,
        avg_transactions_per_month,
        CASE 
            WHEN avg_transactions_per_month >= 10 THEN 'High Frequency'
            WHEN avg_transactions_per_month BETWEEN 3 AND 9 THEN 'Medium Frequency'
            ELSE 'Low Frequency'
        END AS frequency_category
    FROM average_per_month
)
-- --------- Final Output ----------
SELECT
	frequency_category,
	total_transactions,
    avg_transactions_per_month
FROM category
ORDER BY avg_transactions_per_month DESC;
