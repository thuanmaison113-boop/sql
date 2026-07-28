--CREATE INDEX idx_inbound_pending ON inbound (shop_code) WHERE current_action = 'post' OR current_action IS NULL;
CREATE INDEX idx_inbound_shop_code ON inbound(shop_code);
CREATE INDEX idx_inbound_shop_name ON inbound(shop_name);
CREATE INDEX idx_inbound_purchase_order_num ON inbound(purchase_order_num);
CREATE INDEX idx_inbound_good_receipt_date ON inbound(good_receipt_date);
CREATE INDEX idx_inbound_GR_date ON inbound(good_issue_date);

CREATE INDEX idx_outbound_note ON outbound(note);
CREATE INDEX idx_outbound_post_date ON outbound(post_date);
CREATE INDEX idx_outbound_delivery_date ON outbound(delivery_date);
CREATE INDEX idx_outbound_checklist ON outbound(checklist);
CREATE INDEX idx_outbound_stock_tranfer_oder_num ON outbound(stock_transfer_order_num);
CREATE INDEX idx_outbound_shop_code ON outbound(shop_code);
CREATE INDEX idx_outbound_shop_name ON outbound(shop_name);
CREATE INDEX idx_outbound_region ON outbound(region);
CREATE INDEX idx_outbound_delivery_order_num ON outbound(delivery_order_num);
CREATE INDEX idx_outbound_transfer_order_num ON outbound(transfer_order_num);

CREATE INDEX idx_shop_shop_name ON shop(shop_name);
CREATE INDEX idx_shop_shop_code ON shop(shop_code);

CREATE INDEX idx_item_list_barcode ON item_list(barcode);
CREATE INDEX idx_item_list_variant ON item_list(variant);
CREATE INDEX idx_item_list_style_code ON item_list(style_code);

CREATE INDEX idx_defect_purchase_order_num ON defect(purchase_order_num);
CREATE INDEX idx_defect_style_code ON defect(style_code);

--CREATE UNIQUE INDEX idx_fact_task_id ON fact_work_output(task_id);


