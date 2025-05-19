/*
 ==============================================
 Q4: Customer Lifetime Value (CLV) Estimation
 =============================================

Action Plan
===========

-- 1. Use the `users_customuser` table to get the customer ID and full name (first + last).
-- 2. Join with `savings_savingsaccount` to get transaction data (confirmed amounts).
-- 3. Calculate:
--    - Tenure in months: difference between account start date and CURRENT_DATE
--    - Total transactions: count of all confirmed transactions per user
--    - Estimated CLV: (total_transactions / tenure_months) * 12 * avg_profit_per_transaction
--      where avg_profit_per_transaction = AVG(profit_per_transaction) and 
		profit_per_transaction is assumed to be 0.001 * transaction value (amount_confirmed)
-- 4. Group by customer and order by estimated CLV descending.
--
-- Reason for using `amount_confirmed` as the transaction value:
-- `amount_confirmed` represents actual deposit inflows. Since the CLV model assumes
-- profit is made from transaction volumes (e.g. processing fees),
-- using confirmed deposits provides a consistent and meaningful measure of revenue-
-- generating activity. Withdrawals were also excluded due to lack of clarity
-- on whether they contribute to profit.

* Required tables:
  - users_customuser
  - savings_savingsaccount
  
*/

SELECT
    u.id AS customer_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    COALESCE(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date ), NOW()), 0) AS tenure_months, -- COALESCE returns 0 for NULL values
    COUNT(*) AS total_transactions,
    ROUND(
    	(COUNT(*) / COALESCE(TIMESTAMPDIFF(MONTH, MIN(s.transaction_date), NOW()), 1)) * 12 *   -- COALESCE returns 1 for 0 or NULL values
        AVG(0.001 * s.confirmed_amount)
        , 0) AS estimated_clv
FROM
    savings_savingsaccount s
JOIN
    users_customuser u ON s.owner_id = u.id
GROUP BY
    u.id, u.first_name, u.last_name
ORDER BY
    estimated_clv DESC;


