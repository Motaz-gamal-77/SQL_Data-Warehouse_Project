-- CREATING CUSTOMER DIM

CREATE OR ALTER VIEW gold.dim_customer AS 	
SELECT 
	ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_key,
	ci.cst_id AS customer_id, 
	ci.cst_key AS customer_number, 
	ci.cst_firstname AS fist_name, 
	ci.cst_lastname AS last_name, 
	la.cntry AS country,
	ci.cst_marital_status AS marital_status, 
	CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
		 ELSE COALESCE (ca.gen , 'n/a')
	END AS gender,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca
ON  ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 la
ON ci.cst_key = la.cid

GO
-- CREATING PRODUCTS DIM

CREATE OR ALTER VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY  pc.prd_start_dt , pc.prd_key) AS product_key,
	pc.prd_id AS product_id,
	pc.prd_key AS product_number,
	pc.prd_nm AS product_name,
	pc.cat_id AS category_id,
	pe.cat AS category,
	pe.subcat AS subcategory,
	pe.maintenance,
	pc.prd_cost AS cost,
	pc.prd_line AS Product_line,
	pc.prd_start_dt AS start_date
FROM silver.crm_prd_info pc 
LEFT JOIN silver.erp_px_cat_g1v2 pe
ON pc.cat_id = pe.id
WHERE pc.prd_end_dt IS NULL

-- CREATING SALES FACT

CREATE OR ALTER VIEW gold.fact_sales AS 
SELECT 
	sls_ord_num AS order_number,
	pr.product_key AS product_key,
	c.customer_key AS customer_key,
	sls_order_dt AS order_date,
	sls_ship_dt AS ship_date,
	sls_due_dt AS due_date,
	sls_sales AS sales_amount,
	sls_quantity AS quantity,
	sls_price AS price
FROM silver.crm_sales_details sc
LEFT JOIN gold.dim_products pr
ON sc.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer c
ON sc.sls_cust_id = c.customer_id

