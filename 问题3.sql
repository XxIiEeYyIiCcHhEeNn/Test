-- 人工查询相似类目id
with target_categories as (
    select CAST(cate_id AS VARCHAR) as cate_id
    from kalo_data_online.dim_shop_category_all
    where country_code = 'cn' 
    and (name like '%运动与能量饮品%' or name like '%健身保健食品%')
),

-- 筛选符合基本要求的达人
ph_fitness_creators as (
    select
        *
    from 
        kalo_data_online.ads_creator_info
    where
        country = 'ph'
        and partition_day = '2025-04-30'
        and (
            exists (
            select 1 from target_categories 
            where new_main_category LIKE '%' || cate_id || '%'
            ) 
        )
        and is_allocated_gmv_active = 1 -- 有活跃GMV
        and creator_type = 'INDEPENDENT' -- 联盟达人
        and contact_hitmap <> 0 --有联系方式
),

-- 选取综合得分前20位的达人
top_20_creators as (
    select
        uid,
        handle,
        follower_count,
        new_ter_cate_ids,
        new_main_category,
        -- 计算综合得分（考虑到粉丝规模、电商视频总数、电商视频播放量、点赞/评论互动）
        (LOG(10, follower_count + 1) * 0.2 +
         LOG(10, play_count_0 + 1) * 0.3 +
         LOG(10, digg_count_0 + 1) * 0.2 +
         LOG(10, comment_count_0 + 1) * 0.1 +
         (aweme_count_0 / 100) * 0.2) as composite_score
    from
        ph_fitness_creators
    order by
        composite_score desc
    limit 20
)

-- 输出达人联系方式
select
    c.uid,
    c.handle,
    c.follower_count,
    c.composite_score,
    c.new_ter_cate_ids,
    ci.email,
    ci.whatsapp,
    ci.youtube_channel_id,
    ci.twitter_id,
    ci.ins_id,
    ci.facebook,
    ci.line,
    ci.zalo,
    ci.viber_messenger
from
    top_20_creators c
join
    kalo_data_online.ads_creator_info ci
on
    c.uid = ci.uid
where
    ci.partition_day = '2025-04-30'
order by
    c.composite_score desc;
