CREATE VIEW AAA_inbound_GI_current_month AS
SELECT
shop_code as mã_shop,
shop_name as tên_shop,
brand_name as nhãn,
region as khu_vực,
box_qty as số_thùng,
NULLIF(input_standard, 0) as D111,
NULLIF(input_taras_defect, 0) as D116,
NULLIF(input_paper_bag, 0) as túi_giấy,
NULLIF(input_visual_merchandising, 0) as VMR,
input_type as Loại,
status,
good_issue_date as GI_date,
arrival_date as Upload,
good_receipt_date as GR_date,
note
FROM inbound i2
WHERE strftime('%Y-%m', good_issue_date) = strftime('%Y-%m', 'now');

CREATE VIEW AAA_inbound_last_gr_date AS
SELECT
i.shop_code,
i.shop_name,
i.brand_name,
region,
box_qty,
NULLIF(input_standard, 0) as D111,
NULLIF(input_taras_defect, 0) as D116,
NULLIF(input_paper_bag, 0) as túi_giấy,
NULLIF(input_visual_merchandising, 0) as VMR,
input_type,
purchase_order_num,
delivery_order_num,
good_issue_date,
transfer_order_num,
put_away_bin,
transfer_order_quality_issue,
substandard_qty,
arrival_date,
good_receipt_date,
note
FROM inbound i
LEFT JOIN shop s ON i.shop_code = s.shop_code
WHERE good_receipt_date =
    (SELECT MAX(good_receipt_date)
     FROM inbound i2);

CREATE VIEW AAA_outbound_last_post_date AS
SELECT
    o.post_date,
    o.order_date,
    o.delivery_date,
    o.brand_name,
    o.region,
    o.shop_code,
    o.shop_name,
    NULLIF(o.product_qty, 0) as hàng_hóa,
	NULLIF(o.paper_bag_qty, 0) as túi_giấy,
    o.stock_transfer_order_num,
    o.delivery_order_num,
    o.note,
    o.box_qty,
    o.order_qty
FROM outbound o
WHERE o.post_date = (
    SELECT MAX(post_date)
    FROM outbound
)
ORDER BY shop_code ASC;

CREATE VIEW AAA_daily_inbound_summary AS
SELECT 
    MAX(i.good_receipt_date) AS date,
    b.brand_name AS brand,
    SUM(i.input_standard + i.input_visual_merchandising) AS D111,
    SUM(i.input_taras_defect) AS D116,
    SUM(i.input_paper_bag) AS paperbag
FROM inbound i
LEFT JOIN shop s ON i.shop_code = s.shop_code
LEFT JOIN brand b ON s.brand = b.brand_code
WHERE i.good_receipt_date = (
    SELECT MAX(good_receipt_date)
    FROM inbound
)
GROUP BY b.brand_name, s.brand;

CREATE VIEW AAA_daily_outbound_summary AS
SELECT 
    MAX(o.post_date) AS date,
    b.brand_name AS brand,
    SUM(CASE WHEN o.main_vendor = 'D111' THEN o.product_qty ELSE 0 END) AS D111,
    SUM(CASE WHEN o.main_vendor = 'D116' THEN o.product_qty ELSE 0 END) AS D116,
    SUM(o.paper_bag_qty) AS paperbag
FROM outbound o
LEFT JOIN shop s ON o.shop_code = s.shop_code
LEFT JOIN brand b ON s.brand = b.brand_code
WHERE o.post_date = (
    SELECT MAX(post_date)
    FROM outbound
)
GROUP BY b.brand_name, s.brand;

CREATE VIEW AAA_outbound_post_null AS
SELECT
id,
post_date as ngày_post,
delivery_date as ngày_yêu_cầu_giao,
main_vendor as kho_xuất,
brand_name as nhãn,
region as khu_vực,
shop_code as mã_shop,
shop_name as tên_shop,
order_qty as số_lượng,
delivery_order_num as số_DO,
note
FROM outbound
WHERE post_date is null and main_vendor = 'D111'
ORDER BY shop_code;

CREATE VIEW AAA_cont_job AS
SELECT
id,
arrival_date as Arrival_date,
input_type as Loại,
note as tên_job,
brand_name as nhãn,
box_qty as số_thùng,
NULLIF(input_standard, 0) as D111,
NULLIF(input_paper_bag, 0) as túi_giấy,
NULLIF(input_visual_merchandising, 0) as VMR,
purchase_order_num as PO,
NULLIF(delivery_order_num, '-') as số_Post,
good_issue_date as GI_date,
substandard_qty as QI_Qty,
current_action as action,
good_receipt_date as GR_date
FROM inbound
WHERE region = 'CONT'
  AND note IN (
    SELECT note
    FROM inbound
    WHERE region = 'CONT'
    GROUP BY note
    ORDER BY MAX(arrival_date) DESC
  )
ORDER BY arrival_date DESC, id;

CREATE VIEW AAA_outbound_DO_byday AS
SELECT 
	delivery_date as ngày_yêu_cầu_giao,
	brand_name as nhãn,
	shop_code as mã_shop,
    shop_name as tên_shop,
    region as vùng,
    delivery_order_num as số_DO,
    NULLIF(product_qty, 0) as hàng_hóa,
	NULLIF(paper_bag_qty, 0) as túi_giấy
FROM outbound
WHERE post_date = '2025-06-24'
GROUP BY shop_code;

CREATE VIEW AAA_outbound_deli_today AS
SELECT
	id,
	delivery_date,
	post_date,
    CASE
    WHEN post_date IS NOT NULL THEN 'posted'
    ELSE 'post null'
    END AS "check",
	checklist,
	brand_name,
	shop_code,
    shop_name,
    region,
    stock_transfer_order_num as PO_num,
    delivery_order_num as DO_num,
    note as type,
    box_qty,
    NULLIF(product_qty, 0) as product_qty,
	NULLIF(paper_bag_qty, 0) as paper_qty,
    order_qty
    FROM outbound
	WHERE delivery_date = date('now')
	ORDER BY shop_code ASC;

CREATE VIEW AAA_inbound_pending AS
SELECT
shop_code,
shop_name,
brand_name,
region,
box_qty as box,
NULLIF(input_standard, 0) as product_qty,
NULLIF(input_taras_defect, 0) as taras_qty,
NULLIF(input_paper_bag, 0) as paper_qty,
NULLIF(input_visual_merchandising, 0) as vm_qty,
input_type,
status,
delivery_order_num as DO_num,
good_issue_date as GI_date,
arrival_date,
good_receipt_date as GR_date,
note
FROM inbound
WHERE good_receipt_date is null AND region <> "CONT";

CREATE VIEW AAA_inbound_today AS
SELECT
shop_code as mã_shop,
shop_name as tên_shop,
box_qty as số_thùng,
NULLIF(input_standard, 0) as D111,
NULLIF(input_taras_defect, 0) as D116,
NULLIF(input_paper_bag, 0) as túi_giấy,
NULLIF(input_visual_merchandising, 0) as VMR,
input_type as Loại,
purchase_order_num as số_PO,
delivery_order_num as số_DO,
arrival_date as Upload,
good_receipt_date as GR_date,
note
FROM inbound
WHERE good_receipt_date = date('now');

CREATE VIEW AAA_outbound_defect_taras AS
SELECT
id,
post_date as post,
main_vendor as sup,
order_date,
delivery_date,
shop_code as site,
box_qty as thùng,
product_qty as SL,
stock_transfer_order_num as PO,
delivery_order_num as DOs,
transfer_order_num as TOs,
note
FROM outbound
WHERE note LIKE '%defect%' AND post_date IS NULL
ORDER BY id DESC
LIMIT 10;

CREATE VIEW AAA_ob_deli_today_include_multi AS
SELECT 
delivery_date AS ngày_yêu_cầu_giao,
brand_name AS nhãn,
CASE 
WHEN o.shop_code = '4000' THEN s.shop_code 
ELSE o.shop_code 
END AS mã_shop,
CASE 
WHEN o.shop_code = '4000' THEN s.shop_name 
ELSE o.shop_name 
END AS tên_shop,
o.region AS vùng,
o.stock_transfer_order_num AS số_PO,
o.delivery_order_num AS số_DO,
o.note,
o.box_qty,
NULLIF(o.product_qty, 0) AS hàng_hóa,
NULLIF(o.paper_bag_qty, 0) AS túi_giấy,
o.order_qty AS SL_order
FROM outbound o
LEFT JOIN shop s ON o.shop_code = '4000' AND o.note = s.shop_code
WHERE o.delivery_date = date('now')
ORDER BY mã_shop ASC;

CREATE VIEW AAA_ob_deli_today_include_multi_ck_pd AS
SELECT 
o.delivery_date AS ngày_yêu_cầu_giao,
o.brand_name AS nhãn,
CASE 
WHEN o.shop_code IN ('4000', '1000', '1100') THEN s.shop_code 
ELSE o.shop_code 
END AS mã_shop,
CASE 
WHEN o.shop_code IN ('4000', '1000', '1100') THEN s.shop_name 
ELSE o.shop_name 
END AS tên_shop,
o.stock_transfer_order_num AS số_PO,
o.delivery_order_num AS số_DO,
CASE 
WHEN o.shop_code IN ('4000', '1000', '1100') THEN o.shop_code
ELSE o.note
END AS note,
o.box_qty,
NULLIF(o.product_qty, 0) AS hàng_hóa,
NULLIF(o.paper_bag_qty, 0) AS túi_giấy,
o.order_qty AS SL_order
FROM outbound o
LEFT JOIN shop s 
ON o.shop_code IN ('4000', '1000', '1100') AND o.note = s.shop_code
WHERE o.delivery_date = DATE('now')
ORDER BY mã_shop ASC;

CREATE VIEW AAA_outbound_pending  AS
SELECT *
FROM outbound
WHERE product_qty = 0
  AND paper_bag_qty = 0
  AND delivery_date >= DATE('now', '-3 days');

CREATE VIEW vw_NXT_cyclecount_last_month AS
SELECT
*
FROM cyclecount
WHERE document_date >= date('now', 'start of month', '-1 month')
  AND document_date < date('now', 'start of month');

CREATE VIEW vw_NXT_stocktaking_last_month AS
SELECT
*
FROM stocktaking
WHERE document_date >= date('now', 'start of month', '-1 month')
  AND document_date < date('now', 'start of month');

CREATE VIEW vw_report_outbound_last_month AS
SELECT
post_date as ngày_post,
main_vendor as site_xuất,
brand_name as nhãn,
shop_name as tên_shop,
product_qty as hàng_hóa,
paper_bag_qty as túi_giấy,
note,
order_qty,
note2
FROM outbound
WHERE post_date >= date('now', 'start of month', '-1 month')
  AND post_date < date('now', 'start of month');

CREATE VIEW vw_NXT_total_outbound_tiki AS
SELECT
strftime('%Y-%m', post_date) AS year_month,
brand_name,
SUM(product_qty + paper_bag_qty) AS total_outbound
FROM outbound
WHERE post_date IS NOT NULL AND shop_code LIKE '%99M2%'
GROUP BY year_month, brand_name
ORDER BY year_month, brand_name;

CREATE VIEW vw_report_defect_aggregation_by_ref AS
SELECT 
    i.style_code,
    m.material,
    d.defect_type,
    COUNT(*) AS issue_count
FROM 
    defect d
JOIN 
    item_list i	 ON d.barcode = i.barcode
JOIN 
    item_material m ON d.barcode = m.barcode
GROUP BY 
    i.style_code, m.material, d.defect_type 
ORDER BY 
    issue_count DESC;

CREATE VIEW vw_report_inbound_aggregation_by_brand AS
SELECT
    brand_name,
    SUM(input_standard) AS total_input_standard,
    ROUND(AVG(input_standard), 2) AS avg_input_standard
FROM inbound
WHERE input_standard IS NOT NULL
GROUP BY brand_name
ORDER BY total_input_standard DESC;

CREATE VIEW vw_report_inbound_CONT_percent_of_total AS
SELECT
    shop_code,
    input_standard  AS total_scan,
    ROUND((input_standard  * 100) / SUM(input_standard ) OVER (), 0) AS percent_of_total
FROM 
    inbound
WHERE 
    shop_code LIKE '%CONT%'
GROUP BY shop_code;

CREATE VIEW vw_report_defect_rate_by_shop AS
SELECT
    i.shop_name,
    b.brand_name AS brand,
    p.province_name,
    COALESCE(SUM(d.defect_qty), 0) AS total_defect_qty,
    COALESCE(SUM(i.input_standard), 0) AS total_received_qty,
    ROUND(100.0 * SUM(d.defect_qty) / NULLIF(SUM(i.input_standard), 0), 3) AS defect_rate
FROM defect d
INNER JOIN inbound i ON d.purchase_order_num = i.purchase_order_num
INNER JOIN shop s ON i.shop_code = s.shop_code
INNER JOIN brand b ON s.brand = b.brand_code
INNER JOIN province p ON s.province_id = p.id
WHERE p.region != 'CONT'
  AND i.shop_name NOT IN ('KHO D111', 'ECOM QUẬN 8', 'KHO ECOM THỦ ĐỨC')
GROUP BY i.shop_name, b.brand_name, p.province_name
HAVING defect_rate IS NOT NULL;

CREATE VIEW vw_report_inbound_aggregation AS
SELECT
  brand_name,
  COUNT(*) AS total_rows,
  COUNT(CASE WHEN input_standard > 10 THEN 1 END) AS over_10_input,
  COUNT(CASE WHEN status = 'complete' THEN 1 END) AS complete_status_count,
  COUNT(CASE WHEN input_standard BETWEEN 5 AND 10 THEN 1 END) AS mid_input,
  COUNT(CASE WHEN good_receipt_date IS NOT NULL THEN 1 END) AS with_gr_date
FROM inbound
GROUP BY brand_name;

CREATE VIEW vw_report_outbound_disparity_last_month AS
SELECT
post_date,
brand_name,
shop_code,
product_qty,
paper_bag_qty,
order_qty,
       (COALESCE(product_qty, 0) + COALESCE(paper_bag_qty, 0) - COALESCE(order_qty, 0)) AS disparity,
note
FROM outbound
WHERE strftime('%Y-%m', post_date) = strftime('%Y-%m', DATE('now', '-1 month'))
  AND COALESCE(product_qty, 0) + COALESCE(paper_bag_qty, 0) <> COALESCE(order_qty, 0) AND note != 'chênh lệch pullback';

CREATE VIEW vw_report_outbound_disparity_percent_last_month AS
WITH monthly_totals AS (
    SELECT 
        brand_name,
        SUM(COALESCE(product_qty, 0) + COALESCE(paper_bag_qty, 0)) AS total_product_paper
    FROM outbound
    WHERE strftime('%Y-%m', post_date) = strftime('%Y-%m', DATE('now', '-1 month'))
    GROUP BY brand_name
),
disparity_totals AS (
    SELECT 
        brand_name,
        SUM(COALESCE(product_qty, 0) + COALESCE(paper_bag_qty, 0) - COALESCE(order_qty, 0)) AS total_disparity
    FROM outbound
    WHERE strftime('%Y-%m', post_date) = strftime('%Y-%m', DATE('now', '-1 month'))
      AND COALESCE(product_qty, 0) + COALESCE(paper_bag_qty, 0) <> COALESCE(order_qty, 0) AND note != 'chênh lệch pullback'
    GROUP BY brand_name
)
SELECT 
    m.brand_name,
    m.total_product_paper,
    COALESCE(d.total_disparity, 0) AS total_disparity,
    ROUND(
        100.0 * COALESCE(d.total_disparity, 0) / NULLIF(m.total_product_paper, 0),
        2
    ) AS disparity_percent
FROM monthly_totals m
LEFT JOIN disparity_totals d ON m.brand_name = d.brand_name
ORDER BY m.brand_name;

CREATE VIEW vw_report_daily_diff_in_out_last_date2 AS
SELECT 
    brand,
    MAX(date) AS date,
    SUM(D111_in - D111_out) AS D111_balance,
    SUM(D116_in - D116_out) AS D116_balance,
    SUM(paperbag_in - paperbag_out) AS paperbag_balance
FROM (
    SELECT 
        i.good_receipt_date AS date, 
        b.brand_name AS brand, 
        SUM(i.input_standard + i.input_visual_merchandising) AS D111_in,
        0 AS D111_out,
        SUM(i.input_taras_defect) AS D116_in, 
        0 AS D116_out,
        SUM(i.input_paper_bag) AS paperbag_in,
        0 AS paperbag_out
    FROM inbound i
    LEFT JOIN shop s ON i.shop_code = s.shop_code
    LEFT JOIN brand b ON s.brand = b.brand_code
    WHERE i.good_receipt_date = (SELECT MAX(good_receipt_date) FROM inbound)
    GROUP BY b.brand_name
    UNION ALL
    SELECT 
        o.post_date AS date, 
        b.brand_name AS brand, 
        0 AS D111_in,
        SUM(CASE WHEN o.main_vendor = 'D111' THEN o.product_qty ELSE 0 END) AS D111_out,
        0 AS D116_in,
        SUM(CASE WHEN o.main_vendor = 'D116' THEN o.product_qty ELSE 0 END) AS D116_out,
        0 AS paperbag_in,
        SUM(o.paper_bag_qty) AS paperbag_out
    FROM outbound o
    LEFT JOIN shop s ON o.shop_code = s.shop_code
    LEFT JOIN brand b ON s.brand = b.brand_code
    WHERE o.post_date = (SELECT MAX(post_date) FROM outbound)
    GROUP BY b.brand_name
) AS combined
GROUP BY brand;

CREATE VIEW vw_report_inbound_last5dayGI AS
SELECT delivery_order_num as DO_num
FROM inbound
WHERE DATE(good_issue_date) >= DATE('now', '-5 days')
  AND region <> 'CONT';

CREATE VIEW vw_NXT_job_last_month AS
SELECT
id,
note as tên_job,
brand_name as nhãn,
box_qty as số_thùng,
NULLIF(input_standard, 0) as D111,
NULLIF(input_paper_bag, 0) as túi_giấy,
NULLIF(input_visual_merchandising, 0) as VMR,
input_type as Loại,
purchase_order_num as PO,
delivery_order_num as số_post,
good_issue_date as GI_date,
NULLIF(substandard_qty, 0) as QI_Qty,
arrival_date as Arrival_date,
good_receipt_date as GR_date
FROM inbound
WHERE region = 'CONT'
  AND good_issue_date >= date('now', 'start of month', '-1 month')
  AND good_issue_date < date('now', 'start of month');

CREATE VIEW vw_NXT_last_month_outbound_summary AS
WITH outbound_summary AS (
SELECT
    brand_name,
    SUM(CASE WHEN main_vendor = 'D111' THEN product_qty ELSE 0 END) AS D111,
    SUM(CASE WHEN main_vendor = 'D116' THEN product_qty ELSE 0 END) AS D116,
    SUM(paper_bag_qty) AS paperbag,
    SUM(CASE WHEN main_vendor = 'D111' THEN product_qty ELSE 0 END) +
    SUM(CASE WHEN main_vendor = 'D116' THEN product_qty ELSE 0 END) +
    SUM(paper_bag_qty) AS total
FROM outbound
WHERE strftime('%Y-%m', post_date) = strftime('%Y-%m', DATE('now', 'start of month', '-1 month'))
GROUP BY brand_name
)
SELECT * FROM outbound_summary
UNION ALL
SELECT
    'TOTAL',
    SUM(D111),
    SUM(D116),
    SUM(paperbag),
    SUM(total)
FROM outbound_summary;

CREATE VIEW vw_NXT_last_month_inbound_cont_only AS
WITH inbound_raw AS (
    SELECT
        region,
        brand_name,
        input_standard,
        input_visual_merchandising,
        input_taras_defect,
        input_paper_bag
    FROM inbound
    WHERE strftime('%Y-%m', good_issue_date) = strftime('%Y-%m', DATE('now', 'start of month', '-1 month'))
),
inbound_summary AS (
    SELECT
        brand_name,
        -- CONT region
        SUM(CASE WHEN region = 'CONT' THEN input_standard ELSE 0 END) AS CONT_standard,
        SUM(CASE WHEN region = 'CONT' THEN input_visual_merchandising ELSE 0 END) AS CONT_visual,
        SUM(CASE WHEN region = 'CONT' THEN input_paper_bag ELSE 0 END) AS CONT_paperbag
    FROM inbound_raw
    GROUP BY brand_name
)
SELECT * 
FROM inbound_summary
UNION ALL
SELECT
    'TOTAL' AS brand_name,
    SUM(CONT_standard) AS CONT_standard,
    SUM(CONT_visual) AS CONT_visual,
    SUM(CONT_paperbag) AS CONT_paperbag
FROM inbound_summary;

CREATE VIEW vw_NXT_last_month_inbound_summary AS
SELECT
        brand_name,
        SUM(CASE WHEN region != 'CONT' THEN input_standard ELSE 0 END) AS D111_standard,
        SUM(CASE WHEN region != 'CONT' THEN input_visual_merchandising ELSE 0 END) AS D111_visual,
        SUM(CASE WHEN region != 'CONT' THEN input_taras_defect ELSE 0 END) AS D116,
        SUM(CASE WHEN region != 'CONT' THEN input_paper_bag ELSE 0 END) AS D111_paperbag,
        SUM(input_standard + input_visual_merchandising + input_taras_defect + input_paper_bag) AS total
FROM inbound
WHERE strftime('%Y-%m', good_issue_date) = strftime('%Y-%m', DATE('now', 'start of month', '-1 month')) AND region != 'CONT'
GROUP BY brand_name

CREATE VIEW vw_NXT_multi_4000_last_month AS
SELECT
post_date,
product_qty,
paper_bag_qty,
stock_transfer_order_num
FROM outbound
WHERE /*shop_code = '4000'*/ brand_name = 'MULTI'
  AND strftime('%Y-%m', post_date) = strftime('%Y-%m', DATE('now', 'start of month', '-1 month'));

CREATE VIEW PBI_inbound_custom AS
SELECT
    i.good_receipt_date AS date,
    i.brand_name,
    i.region,
    'normal' AS type,
    SUM(i.input_standard) AS qty,
    'inbound' AS direction
FROM inbound i
WHERE i.status = 'complete'
GROUP BY i.good_receipt_date, i.brand_name, i.region
HAVING SUM(i.input_standard) <> 0
UNION ALL
SELECT
    i.good_receipt_date AS date,
    i.brand_name,
    i.region,
    'defect' AS type,
    SUM(i.input_taras_defect) AS qty,
    'inbound' AS direction
FROM inbound i
WHERE i.status = 'complete'
GROUP BY i.good_receipt_date, i.brand_name, i.region
HAVING SUM(i.input_taras_defect) <> 0
UNION ALL
SELECT
    i.good_receipt_date AS date,
    i.brand_name,
    i.region,
    'paper_bag' AS type,
    SUM(i.input_paper_bag) AS qty,
    'inbound' AS direction
FROM inbound i
WHERE i.status = 'complete'
GROUP BY i.good_receipt_date, i.brand_name, i.region
HAVING SUM(i.input_paper_bag) <> 0;

CREATE VIEW PBI_outbound_custom AS
SELECT
    post_date AS date,
    brand_name,
    region,
    'normal' AS type,
    SUM(product_qty) AS qty,
    'outbound' AS direction
FROM outbound
WHERE post_date IS NOT NULL AND main_vendor = 'D111'
GROUP BY post_date, brand_name, region
HAVING SUM(product_qty) <> 0
UNION ALL
SELECT
    post_date AS date,
    brand_name,
    region,
    'paper_bag' AS type,
    SUM(paper_bag_qty) AS qty,
    'outbound' AS direction
FROM outbound
WHERE post_date IS NOT NULL AND main_vendor = 'D111'
GROUP BY post_date, brand_name, region
HAVING SUM(paper_bag_qty) <> 0
UNION ALL
SELECT
    post_date AS date,
    brand_name,
    region,
    'defect' AS type,
    SUM(product_qty) AS qty,
    'outbound' AS direction
FROM outbound
WHERE post_date IS NOT NULL AND main_vendor = 'D116'
GROUP BY post_date, brand_name, region
HAVING SUM(product_qty) <> 0;

CREATE VIEW PBI_inout_custom AS
SELECT * FROM PBI_inbound_custom
UNION ALL
SELECT * FROM PBI_outbound_custom;

CREATE VIEW vw_visual_asset_stock_in_hand AS
SELECT
    item_name,
    SUM(CASE WHEN status = 'inbound' THEN quantity ELSE 0 END) AS total_inbound,
    SUM(CASE WHEN status = 'outbound' THEN quantity ELSE 0 END) AS total_outbound,
    SUM(CASE WHEN status = 'inbound' THEN quantity ELSE 0 END)
      - SUM(CASE WHEN status = 'outbound' THEN quantity ELSE 0 END) AS stock_in_hand
FROM visual_asset
GROUP BY item_name
HAVING 
    SUM(CASE WHEN status = 'inbound' THEN quantity ELSE 0 END)
    - SUM(CASE WHEN status = 'outbound' THEN quantity ELSE 0 END) > 0;

CREATE VIEW data_tool_outbound_deli_today AS
SELECT 
    o.shop_code,
    o.shop_name,
    o.delivery_order_num as do_num,
    o.note,
    o.box_qty,
    g.groupx
FROM outbound AS o
LEFT JOIN outbound_groupx AS g
    ON o.shop_code = g.shop_code
WHERE o.delivery_date = DATE('now')
ORDER BY g.groupx, o.shop_name ASC;

CREATE VIEW data_tool_pullback_today AS
SELECT 
  p.to_shop as shop_code,
  s.shop_name,
  '-' as do_num,
  'zLCNB' AS note,
  SUM(p.box_qty) AS box_qty,
  g.groupx
FROM pullback AS p
LEFT JOIN outbound_groupx AS g
  ON p.to_shop = g.shop_code
LEFT JOIN shop AS s
  ON p.to_shop = s.shop_code
WHERE p.pullback_date = DATE('now')
  AND p.to_shop NOT LIKE '%D111%'
  AND p.to_shop NOT LIKE '%D116%'
GROUP BY p.to_shop, s.shop_name, g.groupx
ORDER BY g.groupx, p.to_shop, s.shop_name ASC;

CREATE VIEW data_tool_outbound_include_today AS
SELECT 
i.shop_code,
s.shop_name,
i.note as do_num,
i.item_name AS note,
i.box_qty as box_qty,
g.groupx
FROM outbound_include as i
LEFT JOIN outbound_groupx AS g
  ON i.shop_code = g.shop_code
LEFT JOIN shop AS s
  ON i.shop_code = s.shop_code
WHERE i.dely_date = DATE('now')
ORDER BY g.groupx, i.shop_code, s.shop_name ASC;

CREATE VIEW data_tool_inbound_online AS
SELECT
CASE 
    WHEN brand_name = 'Charles & Keith' THEN 'CK'
    ELSE brand_name
END AS brand,
shop_name AS name,
box_qty AS box,
input_standard AS product,
input_taras_defect AS taras,
input_paper_bag AS paper,
input_visual_merchandising AS vmr,
input_type AS Loai,
arrival_date,
inbound_code
FROM inbound
WHERE current_action IS NULL AND region <> 'CONT'
ORDER BY arrival_date;

CREATE VIEW AAA_timeline_cont AS
WITH grouped AS (
    SELECT
        note,
        strftime('%Y', good_receipt_date) AS yr,
        SUM(input_standard) AS qty_sum
    FROM inbound_new
    WHERE region = 'CONT'
    GROUP BY note, yr
),
base AS (
    SELECT
        i.*,
        g.qty_sum,

        CAST(
            julianday(i.good_receipt_date) -
            julianday(i.arrival_date)
            AS REAL
        ) AS ngay_xu_ly,

        CASE
            WHEN g.qty_sum < 12000 THEN 3
            ELSE 3 +
                (
                    CAST(
                        (g.qty_sum - 12000 + 4999) / 5000
                        AS INTEGER
                    ) * 1.5
                )
        END AS sla_days
    FROM inbound_new i
    JOIN grouped g
        ON i.note = g.note
       AND strftime('%Y', i.good_receipt_date) = g.yr
    WHERE i.region = 'CONT'
),
sunday_check AS (
    SELECT
        b.*,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM date_tb d
                WHERE d.Date BETWEEN b.arrival_date
                                 AND date(
                                     b.arrival_date,
                                     '+' || CAST(b.sla_days AS INTEGER) || ' day'
                                 )
                  AND d.Day_Of_Week_Number = 7
            )
            THEN 1
            ELSE 0
        END AS sunday_bonus
    FROM base b
)
SELECT
    *,
    sla_days + sunday_bonus AS sla_final,
    CASE
        WHEN ngay_xu_ly <= sla_days + sunday_bonus
            THEN 'dat'
        ELSE 'khong_dat'
    END AS sla_status
FROM sunday_check;

CREATE VIEW AAA_CONT_summary_month AS
SELECT
    strftime('%Y-%m', good_receipt_date) AS year_month,
    SUM(CASE WHEN sla_status = 'dat' THEN 1 ELSE 0 END) AS dat_count,
    SUM(CASE WHEN sla_status = 'khong_dat' THEN 1 ELSE 0 END) AS khong_dat_count,
    COUNT(*) AS total
FROM AAA_timeline_cont
GROUP BY strftime('%Y-%m', good_receipt_date)
ORDER BY year_month;

CREATE VIEW LUC666 AS
SELECT *
FROM (
    SELECT *
    FROM outbound
    ORDER BY id DESC
    LIMIT 300
) t
ORDER BY id ASC;

CREATE VIEW AAA_BOX_OUTBOUND AS
SELECT 
    o.shop_code,
    o.shop_name,
    o.region,
    SUM(o.order_qty) AS total_order_qty,
    SUM(o.box_qty) AS total_box_qty,
    SUM(CASE WHEN o.box_qty = 0 THEN 1 ELSE 0 END) AS pending_rows,
    IFNULL(pb.pullback_box_qty, 0) AS pullback_box_qty,
    SUM(o.box_qty) + IFNULL(pb.pullback_box_qty, 0)  AS total_box
FROM outbound o
LEFT JOIN (
    SELECT 
        to_shop,
        SUM(box_qty) AS pullback_box_qty
    FROM pullback
    WHERE pullback_date = DATE('now')
    GROUP BY to_shop
) pb
    ON pb.to_shop = o.shop_code
WHERE o.delivery_date = DATE('now')
  AND o.paper_bag_qty = 0
GROUP BY o.shop_code, o.shop_name;

CREATE VIEW AAA_outbound_DONULL  AS
SELECT *
FROM outbound
WHERE delivery_order_num = '-';

CREATE VIEW AAA_PULLBACK_summary_month_1 AS
SELECT
    v.month,
    SUM(CASE WHEN v.timeline_status = 'dat' THEN 1 ELSE 0 END) AS dat_count,
    SUM(CASE WHEN v.timeline_status = 'khong_dat' THEN 1 ELSE 0 END) AS khong_dat_count,
    COUNT(*) AS total_records,
    SUM(v.input_standard) AS hang_hoa,
    SUM(v.input_paper_bag) AS tui_giay
FROM AAA_timeline_pullback_1 v
GROUP BY v.month;

CREATE VIEW AAA_timeline_cont AS
WITH grouped AS (
    SELECT
        note,
        strftime('%Y', good_receipt_date) AS yr,
        SUM(input_standard) AS qty_sum
    FROM inbound_new
    WHERE region = 'CONT'
    GROUP BY note, yr
),
base AS (
    SELECT
        i.*,
        g.qty_sum,

        CAST(
            julianday(i.good_receipt_date) -
            julianday(i.arrival_date)
            AS REAL
        ) AS ngay_xu_ly,

        CASE
            WHEN g.qty_sum < 12000 THEN 3
            ELSE 3 +
                (
                    CAST(
                        (g.qty_sum - 12000 + 4999) / 5000
                        AS INTEGER
                    ) * 1.5
                )
        END AS sla_days
    FROM inbound_new i
    JOIN grouped g
        ON i.note = g.note
       AND strftime('%Y', i.good_receipt_date) = g.yr
    WHERE i.region = 'CONT'
),
sunday_check AS (
    SELECT
        b.*,
        CASE
            WHEN EXISTS (
                SELECT 1
                FROM date_tb d
                WHERE d.Date BETWEEN b.arrival_date
                                 AND date(
                                     b.arrival_date,
                                     '+' || CAST(b.sla_days AS INTEGER) || ' day'
                                 )
                  AND d.Day_Of_Week_Number = 7
            )
            THEN 1
            ELSE 0
        END AS sunday_bonus
    FROM base b
)
SELECT
    *,
    sla_days + sunday_bonus AS sla_final,
    CASE
        WHEN ngay_xu_ly <= sla_days + sunday_bonus
            THEN 'dat'
        ELSE 'khong_dat'
    END AS sla_status
FROM sunday_check;

CREATE VIEW AAA_timeline_pullback_1 AS
SELECT
    i.shop_name,
    i.box_qty || '-' || 
    i.input_standard || '-' || 
    i.input_taras_defect || '-' || 
    i.input_paper_bag
    AS box_hh_taras_tg,
    i.input_standard,
    i.input_paper_bag,
    CAST(
        julianday(date(i.good_receipt_date)) 
        - julianday(date(i.arrival_date))
        AS INTEGER
    ) AS so_ngay_xu_ly,
    i.delivery_order_num AS DO_num,
    i.good_issue_date || '>' ||
    i.arrival_date || '>' ||
    i.good_receipt_date
    AS process_date,
    strftime('%Y-%m', i.good_issue_date) AS month,
    CASE
        WHEN i.arrival_date IS NULL 
          OR i.good_receipt_date IS NULL
            THEN NULL
        WHEN julianday(date(i.good_receipt_date)) >
             julianday(
                CASE
                    WHEN d.Day_Of_Week_Number = 7
                        THEN date(i.arrival_date, '+8 day')
                    ELSE date(i.arrival_date, '+7 day')
                END
             )
            THEN 'khong_dat'
        ELSE 'dat'
    END AS timeline_status
FROM inbound i
LEFT JOIN date_tb d
    ON d.Date = date(i.arrival_date, '+7 day')
WHERE i.region <> 'CONT';

--------------

CREATE VIEW soh_by_kind AS
SELECT 
    s.date,
    s.site,
    ik.kind,
    SUM(s.qty) AS total_qty
FROM soh s
LEFT JOIN item_list il 
    ON s.barcode = il.barcode
LEFT JOIN item_type it 
    ON il.type = it.type
LEFT JOIN item_kind ik 
    ON it.type = ik.type
GROUP BY 
    s.date,
    s.site,
    ik.kind;

CREATE VIEW soh_by_type AS
SELECT 
    s.date,
    s.site,
    it.type,
    SUM(s.qty) AS total_qty
FROM soh s
LEFT JOIN item_list il 
    ON s.barcode = il.barcode
LEFT JOIN item_type it 
    ON il.type = it.type
GROUP BY 
    s.date,
    s.site,
    it.type;

CREATE VIEW soh_missing_barcodes AS
SELECT 
    s.barcode,
    s.date,
    s.site,
    s.qty
FROM soh s
LEFT JOIN item_list il 
    ON s.barcode = il.barcode
WHERE il.barcode IS NULL;

CREATE VIEW AAA_OUTBOUND_TIKI_LAST10 AS
SELECT *
FROM outbound
WHERE shop_name = 'KHO ECOM THỦ ĐỨC'
AND box_qty > 0
ORDER BY id DESC
LIMIT 10;

CREATE VIEW vw_NXT_cont_summary_by_date_brand AS
SELECT
    good_issue_date,
    brand_name,
    SUM(NULLIF(input_standard, 0)) AS total_D111,
    SUM(NULLIF(input_paper_bag, 0)) AS total_tui_giay,
    SUM(NULLIF(input_visual_merchandising, 0)) AS total_VMR
FROM inbound
WHERE region = 'CONT'
  AND good_issue_date >= date('now', 'start of month', '-1 month')
  AND good_issue_date < date('now', 'start of month')
GROUP BY good_issue_date, brand_name
ORDER BY good_issue_date, brand_name;

CREATE VIEW AAA_defect_pending AS
SELECT
d.id,
d.results,
d.purchase_order_num AS PO,
d.shop_name AS tên_shop,
d.defect_qty AS số_lượng,
--d.barcode,
d.artical,
d.item_full_name AS tên_sản_phẩm,
d.defect_type AS lỗi,
d.solution AS hướng_xử_lý,
d.note,
d.checklist 
FROM defect d
WHERE d.results IS NULL 
ORDER BY d.id DESC;

CREATE VIEW AAA_outbound_province_bill_expect_date AS
SELECT
    t.shop_code AS mã_shop,
    MAX(t.shop_name) AS tên_shop,
    SUM(t.box_qty) AS số_thùng,
    '-' AS bill_vận_chuyển,
    CASE
        WHEN (CAST(strftime('%w', DATE('now')) AS INTEGER) + MAX(t.lead_time_day)) >= 7
        THEN DATE('now', '+' || (MAX(t.lead_time_day) + 1) || ' days')
        ELSE DATE('now', '+' || MAX(t.lead_time_day) || ' days')
    END AS ngày_giao_hàng_dự_kiến,
    CASE
        WHEN MAX(t.carrier) = 'nhattin' THEN 'Nhất Tín'
        WHEN MAX(t.carrier) = 'vintran' THEN 'VinTrans'
        ELSE MAX(t.carrier)
    END AS Đơn_vị_vận_chuyển
FROM (
    SELECT
        o.shop_code,
        o.shop_name,
        o.delivery_order_num AS do_num,
        o.note,
        o.box_qty,
        g.groupx,
        s.lead_time_day,
        s.carrier
    FROM outbound o
    LEFT JOIN outbound_groupx g
        ON o.shop_code = g.shop_code
    LEFT JOIN shop s
        ON o.shop_code = s.shop_code
    LEFT JOIN province p
        ON s.province_id = p.id
    WHERE o.delivery_date = DATE('now')
      AND p.region = 'tỉnh'
    UNION ALL
    SELECT
        i.shop_code,
        s.shop_name,
        i.note AS do_num,
        i.item_name AS note,
        i.box_qty,
        g.groupx,
        s.lead_time_day,
        s.carrier
    FROM outbound_include i
    LEFT JOIN outbound_groupx g
        ON i.shop_code = g.shop_code
    LEFT JOIN shop s
        ON i.shop_code = s.shop_code
    LEFT JOIN province p
        ON s.province_id = p.id
    WHERE i.dely_date = DATE('now')
      AND p.region = 'tỉnh'
    UNION ALL
    SELECT
        p1.to_shop AS shop_code,
        s.shop_name,
        '-' AS do_num,
        'zLCNB' AS note,
        SUM(p1.box_qty) AS box_qty,
        g.groupx,
        s.lead_time_day,
        s.carrier
    FROM pullback p1
    LEFT JOIN outbound_groupx g
        ON p1.to_shop = g.shop_code
    LEFT JOIN shop s
        ON p1.to_shop = s.shop_code
    LEFT JOIN province p
        ON s.province_id = p.id
    WHERE p1.pullback_date = DATE('now')
      AND p1.to_shop NOT LIKE '%D111%'
      AND p1.to_shop NOT LIKE '%D116%'
      AND p.region = 'tỉnh'
    GROUP BY
        p1.to_shop,
        s.shop_name,
        g.groupx,
        s.lead_time_day,
        s.carrier
) t
GROUP BY t.shop_code
ORDER BY MAX(t.groupx), MAX(t.shop_name);

CREATE VIEW AAA_Delidate_NULL  AS
SELECT *
FROM outbound
WHERE delivery_date is NULL AND main_vendor <> "D116";

CREATE VIEW AAA_way_bill_last_month  AS
SELECT
a.shop_code,
a.shop_name,
a.brand_name,
a.region,
sum(a.box_qty) as box_qty,
s.carrier,
a.arrival_date,
a.way_bill
FROM inbound a
LEFT JOIN shop s ON a.shop_code = s.shop_code
WHERE strftime('%Y-%m', arrival_date  ) = strftime('%Y-%m', DATE('now', 'start of month', '-1 month')) AND region != 'CONT' AND region = "tỉnh"
GROUP BY
a.way_bill,
a.shop_code,
a.shop_name,
a.brand_name,
a.region,
s.carrier,
a.arrival_date;

CREATE VIEW test_expect_date AS
SELECT
    t.shop_code AS mã_shop,
    MAX(t.shop_name) AS tên_shop,
    SUM(t.box_qty) AS số_thùng,
    '-' AS bill_vận_chuyển,
    CASE
        WHEN (CAST(strftime('%w', DATE('now')) AS INTEGER) + MAX(t.lead_time_day)) >= 7
        THEN DATE('now', '+' || (MAX(t.lead_time_day) + 1) || ' days')
        ELSE DATE('now', '+' || MAX(t.lead_time_day) || ' days')
    END AS ngày_giao_hàng_dự_kiến,
    CASE
        WHEN MAX(t.carrier) = 'nhattin' THEN 'Nhất Tín'
        WHEN MAX(t.carrier) = 'vintran' THEN 'VinTrans'
        ELSE MAX(t.carrier)
    END AS Đơn_vị_vận_chuyển,
    MAX(t.contact_name) AS contact_name,
    MAX(t.contact_phone) AS contact_phone,
    MAX(t.tracking_url) AS tracking_url
FROM (
    SELECT
        o.shop_code,
        o.shop_name,
        o.delivery_order_num AS do_num,
        o.note,
        o.box_qty,
        g.groupx,
        s.lead_time_day,
        s.carrier,
        c.contact_name,
        c.contact_phone,
        c.tracking_url
    FROM outbound o
    LEFT JOIN outbound_groupx g
        ON o.shop_code = g.shop_code
    LEFT JOIN shop s
        ON o.shop_code = s.shop_code
    LEFT JOIN province p
        ON s.province_id = p.id
    LEFT JOIN carrier c 
    	ON s.carrier = c.id
    WHERE o.delivery_date = DATE('now')
      AND p.region = 'tỉnh'
    UNION ALL
    SELECT
        i.shop_code,
        s.shop_name,
        i.note AS do_num,
        i.item_name AS note,
        i.box_qty,
        g.groupx,
        s.lead_time_day,
        s.carrier,
        c.contact_name,
        c.contact_phone,
        c.tracking_url
    FROM outbound_include i
    LEFT JOIN outbound_groupx g
        ON i.shop_code = g.shop_code
    LEFT JOIN shop s
        ON i.shop_code = s.shop_code
    LEFT JOIN carrier c 
    	ON s.carrier = c.id
    LEFT JOIN province p
        ON s.province_id = p.id
    WHERE i.dely_date = DATE('now')
      AND p.region = 'tỉnh'
    UNION ALL
    SELECT
        p1.to_shop AS shop_code,
        s.shop_name,
        '-' AS do_num,
        'zLCNB' AS note,
        SUM(p1.box_qty) AS box_qty,
        g.groupx,
        s.lead_time_day,
        s.carrier,
        c.contact_name,
        c.contact_phone,
        c.tracking_url
    FROM pullback p1
    LEFT JOIN outbound_groupx g
        ON p1.to_shop = g.shop_code
    LEFT JOIN shop s
        ON p1.to_shop = s.shop_code
    LEFT JOIN carrier c 
    	ON s.carrier = c.id
    LEFT JOIN province p
        ON s.province_id = p.id
    WHERE p1.pullback_date = DATE('now')
      AND p1.to_shop NOT LIKE '%D111%'
      AND p1.to_shop NOT LIKE '%D116%'
      AND p.region = 'tỉnh'
    GROUP BY
        p1.to_shop,
        s.shop_name,
        g.groupx,
        s.lead_time_day,
        s.carrier,
        c.contact_name,
        c.contact_phone,
        c.tracking_url
) t
GROUP BY t.shop_code
ORDER BY MAX(t.groupx), MAX(t.shop_name);

CREATE VIEW data_tool_inbound_report AS
SELECT
shop_code,
shop_name,
brand_name,
region,
box_qty,
NULLIF(input_standard, 0) as product_qty,
NULLIF(input_taras_defect, 0) as taras_qty,
NULLIF(input_paper_bag, 0) as paper_qty,
NULLIF(input_visual_merchandising, 0) as vm_qty,
input_type,
status,
delivery_order_num as DO_num,
good_issue_date as GI_date,
arrival_date,
good_receipt_date as GR_date,
note
FROM inbound
WHERE good_receipt_date is null AND region <> "CONT";

CREATE VIEW data_tool_outbound_report AS
SELECT
	id,
	delivery_date,
	post_date,
    CASE
    WHEN post_date IS NOT NULL THEN 'posted'
    ELSE 'post null'
    END AS "check",
	checklist,
	brand_name,
	shop_code,
    shop_name,
    region,
    stock_transfer_order_num as PO_num,
    delivery_order_num as DO_num,
    note as type,
    box_qty,
    NULLIF(product_qty, 0) as product_qty,
	NULLIF(paper_bag_qty, 0) as paper_qty,
    order_qty
    FROM outbound
	WHERE delivery_date = date('now')
	ORDER BY shop_code ASC;