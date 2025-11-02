with 
--Nối bảng products và product_category_name_translation để  lấy tên tiếng anh của sản phẩm
products as (
select *
from dwh_olist.olist_products_dataset p left join dwh_olist.product_category_name_translation c
on p.product_category_name = c.product_category_name
), 
--Nối bảng sellers và geolocation để lấy thông tin địa lý của sellers
sellers_geo as (
select *
from dwh_olist.olist_sellers_dataset sellers left join dwh_olist.olist_geolocation_clean geo
on sellers.seller_zip_code_prefix = geo.geolocation_zip_code_prefix
),

--Nối bảng order_items với products 
items_products as (
select *
from dwh_olist.olist_order_items_dataset items left join products
on items.product_id = products.product_id
),
--Nối bảng items_products với sellers_geo
items_sellers as (
select *
from items_products left join sellers_geo
on items_products.seller_id = sellers_geo.seller_id
),
----------------------------------------------------------------------------
-- Nối bảng orders và customers
orders_custommers as (
select *
from dwh_olist.olist_orders_dataset orders left join dwh_olist.olist_customers_dataset customers
on orders.customer_id = customers.customer_id
), 
-- Agreegate bảng order_payments để lấy tổng giá trị thanh toán theo order_id
sum_payments as (
  select order_id, sum(payment_value) as total_payment_value
  from dwh_olist.olist_order_payments_dataset
  group by order_id
),
-- Nối bảng orders_custommers với sum_payments
sale_payments as (
select orders_custommers.order_id, orders_custommers.order_status
from orders_custommers left join sum_payments
on orders_custommers.order_id = sum_payments.order_id
),
-----------------------------------------------------------------------------
-- Nối sale_payments nối với items_sellers
sale_detail as (
select sale_payments.order_id
from sale_payments left join items_sellers
on sale_payments.order_id = items_sellers.order_id
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
-- Nối bảng sale_detail với reviews_agg
olist_data as (
select * 
from sale_detail left join reviews_agg
on sale_detail.order_id = reviews_agg.order_id
)
-- Truy vấn cuối cùng
select *
from olist_data
