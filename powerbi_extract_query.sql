select * 
from (
with 
--Nối bảng products và product_category_name_translation để  lấy tên tiếng anh của sản phẩm
products as (
  select p.product_id, c.product_category_name_english, p.product_weight_g
  from dwh_olist.olist_products_dataset p left join dwh_olist.product_category_name_translation c
  on p.product_category_name = c.product_category_name
), 

--Nối bảng sellers và geolocation để lấy thông tin địa lý của sellers
sellers_geo as (
  select s.seller_id, s.seller_city, s.seller_state, g.geolocation_city, g.geolocation_state
  from dwh_olist.olist_sellers_dataset s left join dwh_olist.olist_geolocation_clean g
  on s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
),

--Nối bảng order_items với products 
items_products as (
  select 
  i.order_id, i.order_item_id, i.product_id, i.seller_id, i.shipping_limit_date, i.price, i.freight_value,
  p.product_category_name_english, p.product_weight_g
  from dwh_olist.olist_order_items_dataset i left join products p
  on i.product_id = p.product_id
),

--Nối bảng items_products với sellers_geo
items_sellers as (
select 
  ip.order_id, ip.order_item_id, ip.product_id, ip.seller_id, ip.shipping_limit_date, ip.price, ip.freight_value,
  ip.product_category_name_english, ip.product_weight_g,
  sg.seller_city, sg.seller_state, sg.geolocation_city, sg.geolocation_state
  from items_products ip left join sellers_geo sg
  on ip.seller_id = sg.seller_id
),
----------------------------------------------------------------------------
-- Agreegate bảng order_payments để lấy tổng giá trị thanh toán theo order_id
sum_payments as (
  select order_id, sum(payment_value) as total_payment_value
  from dwh_olist.olist_order_payments_dataset
  group by order_id
),
-- Nối bảng orders với sum_payments
order_payments as ( 
  select 
  o.order_id, o.customer_id, o.order_status, o.order_purchase_timestamp, o.order_approved_at, o.order_delivered_carrier_date,
  o.order_delivered_customer_date, o.order_estimated_delivery_date, sp.total_payment_value
  from dwh_olist.olist_orders_dataset o left join sum_payments sp
  on o.order_id = sp.order_id
),
-----------------------------------------------------------------------------
-- Agreegate bảng order_reviews để lấy điểm đánh giá trung bình và số lượng đánh giá theo order_id
reviews_agg as (
  select order_id,
         avg(review_score) as avg_review_score,
         count(*) as review_count
  from dwh_olist.olist_order_reviews_dataset
  group by order_id
),
-- Nối bảng order_payments với reviews_agg
order_payments_reviews as (
  select 
  op.order_id, op.customer_id, op.order_status, op.order_purchase_timestamp, op.order_approved_at, op.order_delivered_carrier_date, 
  op.order_delivered_customer_date, op.order_estimated_delivery_date, op.total_payment_value,
  ra.review_count, ra.avg_review_score
  from order_payments op left join reviews_agg ra
  on op.order_id = ra.order_id
),
-- Nối order_payments_reviews với customers
sales as (
  select 
  opr.order_id, opr.customer_id, opr.order_status, opr.order_purchase_timestamp, opr.order_approved_at, opr.order_delivered_carrier_date, 
  opr.order_delivered_customer_date, opr.order_estimated_delivery_date, opr.total_payment_value,opr.review_count, opr.avg_review_score,
  c.customer_unique_id, c.customer_city, c.customer_state
  from order_payments_reviews opr left join dwh_olist.olist_customers_dataset c
  on opr.customer_id = c. customer_id
),

--Nối sales nối với items_sellers
sale_details as (
  select 
  s.order_id, s.customer_id, s.order_status, s.order_purchase_timestamp, s.order_approved_at, s.order_delivered_carrier_date, s.order_delivered_customer_date, 
  s.order_estimated_delivery_date, s.total_payment_value,s.review_count, s.avg_review_score,
  s.customer_unique_id, s.customer_city, s.customer_state,
  i.order_item_id, i.product_id, i.seller_id, i.shipping_limit_date, i.price, i.freight_value,
  i.product_category_name_english, i.product_weight_g,
  i.seller_city, i.seller_state, i.geolocation_city, i.geolocation_state
  from sales s left join items_sellers i
  on s.order_id = i.order_id
)

--Truy vấn cuối cùng
select *, 
  -- Số ngày từ order approved → delivered
  CASE 
    WHEN order_status IN ('delivered', 'shipped') 
    THEN DATE_DIFF(
          DATE(order_delivered_customer_date), 
          DATE(order_approved_at), 
          DAY
        )
    ELSE NULL
  END AS DayToDelivery,

  -- On-time delivery
  CASE 
    WHEN order_status IN ('delivered', 'shipped') 
    THEN order_delivered_customer_date <= order_estimated_delivery_date
    ELSE NULL
  END AS OnTime,

  -- Late delivery
  CASE 
    WHEN order_status IN ('delivered', 'shipped') 
    THEN order_delivered_customer_date > order_estimated_delivery_date
    ELSE NULL
  END AS LateDelivery,
  DATE(order_purchase_timestamp) AS order_purchase_date,
  DATE(order_approved_at) AS order_approved_date,
  DATE(order_delivered_customer_date) AS order_delivered_date
from sale_details
) as FinalResultQuery

