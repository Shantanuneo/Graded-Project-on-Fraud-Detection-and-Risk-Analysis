SELECT * FROM cross_river_bank.customer_table;

#Identify customers with low credit scores and high-risk loans to predict potential defaults and prioritize risk mitigation strategies.
SELECT c.customer_id, c.name, c.credit_score, l.loan_id, l.default_risk FROM cross_river_bank.customer_table as c JOIN cross_river_bank.loan_table as l ON c.customer_id = l.customer_id WHERE c.credit_score < 600 & l.default_risk = 'High' GROUP BY c.customer_id, c.name, c.credit_score, l.loan_id, l.loan_amount, l.default_risk ORDER BY c.credit_score ASC;

#Determine the most popular loan purposes and their associated revenues to align financial products with customer demands
SELECT 
    l.loan_purpose,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_revenue
FROM 
    cross_river_bank.loan_table AS l
WHERE 
    l.loan_status IN ('Approved', 'Closed')
GROUP BY 
    l.loan_purpose
ORDER BY 
    total_loans DESC, 
    total_revenue DESC;
    
#Detect transactions that exceed 30% of their respective loan amounts to flag potential fraudulent activities
SELECT 
    t.transaction_id,
    t.customer_id,
    t.loan_id,
    t.transaction_date,
    t.transaction_amount,
    l.loan_amount,
    (t.transaction_amount / l.loan_amount) * 100 AS transaction_percentage
FROM 
    cross_river_bank.transaction_table AS t
JOIN 
    cross_river_bank.loan_table AS l ON t.loan_id = l.loan_id
WHERE 
    (t.transaction_amount / l.loan_amount) > 0.30
ORDER BY 
    transaction_percentage DESC;
    
#Analyze the number of missed EMIs per loan to identify loans at risk of default and suggest intervention strategies
select l.loan_purpose, count(t.transaction_type) as Missed_emi_totals from cross_river_bank.transaction_table as t join cross_river_bank.loan_table as l on t.loan_id=l.loan_id where t.transaction_type='Missed EMI' group by l.loan_purpose;

SELECT 
    l.loan_id,
    l.customer_id,
    COUNT(t.transaction_id) AS total_missed_emis,
    l.loan_amount,
    l.loan_status,
    c.name AS customer_name,
    c.credit_score
FROM 
    cross_river_bank.transaction_table AS t
JOIN 
    cross_river_bank.loan_table AS l ON t.loan_id = l.loan_id
JOIN 
    cross_river_bank.customer_table AS c ON l.customer_id = c.customer_id
WHERE 
    t.transaction_type = 'EMI Payment'
    AND t.status = 'Failed'
GROUP BY 
    l.loan_id, l.customer_id, l.loan_amount, l.loan_status, c.name, c.credit_score
HAVING 
    total_missed_emis > 0
ORDER BY 
    total_missed_emis DESC;

#•	Regional Loan Distribution: Examine the geographical distribution of loan disbursements to assess regional trends and business opportunities. 

SELECT 
    c.address,
    COUNT(l.loan_id) AS total_loans_disbursed,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(l.loan_amount) AS average_loan_amount
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.customer_table AS c ON l.customer_id = c.customer_id
WHERE 
    l.loan_status IN ('Approved', 'Closed')
GROUP BY 
    c.address
ORDER BY 
    total_loan_amount DESC;
    
#List customers who have been associated with Cross River Bank for over five years and evaluate their loan activity to design loyalty programs.

select c.name, sum(l.loan_amount) , count(l.loan_id) from cross_river_bank.customer_table as c join cross_river_bank.loan_table as l on c.customer_id=l.customer_id where c.customer_since < 19/12/2018 group by c.name;

SELECT 
    c.customer_id,
    c.name,
    c.customer_since,
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(c.customer_since, '%m/%d/%Y'), CURDATE()) AS years_with_bank,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(l.loan_amount) AS average_loan_amount
FROM 
    cross_river_bank.customer_table AS c
LEFT JOIN 
    cross_river_bank.loan_table AS l ON c.customer_id = l.customer_id
WHERE 
    TIMESTAMPDIFF(YEAR, STR_TO_DATE(c.customer_since, '%m/%d/%Y'), CURDATE()) > 5
GROUP BY 
    c.customer_id, c.name, c.customer_since
ORDER BY 
    years_with_bank DESC, total_loan_amount DESC;
    
#Identify loans with excellent repayment histories to refine lending policies and highlight successful products.
SELECT 
    l.loan_id,
    l.loan_purpose,
    sum(l.loan_amount),
    avg(l.repayment_history)
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.customer_table AS c ON l.customer_id = c.customer_id
WHERE 
    l.repayment_history >= 9
    AND l.loan_status = 'Closed'
group by l.loan_purpose, l.loan_id;

#Analyze loan amounts disbursed to customers of different age groups to design targeted financial products.
SELECT 
    CASE 
        WHEN c.age < 25 THEN 'Under 25'
        WHEN c.age BETWEEN 25 AND 34 THEN '25-34'
        WHEN c.age BETWEEN 35 AND 44 THEN '35-44'
        WHEN c.age BETWEEN 45 AND 54 THEN '45-54'
        WHEN c.age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65 and above'
    END AS age_group,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(l.loan_amount) AS average_loan_amount
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.customer_table AS c ON l.customer_id = c.customer_id
GROUP BY 
    age_group
ORDER BY 
    total_loan_amount DESC;
    
#Examine transaction patterns over years and months to identify seasonal trends in loan repayments.
SELECT 
    YEAR(STR_TO_DATE(t.transaction_date, '%m/%d/%Y')) AS transaction_year,
    MONTH(STR_TO_DATE(t.transaction_date, '%m/%d/%Y')) AS transaction_month,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(t.transaction_amount) AS total_transaction_amount,
    AVG(t.transaction_amount) AS average_transaction_amount
FROM 
    cross_river_bank.transaction_table AS t
GROUP BY 
    transaction_year, transaction_month
ORDER BY 
    transaction_year ASC, transaction_month ASC;
    
SELECT 
    t.transaction_id,
    t.customer_id,
    c.address AS customer_address,
    t.ip_location AS transaction_ip_location,
    t.transaction_date,
    t.transaction_amount
FROM 
    `cross_river_bank`.`transaction_table` AS t
JOIN 
    `cross_river_bank`.`customer_table` AS c ON t.customer_id = c.customer_id
WHERE 
    c.address NOT LIKE CONCAT('%', t.ip_location, '%')
ORDER BY 
    t.transaction_date DESC;
    
-- Rank loans by repayment performance using window functions
SELECT 
    l.loan_id,
    l.customer_id,
    l.loan_amount,
    l.repayment_history,
    l.loan_status,
    RANK() OVER (ORDER BY l.repayment_history DESC, l.loan_amount DESC) AS repayment_rank
FROM 
    cross_river_bank.loan_table AS l
WHERE 
    l.loan_status IN ('Closed', 'Approved')
ORDER BY 
    repayment_rank ASC;
    
-- Compare average loan amounts for different credit score ranges
SELECT 
    CASE 
        WHEN c.credit_score < 500 THEN 'Very Poor'
        WHEN c.credit_score BETWEEN 500 AND 599 THEN 'Poor'
        WHEN c.credit_score BETWEEN 600 AND 699 THEN 'Fair'
        WHEN c.credit_score BETWEEN 700 AND 799 THEN 'Good'
        ELSE 'Excellent'
    END AS credit_score_range,
    COUNT(l.loan_id) AS total_loans,
    AVG(l.loan_amount) AS average_loan_amount
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.customer_table AS c ON l.customer_id = c.customer_id
GROUP BY 
    credit_score_range
ORDER BY 
    average_loan_amount DESC;

-- Identify regions with the highest total loan disbursements
SELECT 
    c.address AS region,
    COUNT(l.loan_id) AS total_loans,
    SUM(l.loan_amount) AS total_loan_disbursements,
    AVG(l.loan_amount) AS average_loan_amount
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.customer_table AS c ON l.customer_id = c.customer_id
GROUP BY 
    c.address
ORDER BY 
    total_loan_disbursements DESC;
-- Detect loans with frequent early repayments and their impact on revenue

SELECT 
    l.loan_id,
    l.customer_id,
    l.loan_amount,
    COUNT(t.transaction_id) AS early_repayments_count,
    SUM(t.transaction_amount) AS total_early_repayments,
    (SUM(t.transaction_amount) / l.loan_amount) * 100 AS early_repayment_percentage
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.transaction_table AS t ON l.loan_id = t.loan_id
WHERE 
    t.transaction_type = 'Prepayment'
GROUP BY 
    l.loan_id, l.customer_id, l.loan_amount
HAVING 
    early_repayment_percentage > 10
ORDER BY 
    early_repayments_count DESC, total_early_repayments DESC;

-- Correlate customer feedback sentiment scores with loan statuses
SELECT 
    CASE 
        WHEN t.remarks= 'Late penalty.' THEN 'Late penalty.'
        WHEN t.remarks= 'On-time payment.' THEN 'On-time payment.'
        WHEN t.remarks= 'Partial payment.' THEN 'Partial payment.'
        WHEN t.remarks= 'Payment missed.' THEN 'Payment missed.'
    END AS Feedback_sentiment,
    l.loan_status,
    SUM(l.loan_amount) AS total_loan_amount,
    AVG(l.loan_amount) AS average_loan_amount
FROM 
    cross_river_bank.loan_table AS l
JOIN 
    cross_river_bank.transaction_table AS t ON l.customer_id = t.customer_id
GROUP BY 
    Feedback_sentiment , l.loan_status
ORDER BY 
    total_loan_amount DESC;