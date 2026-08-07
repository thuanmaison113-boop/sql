-- tranfer between two dtb
--ATTACH DATABASE 'C:\Users\user\OneDrive - MAISON RMI\inventory_database_111_onedrive/data_scan.sqlite3' AS des;
/*INSERT INTO des.province_new (id, region, province, area)
SELECT id, region, province, area
FROM province--;
DETACH DATABASE des;*/

-- chống phân mảnh
VACUUM;
ANALYZE;

-- compare 2 table have same structure
SELECT * FROM table1
EXCEPT
SELECT * FROM table2;
UNION ALL
SELECT * FROM table2
EXCEPT
SELECT * FROM table1;


-- INSERT AND REMAKE TABLE
INSERT INTO employee_new (id, employee_code, employee_full_name, employee_short_name, user_SAP, gender, phone_number, employee_role, is_direct_labor, start_date, end_date)
SELECT id, employee_code, employee_full_name, employee_short_name, user_SAP, gender, phone_number, employee_role, is_direct_labor, start_date, end_date
FROM employee
--
CREATE TABLE inbound_ecom AS
SELECT *
FROM inbound_ecom_new
WHERE 0
--
INSERT INTO employee_new
SELECT *
FROM employee

-- Create the new table with the same structure, order value column
CREATE TABLE brand_sorted AS
SELECT *
FROM brand
ORDER BY brand_name ASC;

-- RENEW ITEM LIST
DELETE FROM item_list
DELETE FROM sqlite_sequence WHERE name = 'item_list';

-- RENEW inbound_pullback
DELETE FROM inbound_pullback
DELETE FROM sqlite_sequence WHERE name = 'inbound_pullback'
INSERT INTO inbound_pullback (id, shop_code, shop_name, brand_name, region, box_qty, input_standard, input_taras_defect, input_paper_bag, input_visual_merchandising, input_type, status, purchase_order_num, delivery_order_num, good_issue_date, transfer_order_num, put_away_bin, transfer_order_quality_issue, substandard_qty, arrival_date, current_action, good_receipt_date, note, inbound_code, way_bill, checklist, pullback_date, from_shop, to_shop, product, paper_bag)
SELECT id, shop_code, shop_name, brand_name, region, box_qty, input_standard, input_taras_defect, input_paper_bag, input_visual_merchandising, input_type, status, purchase_order_num, delivery_order_num, good_issue_date, transfer_order_num, put_away_bin, transfer_order_quality_issue, substandard_qty, arrival_date, current_action, good_receipt_date, note, inbound_code, way_bill, checklist, pullback_date, from_shop, to_shop, product, paper_bag
FROM inbound
WHERE region <> 'CONT';

-- GET COLUMN LIST HORIZONTALLY
SELECT GROUP_CONCAT(name, ', ') AS column_list
FROM PRAGMA_TABLE_INFO('employee');

-- GET COLUMN LIST VERTICALLY 
SELECT name || ',' AS column_name_with_comma
FROM PRAGMA_TABLE_INFO('inbound');

-- TIME STATEMENT
strftime('%Y-%m', post_date) = strftime('%Y-%m', DATE('now', '-1 month'))
DATE(post_date) >= DATE('now', '-3 days')
strftime('%Y-%m', upload_date) = strftime('%Y-%m', DATE('now', 'start of month', '-1 month')) -- get last month

-- 5 TYPE OF JOIN & ORDER OF PROCESS
INNER JOIN
LEFT JOIN
RIGHT JOIN
FULL JOIN
SELF JOIN (JOIN WITH ITSELF , LEFT OR INNER)
SELECT ------------- Step 5: Select columns or expressions
FROM --------------- Step 1: Specify source tables
JOIN --------------- Step 1: Combine related tables
WHERE -------------- Step 2: Filter rows
GROUP BY ----------- Step 3: Group data
HAVING ------------- Step 4: Filter groups
ORDER BY ----------- Step 6: Sort rows
LIMIT  ------------- Step 7: Limit rows

-- ROW NUMBER, RANK, DENSE_RANK , ranking to each row based on the value
SELECT
    shop,
    qty,
    ROW_NUMBER() OVER (PARTITION BY brand_name ORDER BY qty DESC) AS row_number,
    RANK() OVER (ORDER BY qty DESC) AS rank,
    DENSE_RANK() OVER (ORDER BY qty DESC) AS dense_rank
    --- result
| shop       | qty             | row_number | rank  | dense_rank   |
| S001       | 500             | 1                  | 1       | 1                  |
| S002       | 400             | 2                  | 2       | 2                  |
| S003       | 400             | 3                  | 2       | 2                  |
| S004       | 300             | 4                  | 4       | 3                  |;

-- LAG LEAD STATEMENT, get value in next or previous of current row value
SELECT
    shop_code,
    gi_date,
    input_main,
    LAG(input_main) OVER (PARTITION BY shop_code ORDER BY gi_date) AS prev_input,
    LEAD(input_main) OVER (PARTITION BY shop_code ORDER BY gi_date) AS next_input,
    input_main - LAG(input_main) OVER (PARTITION BY shop_code ORDER BY gi_date) AS diff_from_prev,
    LEAD(input_main) OVER (PARTITION BY shop_code ORDER BY gi_date) - input_main AS diff_to_next
FROM inbound
WHERE input_main IS NOT NULL
ORDER BY shop_code, gi_date
---- result
| shopcode     | gi_date    | input_main    | prev_input    | next_input   | diff_from_prev      | diff_to_next    |
| S001         | 2025-08-01 | 100           | (null)        | 150          | (null)              | 50              |
| S001         | 2025-08-02 | 150           | 100           | 180          | 50                  | 30              |
| S001         | 2025-08-03 | 180           | 150           | (null)       | 30                  | (null)          |;

-- TWO TYPE OF QUERY
-- CTE version
WITH ranked_inbound AS
  			(	
  				SELECT *, 
  				RANK() OVER (PARTITION BY brand_name ORDER BY input_standard DESC) AS rankinput   /* reset for each brand_name*/
   				FROM inbound
   				WHERE input_standard IS NOT NULL
   			)
SELECT *
FROM ranked_inbound
WHERE rankinput <= 2
-- SUB QUERY version
SELECT *
FROM 	(  	
				SELECT *,
           		RANK() OVER (PARTITION BY brand_name ORDER BY input_standard DESC) AS rankinput
    			FROM inbound
    			WHERE input_standard IS NOT NULL
			) AS ranked_inbound
WHERE rankinput <= 2;

-- update artical in defect table
UPDATE defect_new
SET artical = (
    SELECT item_list.variant
    FROM item_list
    WHERE item_list.barcode = defect_new.barcode
)
WHERE EXISTS (
    SELECT 1
    FROM item_list
    WHERE item_list.barcode = defect_new.barcode
);

-------------------thêm dòng vào inbound để cân bằng báo cáo ngày
INSERT INTO inbound (shop_code, good_issue_date,status,arrival_date,current_action, good_receipt_date)
VALUES ('TEMP','2026-04-29', 'complete', '2026-04-29', 'confirm','2026-04-29');

-------------------thêm dòng vào outbound để cân bằng báo cáo ngày
INSERT INTO outbound (shop_code, post_date)
VALUES ('TEMP', '2026-04-04');

-------------------find null upload date
SELECT * FROM inbound WHERE current_action IS NOT NULL AND arrival_date IS NULL;

-------------------find date wrong format
SELECT *
FROM outbound o 
WHERE delivery_date NOT LIKE '____-__-__' ;

-------------------fix break line character
UPDATE stocktaking
SET location = REPLACE(REPLACE(location, CHAR(13), ' '), CHAR(10), ' ');

-------------------REPLACE LINE BREAK WITH COMMA
UPDATE defect
SET Note = REPLACE(
              REPLACE(
                REPLACE(Note, CHAR(13) || CHAR(10), ','),
              CHAR(10), ','),
           CHAR(13), ',')
WHERE Note LIKE '%' || CHAR(10) || '%' OR Note LIKE '%' || CHAR(13) || '%';

-------------------find date not exist in date_tb
SELECT *
FROM inbound
WHERE good_receipt_date IS NOT NULL
AND good_receipt_date NOT IN (
SELECT Date FROM date_tb
);

-------------------show not found list vs nearest match include Null match
SELECT DISTINCT o.shop_code, s.shop_code AS nearest_match
FROM outbound o
LEFT JOIN shop s ON UPPER(o.shop_code) LIKE '%' || UPPER(s.shop_code) || '%'
WHERE UPPER(o.shop_code) NOT IN (SELECT shop_code FROM shop);

-------------------conver XXXX-YY TO YY XXXX
UPDATE outbound 
SET shop_code = UPPER(TRIM(SUBSTR(shop_code, INSTR(shop_code, '-') + 1) || ' ' || SUBSTR(shop_code, 1, INSTR(shop_code, '-') - 1))
)
WHERE shop_code LIKE '%-%';

-------------------update with nearest match value, exclude Null match
UPDATE outbound
SET shop_code = (
    SELECT s.shop_code
    FROM shop s
    WHERE outbound.shop_code LIKE s.shop_code || '%'
    ORDER BY LENGTH(s.shop_code) DESC
    LIMIT 1
)
WHERE shop_code NOT IN (SELECT shop_code FROM shop)
AND EXISTS (
    SELECT 1 FROM shop s WHERE outbound.shop_code LIKE s.shop_code || '%'
);

-- update barcode from item_list to item_material
INSERT INTO item_material (barcode)
SELECT il.barcode
FROM item_list il
LEFT JOIN item_material im ON il.barcode = im.barcode
WHERE im.barcode IS NULL
  AND il.type = 'hàng bán'
  AND il.barcode IS NOT NULL
  AND il.brand_name IN ('Charles & Keith', 'Pedro');

-- UPDATE item_materia
UPDATE item_material
SET material = REPLACE(material, 'Thành phần: ', '')
WHERE material LIKE '%Thành phần: %';

-- UPDATE item_material
UPDATE item_material
SET material = REPLACE(material, 'Thành phần chính', 'chính')
WHERE material LIKE '%Thành phần%';

-- UPDATE item_material
UPDATE item_material
SET material = REPLACE(material, 'Lớp lót', 'lót')
WHERE material LIKE '%Lớp lót%';

-- UPDATE item_material
UPDATE item_material
SET material = REPLACE(material, 'Lớp đế', 'đế')
WHERE material LIKE '%Lớp đế%';

-- UPDATE item_material
UPDATE item_material
SET material = 'Da Tổng Hợp'
WHERE material = 'Da Tổng Hợp (chính)';

-- DELETE item_material
DELETE FROM item_material
WHERE material = 'Theo thông tin trên bao bì' OR material is null OR barcode like '%+12';

-- FIND DUP LIST IN item_material
SELECT *, COUNT(*) AS duplicate_count
FROM item_material 
GROUP BY barcode  
HAVING COUNT(*) > 1;

-- DELETE row have lower id in item_material
DELETE FROM item_material
WHERE id NOT IN (
    SELECT MAX(id)
    FROM item_material
    GROUP BY barcode
)
AND barcode IN (
    SELECT barcode
    FROM item_material
    GROUP BY barcode
    HAVING COUNT(*) > 1
);

-------------------find shop have null province id, which province do not still exits
SELECT s.*
FROM shop s
LEFT JOIN province p ON s.province_id = p.id
WHERE p.id IS NULL;

-------------------Check inbound integrity
SELECT id, shop_code, shop_name AS recorded_shop_name,
       (SELECT s.shop_name FROM shop s WHERE s.shop_code = i.shop_code) AS correct_shop_name,
       brand_name AS recorded_brand_name,
       (SELECT b.brand_name FROM brand b 
        JOIN shop s ON s.brand = b.brand_code 
        WHERE s.shop_code = i.shop_code) AS correct_brand_name,
       region AS recorded_region,
       (SELECT p.region FROM province p 
        JOIN shop s ON s.province_id = p.id 
        WHERE s.shop_code = i.shop_code) AS correct_region
FROM inbound i
WHERE shop_name != (SELECT s.shop_name FROM shop s WHERE s.shop_code = i.shop_code)
   OR brand_name != (SELECT b.brand_name FROM brand b 
                     JOIN shop s ON s.brand = b.brand_code 
                     WHERE s.shop_code = i.shop_code)
   OR region != (SELECT p.region FROM province p 
                 JOIN shop s ON s.province_id = p.id 
                 WHERE s.shop_code = i.shop_code);

-------------------Update inbound integrity
UPDATE inbound
SET 
    shop_name = (SELECT s.shop_name FROM shop s WHERE s.shop_code = inbound.shop_code),
    brand_name = (SELECT b.brand_name FROM brand b 
                  JOIN shop s ON s.brand = b.brand_code 
                  WHERE s.shop_code = inbound.shop_code),
    region = (SELECT p.region FROM province p 
              JOIN shop s ON s.province_id = p.id 
              WHERE s.shop_code = inbound.shop_code)
WHERE shop_code IN (
    SELECT s.shop_code FROM shop s
);

-------------------Check outbound integrity
SELECT id, shop_code, shop_name AS recorded_shop_name,
       (SELECT s.shop_name FROM shop s WHERE s.shop_code = o.shop_code) AS correct_shop_name,
       brand_name AS recorded_brand_name,
       (SELECT b.brand_name FROM brand b 
        JOIN shop s ON s.brand = b.brand_code 
        WHERE s.shop_code = o.shop_code) AS correct_brand_name,
       region AS recorded_region,
       (SELECT p.region FROM province p 
        JOIN shop s ON s.province_id = p.id 
        WHERE s.shop_code = o.shop_code) AS correct_region
FROM outbound o
WHERE shop_name != (SELECT s.shop_name FROM shop s WHERE s.shop_code = o.shop_code)
   OR brand_name != (SELECT b.brand_name FROM brand b 
                     JOIN shop s ON s.brand = b.brand_code 
                     WHERE s.shop_code = o.shop_code)
   OR region != (SELECT p.region FROM province p 
                 JOIN shop s ON s.province_id = p.id 
                 WHERE s.shop_code = o.shop_code);

-------------------Update outbound integrity
UPDATE outbound
SET 
    shop_name = (SELECT s.shop_name FROM shop s WHERE s.shop_code = outbound.shop_code),
    brand_name = (SELECT b.brand_name FROM brand b 
                  JOIN shop s ON s.brand = b.brand_code 
                  WHERE s.shop_code = outbound.shop_code),
    region = (SELECT p.region FROM province p 
              JOIN shop s ON s.province_id = p.id 
              WHERE s.shop_code = outbound.shop_code)
WHERE shop_code IN (SELECT shop_code FROM shop);

-------------------Check defect integrity
SELECT id, purchase_order_num, barcode,
       shop_name AS recorded_shop_name,
       (SELECT i.shop_name FROM inbound i WHERE i.purchase_order_num = d.purchase_order_num) AS correct_shop_name,
       item_full_name AS recorded_item_name,
       (SELECT il.item_full_name FROM item_list il WHERE il.barcode = d.barcode) AS correct_item_name,
       style_code AS recorded_style_code,
       (SELECT il.style_code FROM item_list il WHERE il.barcode = d.barcode) AS correct_style_code
FROM defect d
WHERE shop_name != (SELECT i.shop_name FROM inbound i WHERE i.purchase_order_num = d.purchase_order_num)
   OR item_full_name != (SELECT il.item_full_name FROM item_list il WHERE il.barcode = d.barcode)
   OR style_code != (SELECT il.style_code FROM item_list il WHERE il.barcode = d.barcode);

-------------------Update defect integrity
UPDATE defect
SET
    shop_name = (SELECT i.shop_name FROM inbound i WHERE i.purchase_order_num = defect.purchase_order_num),
    item_full_name = (SELECT il.item_full_name FROM item_list il WHERE il.barcode = defect.barcode),
    style_code = (SELECT il.style_code FROM item_list il WHERE il.barcode = defect.barcode)
WHERE 
    EXISTS (SELECT 1 FROM inbound i WHERE i.purchase_order_num = defect.purchase_order_num)
    OR EXISTS (SELECT 1 FROM item_list il WHERE il.barcode = defect.barcode);

-------------------Update shop_address to shop table
UPDATE shop_new
SET shop_address = (
    SELECT sa.address
    FROM shop_address sa
    WHERE sa.shop_code = shop_new.shop_code
)
WHERE EXISTS (
    SELECT 1
    FROM shop_address sa
    WHERE sa.shop_code = shop_new.shop_code
);

-------------------check a date exits in date_tb or not
SELECT DISTINCT i.good_issue_date
FROM inbound i
LEFT JOIN date_tb d ON i.good_issue_date = d.Date
WHERE i.good_issue_date IS NOT NULL
  AND d.Date IS NULL;

-------------------check wrong status for inbound table
SELECT 
    id,
    status AS current_status,
    CASE
        WHEN current_action = 'confirm' THEN 'complete'
        WHEN (arrival_date IS NULL OR arrival_date = '') 
             AND (current_action IS NULL OR current_action = '') THEN 'Pending'
        ELSE 'process'
    END AS expected_status
FROM inbound
WHERE status <> CASE
        WHEN current_action = 'confirm' THEN 'complete'
        WHEN (arrival_date IS NULL OR arrival_date = '') 
             AND (current_action IS NULL OR current_action = '') THEN 'Pending'
        ELSE 'process'
    END;

-------------------Update inbound status
UPDATE inbound
SET status =
    CASE
        WHEN current_action = 'confirm' THEN 'complete'
        WHEN (arrival_date IS NULL OR arrival_date = '') 
             AND (current_action IS NULL OR current_action = '') THEN 'Pending'
        ELSE 'process'
    END
WHERE status IS NOT
    CASE
        WHEN current_action = 'confirm' THEN 'complete'
        WHEN (arrival_date IS NULL OR arrival_date = '') 
             AND (current_action IS NULL OR current_action = '') THEN 'Pending'
        ELSE 'process'
    END;

-- Virtual Table Project
CREATE VIRTUAL TABLE defect_search USING fts5(
  item_full_name,
  shop_name,
  defect_type,
  note,
  content='defect',
  content_rowid='id',
  tokenize = 'unicode61 remove_diacritics 0'
)
DROP TABLE defect_search
SELECT d.*
FROM defect_search
JOIN defect d ON defect_search.rowid = d.id
WHERE defect_search MATCH 'HUẾ'
ORDER BY d.id DESC
LIMIT 5;

-- mail exchange
SELECT 
    b.shop_code AS mã_shop,
    d.shop_name AS tên_shop,
    d.defect_qty AS SL,
    d.barcode,
    d.item_full_name AS món_hàng,
    d.defect_type AS lỗi,
    d.solution AS hướng_xử_lý,
    b.stock_transfer_order_num AS PO_num,
    b.delivery_order_num AS DO_num,
    b.post_date AS GI_date
FROM defect d
INNER JOIN outbound b 
    ON d.note = b.stock_transfer_order_num
WHERE d.note IN (
4500196372
);

-------- find shop_code not exist in outbound_groupx
SELECT s.shop_code,
s.shop_name 
FROM shop s
WHERE NOT EXISTS (
    SELECT 1
    FROM outbound_groupx og
    WHERE og.shop_code = s.shop_code
);

