/* 
==================================
   Q3 – Inactive Accounts Report
==================================

Action Plan
===========

* Objective:
    - Identify accounts (savings or investment) that have been inactive for over a year.
    - Inactivity is defined by no recorded transactions for 365+ days.
    - Group inactivity at the account level, not user level.

* Steps:
1. Fetch the latest transaction time in the database to use as a reference.
2. Calculate the last transaction date per account (plan_id). This is critical because:
    - A user can own multiple accounts.
    - Grouping by owner_id would wrongly aggregate all transactions for all their accounts into one.
3. Join this data with the `plans_plan` table to classify the account type (Savings, Investment, Unknown).
4. Filter for only those accounts that:
    - Are either savings or investment.
    - Have been inactive for over 365 days.
5. Format the output with key fields:
    - `plan_id`, `owner_id`, `type`, `last_transaction_date`, and `inactivity_days`.

* Reasoning:
- Using NOW() for latest transaction time could lead to inflated inactivity periods if the database wasn’t recently updated. 
  Instead, I used the latest transaction date in the dataset to ensure calculations reflect actual data activity, not system time.
- Initially, the query is grouped by `owner_id`, which led to inaccuracies in determining inactivity.
    - This was incorrect because a user might be active on one plan (account) and inactive on another.
    - The correct grouping should be at the account (plan_id) level.
- Additionally, accounts with neither `is_regular_savings` nor `is_a_fund` should be treated as 'Unknown'
  but excluded from the result based on the question's requirement to find only savings or fund accounts.

* Required Tables:
    - savings_savingsaccount
    - plans_plan
    
*/

-- Get the maximum transaction timestamp in the database
WITH max_db_time AS (
    SELECT MAX(transaction_date) AS max_transaction_time 
    FROM savings_savingsaccount
),
-- Get last transaction date per account (not user!)
last_txn_per_acct AS (
    SELECT
        plan_id,
        MAX(transaction_date) AS last_transaction_date
    FROM savings_savingsaccount
    GROUP BY plan_id
)
-- Final join and filter
SELECT
    p.id AS plan_id,
    p.owner_id,
    CASE
        WHEN p.is_regular_savings = 1 THEN 'Savings'
        WHEN p.is_a_fund = 1 THEN 'Investment'
        ELSE 'Unknown'
    END AS type,
    DATE_FORMAT(l.last_transaction_date, '%Y-%m-%d') AS last_transaction_date,
    DATEDIFF(m.max_transaction_time, l.last_transaction_date) AS inactivity_days
FROM plans_plan p
JOIN last_txn_per_acct l ON p.id = l.plan_id
JOIN max_db_time m ON 1=1
WHERE 
    DATEDIFF(m.max_transaction_time, l.last_transaction_date) > 365
    AND (p.is_regular_savings = 1 OR p.is_a_fund = 1)
ORDER BY inactivity_days DESC;



