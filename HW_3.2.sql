														--CTE #1

with fb_3tables AS(
	select 
		ad_date,
		'Facebook' as media_source,
		campaign_name,
		adset_name,
		spend,
		impressions,
		reach,
		clicks,
		leads,
		value
from public.facebook_ads_basic_daily
left join public.facebook_adset using(adset_id)
left join public.facebook_campaign using(campaign_id)
),
														--CTE #2
four_tables AS (
	select ad_date,
		campaign_name,
		'Facebook' as media_source,
		adset_name,
		spend,
		impressions,
		reach,
		clicks,
		leads,
		value
	from fb_3tables
		union
	select ad_date,
		campaign_name,
		'Google' as media_source,
		adset_name,
		spend,
		impressions,
		reach,
		clicks,
		leads,
		value
	from public.google_ads_basic_daily
)
															-- Основная часть
select ad_date,
	media_source,
	campaign_name,
	adset_name,
	SUM(spend) as spend_sum,
	SUM(impressions) as impressions_sum,
	SUM(clicks) as clicks_sum,
	SUM(value) as value_sum
from four_tables
group by 1, 2, 3, 4;