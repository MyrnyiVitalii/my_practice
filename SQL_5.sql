		--CTE
with four_tables AS(
select 	ad_date,
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
select ad_date,
	url_parameters,
	coalesce(spend,0) as spend,
	coalesce(impressions,0) as impressions,
	coalesce(reach,0) as reach,
	coalesce(clicks,0) as clicks,
	coalesce(leads,0) as leads,
	coalesce(value,0) as value
from public.google_ads_basic_daily
)
		--Main
SELECT ad_date,
	SUM(spend::numeric) as spend_sum,
	SUM(impressions::numeric) as impressions_sum,
	SUM(clicks::numeric) as clicks_sum,
	SUM(value::numeric) as value_sum,
		--substring з регулярним виразом
lower(SUBSTRING(url_parameters,CASE
        WHEN url_parameters ~* 'campaign=nan' THEN NULL
        ELSE url_parameters
        end)) as url_parameters,
		--case for romi
	case 
when SUM(spend::numeric) > 0 then ROUND(((SUM(value::numeric)-SUM(spend::numeric)) / SUM(spend::numeric))*100,2)
else null
end as ROMI,
		--case for cpm
	case 
when SUM(impressions::numeric) > 0 then ROUND((SUM(spend::numeric) / SUM(impressions::numeric))*1000,2)
else null
end as CPM,
		--case for ctr
	case 
when SUM(impressions::numeric) > 0 then ROUND((SUM(clicks::numeric) / SUM(impressions::numeric))*100,2)
else null
end as CTR,
		--case for cpc
	case 
when SUM(clicks::numeric) > 0 then ROUND(SUM(spend::numeric) / SUM(clicks::numeric),2)
else null
end as CPC
from four_tables
group by 1,6;


