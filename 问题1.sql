select
    a.new_pri_cate_id,
    sum(b.gmv) as gmv,
    sum(b.gmv_in_usd),
    count(distinct case when b.daily_sold_count > 0 then a.product_id end) as sale_p_cnt
from 
(
select *
from kalo_data_online.ads_product_info 
where partition_day = '2025-04-22'
    and new_pri_cate_id in ('600942','601739','601755','604693','601768')
    and country = 'th'
) a 
left join(
select
    product_id,
    sum(unit_price * daily_sold_count) as gmv,
    sum(unit_price_in_usd * daily_sold_count) as gmv_in_usd,
    sum(daily_sold_count) as daily_sold_count
from kalo_data_online.ads_product_info
where partition_day between '2024-04-22' and '2025-04-22'
    and country = 'th'
group by product_id 
) b 
    on a.product_id = b.product_id
group by a.new_pri_cate_id
