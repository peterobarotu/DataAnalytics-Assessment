---
# DataAnalytics-Assessment

This project answers four key questions using SQL, based on customer savings, transactions, and plan data. The goal is to extract meaningful insights that support business decision-making.

---

## Question 1: High-Value Customers with Multiple Products

**Approach:**
I inspected each table and wrote subqueries to extract relevant data. Then, I joined the results to identify users who use both savings and investment products. I also summed their total confirmed deposits to find high-value users.

**Why Subqueries?**
Joining large tables directly would be inefficient. Instead, I used aggregated subqueries for better performance.

**Challenges:**
Initially tried filtering after joining all tables, but this was slow due to the size of the `savings_savingsaccount` table. Switching to subqueries reduced processing time and gave correct results.

---

## Question 2: Transaction Frequency Analysis

**Approach:**
I calculated the total number of transactions and the active duration (in months) for each user. Then, I computed the average number of transactions per month and classified users into three groups:

* High Frequency (≥ 10 per month)
* Medium Frequency (3–9)
* Low Frequency (< 3)

**Reasoning:**
Dividing total transactions by 30 days was misleading. Some users are active for short periods but make many transactions. I used the difference between their first and last transaction dates for a fair monthly average.

**Challenges:**
It was tricky to decide the best way to measure “activity period.” Using the actual transaction date range per user gave better results than using fixed periods.

---

## Question 3: Inactive Accounts Report

**Objective:**
Identify accounts that have been inactive for over a year.

**Approach:**

* Fetched the latest transaction date in the system.
* Found the last transaction date per account (plan\_id).
* Joined with the `plans_plan` table to get account type (Savings or Investment).
* Filtered accounts that haven’t had a transaction in 365+ days.

**Reasoning:**
Grouping by user would combine all their accounts, hiding inactive ones. Instead, I grouped by account ID. Also, using `NOW()` could give over inflated inactivity days if the data wasn’t recently updated. I used the dataset’s latest transaction date instead.

**Challenges:**
At first, I grouped by `owner_id`, which was wrong. One user could have active and inactive accounts. Grouping by `plan_id` fixed this.

---

## Question 4: Customer Lifetime Value (CLV) Estimation

**Approach:**

* Got customer names and IDs from `users_customuser`.
* Joined with transactions in `savings_savingsaccount`.
* Calculated:

  * Tenure (months active)
  * Total transactions
  * Estimated CLV using this formula:
    `(total_transactions / tenure_months) * 12 * avg_profit_per_transaction`,
    where `profit_per_transaction = 0.001 * confirmed_amount`.

**Assumption:**
CLV is based on confirmed deposits since they represent revenue-generating activity. Withdrawals were excluded due to lack of profit clarity.

**Challenges:**
Tenure values could be zero for recent users, so I used `COALESCE` to avoid division by zero. Also, defining a standard formula for profit estimation required a clear assumption.

---

**Summary:**
This analysis used structured SQL queries with subqueries, groupings, and joins to get insights into customer behavior. Each solution focused on accuracy, efficiency, and real-world business use.

---
