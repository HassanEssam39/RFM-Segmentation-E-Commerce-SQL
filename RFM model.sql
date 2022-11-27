WITH cust_category(customerid, recency, frequency, monetary) AS (
SELECT customerid, (SELECT MAX(CAST(invoicedate AS DATE)) FROM online_retail) - MAX(CAST(invoicedate AS DATE)) AS recency,
NTILE(5) OVER(ORDER BY COUNT(invoiceno)) AS frequency, NTILE(5) OVER(ORDER BY SUM(total_price) ) AS monetary
FROM online_retail
GROUP BY customerid),

fm_avg (customerid, r_score, fm_score) AS (
SELECT customerid, NTILE(5) OVER(ORDER BY recency DESC) AS r_score,
(frequency + monetary) /2 AS fm_score
FROM cust_category
),
seg_tab (customerid, rfm_score) AS (
SELECT customerid, /*its required to take the average of fm in the project requirments*/ CONCAT(r_score, fm_score) AS rfm_score
	FROM fm_avg
)

SELECT cc.customerid, recency, frequency, monetary, r_score, fm_score,
    CASE WHEN rfm_score IN ('55', '54', '45') THEN 'Champions'	
	 WHEN rfm_score IN ('52', '42', '33', '43') THEN 'Potential Loyalists'
	 WHEN rfm_score IN ('53', '44', '35', '34') THEN 'Loyal Customers'
	 WHEN rfm_score IN ('51') THEN 'Recent Customers'
	 WHEN rfm_score IN ('41', '31') THEN 'Promising'
	 WHEN rfm_score IN ('32', '23', '22') THEN 'Customers Needing Attention'
	 WHEN rfm_score IN ('25', '24', '13') THEN 'At Risk'
	 WHEN rfm_score IN ('15', '14') THEN 'Cant Lose Them'
	 WHEN rfm_score IN ('12') THEN 'Hibernating'
	 WHEN rfm_score IN ('11') THEN 'Lost'
	 END

FROM cust_category cc
JOIN fm_avg fm
ON cc.customerid = fm.customerid
JOIN seg_tab seg
ON fm.customerid = seg.customerid
ORDER BY customerid;



