with top_20_seller as (
    select 
        seller_id,
        shop_name,
        sum(total_gmv) as total_gmv
    from 
        kalo_data_online.ads_seller_info
    where 
        partition_day between '2025-03-22' and '2025-04-22'
        and new_main_category like '%700650%' -- 保健食品id
        and country = 'us' -- 美区
    group by 
        seller_id,shop_name
    order by 
        total_gmv desc
    limit 20
    ),

seller_content_stats as (
    select
        p.seller_id,
        p.strategy,
        sum(p.sale) as total_sale,
        sum(p.gmv) as total_gmv
    from 
        kalo_data_online.ads_product_sale_allocation p
    join 
        top_20_seller t on p.seller_id = t.seller_id
    where 
        p.partition_day between '2025-03-22' and '2025-04-22'
    group by 
        p.seller_id,p.strategy
),

seller_totals as (
    select 
        seller_id,
        sum(total_sale) as seller_total_sale,
        sum(total_gmv) as seller_total_gmv
    from 
        seller_content_stats
    group by 
        seller_id
)

select 
    t.shop_name,
    s.seller_id,
    s.strategy,
    s.total_sale,
    s.total_gmv,
    ROUND((s.total_gmv * 100.0 / NULLIF(st.seller_total_gmv, 0)), 2) as gmv_percentage
from 
    seller_content_stats s
join 
    seller_totals st on s.seller_id = st.seller_id
join 
    top_20_seller t on s.seller_id = t.seller_id
order by 
    t.shop_name,
    s.seller_id, 
    s.strategy;
