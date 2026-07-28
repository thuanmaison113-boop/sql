SELECT
	id,
	delivery_date as ngày_yêu_cầu_giao,
	post_date as ngày_post,
	checklist,
	brand_name as nhãn,
	shop_code as mã_shop,
    shop_name as tên_shop,
    region as vùng,
    stock_transfer_order_num as số_PO,
    delivery_order_num as số_DO,
    note,
    box_qty,
    NULLIF(product_qty, 0) as hàng_hóa,
	NULLIF(paper_bag_qty, 0) as túi_giấy,
    order_qty as SL_order
    FROM outbound
	WHERE delivery_date = date('now')
	ORDER BY shop_code ASC;