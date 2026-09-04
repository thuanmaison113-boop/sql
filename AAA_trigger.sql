----------------outbound_add_shop_brand_region
CREATE TRIGGER outbound_add_shop_brand_region
AFTER INSERT ON outbound
FOR EACH ROW
BEGIN
    UPDATE outbound
    SET 
        shop_name = (SELECT s.shop_name FROM shop s WHERE s.shop_code = NEW.shop_code),
        brand_name = (SELECT b.brand_name FROM shop s INNER JOIN brand b ON s.brand = b.brand_code WHERE s.shop_code = NEW.shop_code),
        region = (SELECT p.region FROM shop s INNER JOIN province p ON s.province_id = p.id WHERE s.shop_code = NEW.shop_code)
    WHERE rowid = NEW.rowid;
END;

------------inbound_add_infos
CREATE TRIGGER inbound_add_infos
AFTER INSERT ON inbound
FOR EACH ROW
BEGIN
    UPDATE inbound
    SET 
        shop_name = (SELECT s.shop_name FROM shop s WHERE s.shop_code = NEW.shop_code),
        brand_name = (SELECT b.brand_name FROM shop s INNER JOIN brand b ON s.brand = b.brand_code WHERE s.shop_code = NEW.shop_code),
        region = (SELECT p.region FROM shop s INNER JOIN province p ON s.province_id = p.id WHERE s.shop_code = NEW.shop_code),
        inbound_code = 
        CASE
            WHEN SUBSTR(NEW.purchase_order_num, 1, 2) = '47' THEN 'I-' || NEW.delivery_order_num || '-001'
            WHEN SUBSTR(NEW.purchase_order_num, 1, 2) = '45' THEN 'O-00' || NEW.delivery_order_num || '-001'
            ELSE '-'
        END
    WHERE rowid = NEW.rowid;
END;

----------------inbound_change_status
CREATE TRIGGER inbound_change_status
AFTER UPDATE OF current_action, arrival_date ON inbound
FOR EACH ROW
WHEN NEW.current_action IS NOT OLD.current_action OR NEW.arrival_date IS NOT OLD.arrival_date
BEGIN
    UPDATE inbound 
    SET status = 
        CASE
            WHEN NEW.current_action = 'confirm' THEN 'complete'
            WHEN (NEW.arrival_date IS NULL OR NEW.arrival_date = '') AND 
                 (NEW.current_action IS NULL OR NEW.current_action = '') THEN 'Pending'
            ELSE 'process'
        END
    WHERE rowid = NEW.rowid;
END;

----------------cyclecount_add_brand_name
CREATE TRIGGER cyclecount_add_brand_name
AFTER INSERT ON cyclecount
FOR EACH ROW
BEGIN
    UPDATE cyclecount
    SET brand_name = (
        SELECT brand_name
        FROM brand
        WHERE brand.brand_code = NEW.brand_code
    )
    WHERE id = NEW.id;
END;

----------------stocktaking_add_brand_name
CREATE TRIGGER stocktaking_add_brand_name
AFTER INSERT ON stocktaking
FOR EACH ROW
BEGIN
   UPDATE stocktaking
    SET brand_name = (
        SELECT brand_name
        FROM brand
        WHERE brand.brand_code = stocktaking.brand_code
    )
    WHERE id = NEW.id;
END;

----------------cyclecount_calc_difference
CREATE TRIGGER cyclecount_calc_difference
AFTER UPDATE ON cyclecount
FOR EACH ROW
BEGIN
    UPDATE cyclecount
    SET different = NEW.scan_qty - NEW.cyclecount_qty
    WHERE id = NEW.id;
END;

----------------outbound_disparity_insert
CREATE TRIGGER outbound_disparity_insert
AFTER INSERT ON outbound_disparity
FOR EACH ROW
BEGIN
    UPDATE outbound_disparity
    SET employee_short_name = (
        SELECT e.employee_short_name 
        FROM employee e 
        WHERE e.user_SAP = NEW.user_SAP
    )
    WHERE rowid = NEW.rowid;
END;

----------------inbound_ecom_add_info
CREATE TRIGGER inbound_ecom_add_info
AFTER INSERT ON inbound_ecom
FOR EACH ROW
BEGIN
    UPDATE inbound_ecom
    SET 
    	artical = (SELECT e.artical FROM item_ecom_bag e WHERE e.barcode = NEW.barcode),
        en_name = (SELECT e.en_name FROM item_ecom_bag e WHERE e.barcode = NEW.barcode),
        vn_name = (SELECT e.vn_name FROM item_ecom_bag e WHERE e.barcode = NEW.barcode)
    WHERE rowid = NEW.rowid;
END;

----------------defect_after_insert_barcode
CREATE TRIGGER defect_after_insert_barcode
AFTER INSERT ON defect
FOR EACH ROW
WHEN NEW.barcode IS NOT NULL
BEGIN
    UPDATE defect
    SET
        shop_name = (SELECT i.shop_name FROM inbound i WHERE i.purchase_order_num = NEW.purchase_order_num),
        artical = (SELECT il.variant FROM item_list il WHERE il.barcode = NEW.barcode),
        item_full_name = (SELECT il.item_full_name FROM item_list il WHERE il.barcode = NEW.barcode),
        style_code = (SELECT il.style_code FROM item_list il WHERE il.barcode = NEW.barcode)
    WHERE rowid = NEW.rowid;
END;

----------------defect_after_insert_artical
CREATE TRIGGER defect_after_insert_artical
AFTER INSERT ON defect
FOR EACH ROW
WHEN NEW.artical IS NOT NULL
BEGIN
    UPDATE defect
    SET
        shop_name = (SELECT i.shop_name FROM inbound i WHERE i.purchase_order_num = NEW.purchase_order_num),
        barcode = (SELECT il.barcode FROM item_list il WHERE il.variant = NEW.artical ),
        item_full_name = (SELECT il.item_full_name FROM item_list il WHERE il.variant = NEW.artical),
        style_code = (SELECT il.style_code FROM item_list il WHERE il.variant = NEW.artical)
    WHERE rowid = NEW.rowid;
END;

----------------outbound_include_add_shop_name
CREATE TRIGGER outbound_include_add_shop_name
AFTER INSERT ON outbound_include
FOR EACH ROW
BEGIN
    UPDATE outbound_include
    SET 
        shop_name = (SELECT s.shop_name FROM shop s WHERE s.shop_code = NEW.shop_code)
    WHERE rowid = NEW.rowid;
END;

----------------pda_devices_insert
CREATE TRIGGER pda_devices_insert
AFTER INSERT ON pda_devices
FOR EACH ROW
BEGIN
    UPDATE pda_devices
    SET assigned_user_name = (
        SELECT e.employee_short_name 
        FROM employee e 
        WHERE e.user_SAP = NEW.assigned_to
    )
    WHERE rowid = NEW.rowid;
END;

----------------plan_mer_overall_add_brand_name
CREATE TRIGGER plan_mer_overall_add_brand_name
AFTER INSERT ON plan_mer_overall
FOR EACH ROW
BEGIN
    UPDATE plan_mer_overall
    SET 
        brand_name = (SELECT b.brand_name FROM brand b WHERE b.brand_code = NEW.brand_code)
       	WHERE rowid = NEW.rowid;
END;

----------------plan_transaction_frequency_add_brand_name
CREATE TRIGGER plan_transaction_frequency_add_brand_name
AFTER INSERT ON plan_transaction_frequency
FOR EACH ROW
BEGIN
    UPDATE plan_transaction_frequency
    SET 
        brand_name = (SELECT b.brand_name FROM brand b WHERE b.brand_code = NEW.brand_code)
       	WHERE rowid = NEW.rowid;
END;

----------------employee_leave_add_name
CREATE TRIGGER employee_leave_add_name
AFTER INSERT ON employee_leave
FOR EACH ROW
BEGIN
    UPDATE employee_leave
    SET 
        employee_full_name = (SELECT b.employee_full_name FROM employee b WHERE b.employee_code = NEW.employee_code)
       	WHERE rowid = NEW.rowid;
END;

----------------employee_leave_calc_total_day
CREATE TRIGGER employee_leave_calc_total_day
AFTER INSERT ON employee_leave
FOR EACH ROW
WHEN NEW.start_date IS NOT NULL
 AND NEW.end_date IS NOT NULL
BEGIN
    UPDATE employee_leave
    SET total_day = (
        SELECT COUNT(*)
        FROM (
            WITH RECURSIVE dates(d) AS (
                SELECT NEW.start_date
                UNION ALL
                SELECT date(d, '+1 day')
                FROM dates
                WHERE d < NEW.end_date
            )
            SELECT d
            FROM dates
            WHERE strftime('%w', d) <> '0'
        )
    )
    WHERE id = NEW.id;
END;

----------------employee_leave_calc_total_day_update
CREATE TRIGGER employee_leave_calc_total_day_update
AFTER UPDATE OF start_date, end_date ON employee_leave
FOR EACH ROW
WHEN NEW.start_date IS NOT NULL
 AND NEW.end_date IS NOT NULL
BEGIN
    UPDATE employee_leave
    SET total_day = (
        SELECT COUNT(*)
        FROM (
            WITH RECURSIVE dates(d) AS (
                SELECT NEW.start_date
                UNION ALL
                SELECT date(d, '+1 day')
                FROM dates
                WHERE d < NEW.end_date
            )
            SELECT d
            FROM dates
            WHERE strftime('%w', d) <> '0'
        )
    )
    WHERE id = NEW.id;
END;

CREATE TRIGGER soh_change_add_artical_stylesizecolor
AFTER INSERT ON soh_change
FOR EACH ROW
WHEN NEW.barcode IS NOT NULL AND NEW.barcode != '-'
BEGIN
    UPDATE soh_change
    SET
        article = (SELECT il.variant FROM item_list il WHERE il.barcode = NEW.barcode),
        style_code = (SELECT il.style_code FROM item_list il WHERE il.barcode = NEW.barcode),
        size = (SELECT il.sizes FROM item_list il WHERE il.barcode = NEW.barcode),
        color = (SELECT il.color FROM item_list il WHERE il.barcode = NEW.barcode),
        full_price = (SELECT il.full_price FROM item_list il WHERE il.barcode = NEW.barcode)
    WHERE rowid = NEW.rowid;
END;

CREATE TRIGGER soh_change_calc_disparity
AFTER INSERT ON soh_change
FOR EACH ROW
BEGIN
    UPDATE soh_change
    SET
        disparity = NEW.soh_physical - NEW.soh_system
    WHERE rowid = NEW.rowid;
END;

CREATE TRIGGER employee_overtime_cal_overtime_hours
AFTER INSERT ON employee_overtime
FOR EACH ROW
BEGIN
    UPDATE employee_overtime
    SET overtime_hours =
        ROUND(
            (
                CASE
                    WHEN end_time >= start_time THEN
                        (
                            (CAST(substr(end_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(end_time, 4, 2) AS INTEGER))
                            -
                            (CAST(substr(start_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(start_time, 4, 2) AS INTEGER))
                        )
                    ELSE
                        (
                            (CAST(substr(end_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(end_time, 4, 2) AS INTEGER))
                            + 1440
                            -
                            (CAST(substr(start_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(start_time, 4, 2) AS INTEGER))
                        )
                END
            ) / 60.0,
            2
        )
    WHERE id = NEW.id;
END;

CREATE TRIGGER employee_overtime_cal_overtime_hours_update
AFTER UPDATE OF start_time, end_time ON employee_overtime
FOR EACH ROW
WHEN NEW.start_time IS NOT OLD.start_time OR NEW.end_time IS NOT OLD.end_time
BEGIN
    UPDATE employee_overtime 
    SET overtime_hours = 
        ROUND(
            (
                CASE
                    WHEN end_time >= start_time THEN
                        (
                            (CAST(substr(end_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(end_time, 4, 2) AS INTEGER))
                            -
                            (CAST(substr(start_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(start_time, 4, 2) AS INTEGER))
                        )
                    ELSE
                        (
                            (CAST(substr(end_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(end_time, 4, 2) AS INTEGER))
                            + 1440
                            -
                            (CAST(substr(start_time, 1, 2) AS INTEGER) * 60 +
                             CAST(substr(start_time, 4, 2) AS INTEGER))
                        )
                END
            ) / 60.0,
            2
        )
    WHERE rowid = NEW.rowid;
END;

CREATE TRIGGER employee_overtime_add_name
AFTER INSERT ON employee_overtime
FOR EACH ROW
BEGIN
    UPDATE employee_overtime
    SET employee_full_name = (
        SELECT employee_full_name
        FROM employee
        WHERE employee_code = NEW.employee_code
    )
    WHERE id = NEW.id;
END;
