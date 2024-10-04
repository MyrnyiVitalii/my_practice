WITH cte AS (
SELECT 
        ad_date,
        'facebook_ads' AS media_source,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM facebook_ads_basic_daily
UNION ALL
SELECT 
        ad_date,
        'google_ads' AS media_source,
        spend,
        impressions,
        reach,
        clicks,
        leads,
        value
    FROM google_ads_basic_daily)
select ad_date,
    media_source,
    SUM(spend) AS spend_sum,
    SUM(impressions) AS impressions_sum,
    SUM(reach) AS reach_sum,
    SUM(clicks) AS clicks_sum,
    SUM(leads) AS leads_sum,
    SUM(value) AS value_sum
FROM
    cte
GROUP BY
    ad_date, media_source;