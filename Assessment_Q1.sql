
/*
 ====================================================
 Q1 –  High-Value Customers with Multiple Products
 ====================================================

 Action Plan
 ============

-- Inspect each table and test a subquery to get the necessary data for each table.
-- Joining Aggregated subqueries should  be  better (more efficient) than Joining
-- the 3 tables at once and filtering because of the size of data especially for savings_savingsaccount
SELECT COUNT(*)
FROM savings_savingsaccount  

 * Requied Tables
 	- users_customuser
	- savings_savingsaccount
 	- plans_plan

*/
 
-- ---------Testing Subqueries ---------------------

-- SELECT id, CONCAT(first_name, " ", last_name) AS name
-- FROM users_customuser
-- LIMIT 5

-- SELECT 
--   owner_id,
--   COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN id END) AS savings_count,
--   COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN id END) AS investment_count
-- FROM plans_plan 
-- GROUP BY owner_id
-- HAVING 
--   COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN id END) > 0 
--   AND COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN id END) > 0
-- LIMIT 10;

-- 
-- SELECT  owner_id, SUM(confirmed_amount) AS total_deposits
-- FROM savings_savingsaccount
-- GROUP BY owner_id
-- LIMIT 5


-- ==================== Final Solution =======================

SELECT 
    u.id AS owner_id,
    CONCAT(u.first_name, ' ', u.last_name) AS name,
    p.savings_count,
    p.investment_count,
    ROUND(COALESCE(s.total_deposits, 0), 0) AS total_deposits
FROM users_customuser u
-- Subquery: Get customers with both savings and investment plans
JOIN (
    SELECT 
        owner_id,
        COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN id END) AS savings_count,
        COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN id END) AS investment_count
    FROM plans_plan 
    GROUP BY owner_id
    HAVING 
        COUNT(DISTINCT CASE WHEN is_regular_savings = 1 THEN id END) > 0 
        AND COUNT(DISTINCT CASE WHEN is_a_fund = 1 THEN id END) > 0
) p ON u.id = p.owner_id
-- Subquery: Total deposits from savings account
LEFT JOIN (
    SELECT  
        owner_id, 
        SUM(confirmed_amount) AS total_deposits
    FROM savings_savingsaccount
    GROUP BY owner_id
) s ON u.id = s.owner_id
ORDER BY total_deposits DESC;
