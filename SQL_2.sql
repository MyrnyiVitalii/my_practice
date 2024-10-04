select ad_date
	,campaign_id
	,SUM(spend) as spend_sum
	,sum(impressions) as impressions_sum
	,sum(clicks) as clicks_sum
	,SUM(value) as value_sum
	,SUM(spend::float) / SUM(clicks::float) as Cost_per_click_CPC
	,SUM(spend::float) / SUM(impressions::float)*1000 as Cost_per_mille_CPM
	,(SUM(clicks::float) / SUM(impressions::float))*100 as Click_through_rate_CTR
	,(SUM(value::float) - SUM(spend::float))/SUM(spend::float)*100	as ROMI
FROM public.facebook_ads_basic_daily
where
	spend > 0
	and clicks > 0
	and impressions > 0
	and value > 0
group by 1,2;


--Додаткове завдання

select campaign_id
	, SUM(spend::float) as spend_sum
	, SUM (value::float) as value_sum
	,(SUM(value::float) - SUM(spend::float))/SUM(spend::float)*100 as romi
FROM public.facebook_ads_basic_daily
group by 1
having sum(spend) > 500000
order by sum(spend) desc
limit 1;
