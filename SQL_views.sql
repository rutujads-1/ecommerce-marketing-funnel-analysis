---creating views for power bi---


-- View 1: sessions--

CREATE OR REPLACE VIEW view_fact_table_sessions AS
WITH s AS (
  SELECT
    website_session_id,
    created_at,
    user_id,
    device_type,
    utm_source,
    utm_campaign,
    utm_content,
    http_referer,
	is_repeat_session
  FROM website_sessions
)
SELECT
  website_session_id,
  created_at::date AS session_date,
  user_id,
  device_type,

  CASE
    WHEN utm_source = 'socialbook' AND utm_campaign <>'NULL'  AND utm_content <>'NULL' AND http_referer <>'NULL' THEN 'Paid Social'
    WHEN utm_source <>'NULL' AND utm_source <> 'socialbook' AND utm_campaign <>'NULL' AND utm_content <>'NULL' AND http_referer <>'NULL'THEN 'Paid'
    WHEN utm_source='NULL' AND utm_campaign='NULL' AND utm_content='NULL' AND http_referer<>'NULL' THEN 'Organic'
    WHEN utm_source='NULL' AND utm_campaign='NULL' AND utm_content='NULL' AND http_referer='NULL' THEN 'Direct'
    ELSE 'Other'
  END AS primary_channel,

  utm_source,
  utm_campaign,
  utm_content,
  http_referer,
  is_repeat_session
FROM s;


-- view 2: orders--

CREATE OR REPLACE VIEW view_fact_orders AS
WITH refunds AS (
  SELECT
    order_id,
    SUM(refund_amount_usd) AS refund_amount_usd
  FROM order_item_refunds
  GROUP BY order_id
)
SELECT
  o.order_id,
  o.website_session_id,
  o.user_id,
  o.created_at::date AS order_date,
  o.primary_product_id,
  o.items_purchased,

  o.price_usd AS gross_revenue_usd,
  o.cogs_usd  AS cogs_usd,
  COALESCE(r.refund_amount_usd,0) AS refunds_usd,

  (o.price_usd - COALESCE(r.refund_amount_usd,0)) AS net_revenue_usd,
  (o.price_usd - COALESCE(r.refund_amount_usd,0) - o.cogs_usd) AS gross_profit_usd
FROM orders o
LEFT JOIN refunds r
  ON o.order_id = r.order_id;

-- view 3: converted sessions--

CREATE OR REPLACE VIEW vw_bridged_converted_sessions AS
SELECT DISTINCT
  website_session_id,date_created_at
FROM website_pageviews
WHERE pageview_url = '/thank-you-for-your-order';




--- view 4: funnel sessions table ---
CREATE OR REPLACE VIEW view_funnelsessiontable AS
WITH pv AS (
  SELECT
    website_session_id,
    1 AS has_pageviews,

    MAX((pageview_url IN ('/lander-1','/lander-2','/lander-3','/lander-4','/lander-5','/home'))::int) AS saw_landing,
    MAX((pageview_url = '/products')::int) AS saw_products,
    MAX((pageview_url IN (
      '/the-original-mr-fuzzy',
      '/the-forever-love-bear',
      '/the-birthday-sugar-panda',
      '/the-hudson-river-mini-bear'
    ))::int) AS saw_any_product,
    MAX((pageview_url = '/cart')::int) AS saw_cart,
    MAX((pageview_url = '/shipping')::int) AS saw_shipping,
    MAX((pageview_url IN ('/billing','/billing-2'))::int) AS saw_billing,
    MAX((pageview_url = '/thank-you-for-your-order')::int) AS saw_thankyou
  FROM website_pageviews
  GROUP BY website_session_id
)
SELECT
  s.website_session_id,
  s.session_date,
  s.primary_channel,
  s.device_type,
  s.utm_campaign,

  COALESCE(pv.saw_landing, 0)     AS saw_landing,
  COALESCE(pv.saw_products, 0)    AS saw_products,
  COALESCE(pv.saw_any_product, 0) AS saw_any_product,
  COALESCE(pv.saw_cart, 0)        AS saw_cart,
  COALESCE(pv.saw_shipping, 0)    AS saw_shipping,
  COALESCE(pv.saw_billing, 0)     AS saw_billing,
  COALESCE(pv.saw_thankyou, 0)    AS saw_thankyou,

  COALESCE(pv.has_pageviews, 0)   AS has_pageviews,
  s.is_repeat_session
FROM view_fact_table_sessions s
LEFT JOIN pv
  ON s.website_session_id = pv.website_session_id;



-- view 5: product dimension view--
CREATE OR REPLACE VIEW vw_dim_products AS
SELECT
  product_id,
  created_at::date AS product_launch_date,
  product_name
FROM products;
