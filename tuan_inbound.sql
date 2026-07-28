-- nhập cont
SELECT
id,
note AS tên_job,
CASE 
    WHEN brand_name = 'Charles & Keith' THEN 'CK'
    ELSE brand_name
END AS brand,
box_qty as box,
input_standard AS hh,
input_paper_bag AS tg,
input_visual_merchandising as vmr,
input_type AS Loại,
purchase_order_num AS PO,
delivery_order_num AS số_post,
good_issue_date AS GI_date,
arrival_date AS Arrival,
current_action AS action,
good_receipt_date AS GR_date
FROM inbound
WHERE region = 'CONT'
ORDER BY id DESC




-- nhập pending
SELECT
id,
brand_name AS brand,
shop_code as code,
shop_name AS shop,
current_action AS action,
good_receipt_date as GRdate,
transfer_order_num AS TO_,
input_type AS loại,
box_qty,
input_standard,
input_taras_defect,
input_paper_bag,
CONCAT(box_qty, '-', input_standard, '-', input_taras_defect, '-', input_paper_bag) AS input,
transfer_order_quality_issue AS TO_QI,
substandard_qty AS QI_Qty,
purchase_order_num AS STO,
delivery_order_num AS DO,
arrival_date
FROM inbound  
WHERE good_receipt_date IS NULL AND region <> 'CONT';





-- nhập bill vận chuyển
SELECT
id,
brand_name,
shop_code AS code,
shop_name AS tên_shop,
box_qty AS số_thùng,
CONCAT(box_qty, '-', input_standard, '-', input_taras_defect, '-', input_paper_bag) AS input,
input_type AS loại,
delivery_order_num AS DO,
good_issue_date AS send_date,
arrival_date AS Arrival,
way_bill
FROM inbound
WHERE current_action IS NULL AND region <> 'CONT';









-- all put
SELECT
id,
brand_name,
current_action AS action,
shop_name AS tên_shop,
input_type,
CONCAT(box_qty, '-', input_standard, '-', input_taras_defect, '-', input_paper_bag) AS box_hh_taras_tg,
transfer_order_num AS TO_num,
transfer_order_quality_issue AS TO_QI,
substandard_qty AS QI_Qty,
arrival_date,
good_receipt_date,
purchase_order_num AS STO,
delivery_order_num AS DO,
way_bill 
FROM inbound
WHERE action = 'post';






-- inbound by shop_code 
select * from inbound where shop_code like '1130' and inbound.input_taras_defect = 0 order by id desc;



-- defect by shop_code
SELECT
d.id,
d.results,
d.purchase_order_num AS PO,
d.shop_name AS tên_shop,
d.defect_qty AS số_lượng,
d.barcode,
d.artical ,
d.item_full_name AS tên_sản_phẩm,
d.defect_type AS lỗi,
d.solution AS hướng_xử_lý,
d.note
FROM defect d
		INNER JOIN inbound i ON d.purchase_order_num = i.purchase_order_num
		WHERE i.shop_code = '1062'
ORDER BY d.id DESC;



-- defect by style code
select * from defect where style_code like "CK1-70381159" ;






-- defect all
SELECT
    d.id,
    d.results,
    d.purchase_order_num AS PO,
    d.shop_name AS tên_shop,
    d.defect_qty AS số_lượng,
    d.barcode,
    d.artical,
    d.item_full_name AS tên_sản_phẩm,
    d.defect_type AS lỗi,
    d.solution AS hướng_xử_lý,
    d.note,
    d.checklist
FROM defect d
WHERE d.results IS NULL
ORDER BY d.id DESC;









-- add inbound
SELECT
shop_code,
purchase_order_num,
delivery_order_num,
good_issue_date,
input_standard,
input_taras_defect,
note,
arrival_date,
id
FROM inbound 
ORDER BY id DESC LIMIT 1;



-- add defect
SELECT * FROM defect ORDER BY id DESC LIMIT 1 ;



-- add outbound
SELECT * FROM outbound ORDER BY id DESC LIMIT 1;



-- add disparity
SELECT * FROM outbound_disparity od  ORDER BY id DESC LIMIT 1;


