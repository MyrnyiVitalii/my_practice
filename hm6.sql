with four_tables AS(
select
	ad_date,
	url_parameters,
	coalesce(spend,0) as spend,
	coalesce(impressions,0) as impressions,
	coalesce(reach,0) as reach,
	coalesce(clicks,0) as clicks,
	coalesce(leads,0) as leads,
	coalesce(value,0) as value
from public.facebook_ads_basic_daily
left join public.facebook_adset USING(adset_id)
left join public.facebook_campaign USING(campaign_id)
union 
select
	ad_date,
	url_parameters,
	coalesce(spend,0) as spend,
	coalesce(impressions,0) as impressions,
	coalesce(reach,0) as reach,
	coalesce(clicks,0) as clicks,
	coalesce(leads,0) as leads,
	coalesce(value,0) as value
from public.google_ads_basic_daily
),four_tables_sum_and_metrics as(
select
	date_trunc('month', ad_date) as ad_month,
	lower(SUBSTRING(url_parameters,CASE
										WHEN url_parameters ~* 'campaign=nan' THEN null
        								ELSE lower(SUBSTRING(url_parameters,'utm_campaign=([^&]*)'))
        							end)) as utm_campaign,
	SUM(spend) as spend_sum,
	SUM(impressions) as impressions_sum,
	SUM(reach) as reach_sum,
	SUM(clicks) as clicks_sum,
	SUM(leads) as leads_sum,
	SUM(value) as value_sum,
	case 
		when SUM(spend::numeric) != 0
		then ROUND(((SUM(value::numeric)-SUM(spend::numeric)) / SUM(spend::numeric))*100,2)
		else null
	end as ROMI,
	case 
		when SUM(impressions::numeric) != 0
		then ROUND((SUM(spend::numeric) / SUM(impressions::numeric))*1000,2)
		else null
	end as CPM,
	case 
		when SUM(impressions::numeric) != 0
		then ROUND((SUM(clicks::numeric) / SUM(impressions::numeric))*100,2)
		else null
	end as CTR,
	case 
		when SUM(clicks::numeric) != 0
		then ROUND(SUM(spend::numeric) / SUM(clicks::numeric),2)
		else null
	end as CPC
from four_tables
group by 1,2
),four_tables_windows as(
select
	ad_month,
	utm_campaign,
	spend_sum,
	impressions_sum,
	clicks_sum,
	value_sum,
	CTR,
	CPC,
	CPM,
	ROMI,
	LAG(romi) over (partition by utm_campaign order by ad_month) as diff_ROMI_lag,
	LAG(CPM) over (partition by utm_campaign order by ad_month) as diff_CPM_lag,
	LAG(CTR) over (partition by utm_campaign order by ad_month) as diff_CTR_lag
from four_tables_sum_and_metrics
)select ad_month,
	utm_campaign,
	spend_sum,
	impressions_sum,
	clicks_sum,
	value_sum,
	CTR,
	CPC,
	CPM,
	ROMI,
	diff_ROMI_lag,
	diff_CPM_lag,
	diff_CTR_lag
from four_tables_windows;