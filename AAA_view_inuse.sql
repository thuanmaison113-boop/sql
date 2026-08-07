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

CREATE VIEW AAA_cont_job AS
SELECT
arrival_date as Arrival_date,
good_receipt_date as GR_date,
input_type as Loại,
note as tên_job,
CASE 
    WHEN brand_name = 'Charles & Keith' THEN 'CK'
    ELSE brand_name
END AS brand,
box_qty as thùng,
NULLIF(input_standard, 0) as hàng_hóa,
NULLIF(input_paper_bag, 0) as túi_giấy,
NULLIF(input_visual_merchandising, 0) as VMR,
purchase_order_num as PO
FROM inbound
WHERE region = 'CONT'
  AND note IN (
    SELECT note
    FROM inbound
    WHERE region = 'CONT'
    GROUP BY note
    ORDER BY MAX(arrival_date) DESC
  )
ORDER BY arrival_date DESC;

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
i.note
FROM inbound i
LEFT JOIN shop s ON i.shop_code = s.shop_code
WHERE good_receipt_date =
    (SELECT MAX(good_receipt_date)
     FROM inbound i2);

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

CREATE VIEW AAA_outbound_DONULL  AS
SELECT *
FROM outbound
WHERE delivery_order_num = '-';

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

CREATE VIEW AAA_outbound_pending  AS
SELECT *
FROM outbound
WHERE product_qty = 0
  AND paper_bag_qty = 0
  AND delivery_date >= DATE('now', '-3 days');

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
ORDER BY shop_name;

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

CREATE VIEW LUC666 AS
SELECT *
FROM (
    SELECT *
    FROM outbound
    ORDER BY id DESC
    LIMIT 300
) t
ORDER BY id ASC;

CREATE VIEW vw_report_daily_diff_in_out_last_date AS
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

CREATE VIEW AAA_Asset_stock_on_hand AS
SELECT
    item_name,
    SUM(CASE WHEN status = 'inbound' THEN quantity ELSE 0 END) AS total_inbound,
    SUM(CASE WHEN status = 'outbound' THEN quantity ELSE 0 END) AS total_outbound,
    SUM(CASE WHEN status = 'inbound' THEN quantity ELSE 0 END)
      - SUM(CASE WHEN status = 'outbound' THEN quantity ELSE 0 END) AS stock_in_hand
FROM inbound_visual_asset
GROUP BY item_name
HAVING 
    SUM(CASE WHEN status = 'inbound' THEN quantity ELSE 0 END)
    - SUM(CASE WHEN status = 'outbound' THEN quantity ELSE 0 END) > 0;

CREATE VIEW AAA_OUTBOUND_TIKI_LAST10 AS
SELECT *
FROM outbound
WHERE shop_name = 'KHO ECOM THỦ ĐỨC'
AND box_qty > 0
ORDER BY id DESC
LIMIT 10;

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

CREATE VIEW AAA_expect_date AS
SELECT 
    o.shop_code AS mã_shop,
    o.shop_name AS tên_shop,
    SUM(o.box_qty) AS số_thùng,
    '-' AS bill_vận_chuyển,
    CASE 
        WHEN strftime('%w', DATE(o.delivery_date, '+' || s.lead_time_day || ' days')) = '0'
        THEN DATE(o.delivery_date, '+' || (s.lead_time_day + 1) || ' days')
        ELSE DATE(o.delivery_date, '+' || s.lead_time_day || ' days')
    END AS ngày_giao_hàng_dự_kiến,
    CASE
    WHEN s.carrier = 'nhattin' THEN 'Nhất Tín'
    WHEN s.carrier = 'vintran' THEN 'VinTrans'
    ELSE s.carrier
END AS Đơn_Vị_Vận_Chuyển
FROM outbound AS o
LEFT JOIN shop AS s
    ON o.shop_code = s.shop_code
WHERE o.delivery_date = DATE('now')
  AND s.province_id <> 44
GROUP BY 
    o.shop_code,
    o.shop_name
ORDER BY 
    o.shop_name ASC;

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