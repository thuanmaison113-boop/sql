SELECT
o.post_date,
o.box_qty,
o.product_qty as hàng_hóa,
o.paper_bag_qty,
o.delivery_order_num as DO ,
o.transfer_order_num as TO_,
o.order_qty as ord_qty,
o.delivery_date as date,
o.shop_name,
o.shop_code,
o.checklist,
O.stock_transfer_order_num ,
o.note2 ,
id
FROM outbound o
where o.transfer_order_num in (
--where delivery_order_num in (

2000198948,
2000198954,
2000198958







);

