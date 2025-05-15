with sales_data as (
    select 
        country,
        sum(daily_sold_count) as total_quantity_sold,
        sum(unit_price_in_usd * daily_sold_count) AS total_sales_amount
    from 
        kalo_data_online.ads_product_info
    where 
        new_ter_cate_id = (select CAST(cate_id AS VARCHAR)
                            from kalo_data_online.dim_shop_category_all
                            where country_code = 'cn' and name like '茶') -- 涉及人工查询
        and country IN ('us', 'gb', 'sg', 'mx', 'my', 'id', 'th', 'ph', 'vn')
        and partition_day BETWEEN '2024-05-05' and '2025-05-05'
    group by 
        country
)

select
    country,
    total_quantity_sold,
    total_sales_amount,
    total_sales_amount / sum(total_sales_amount) OVER () * 100 as sales_amount_percentage,
    total_quantity_sold * 100.0 / sum(total_quantity_sold) OVER () as quantity_percentage
from
    sales_data
order by
    total_sales_amount desc;
