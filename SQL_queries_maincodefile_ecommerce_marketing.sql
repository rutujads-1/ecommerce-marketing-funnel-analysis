-- Table Creation--
CREATE TABLE IF NOT EXISTS public.orders
(
    order_id INTEGER PRIMARY KEY,
    created_at TIMESTAMP,
    website_session_id INTEGER,
    user_id INTEGER,
    primary_product_id INTEGER,
    items_purchased INTEGER,
    price_usd NUMERIC(10,2),
    cogs_usd NUMERIC(10,2),
    order_placed_at DATE
);

DROP TABLE IF EXISTS public.orders;

CREATE TABLE IF NOT EXISTS public.orders
(
    order_id INTEGER PRIMARY KEY,
    created_at TIMESTAMP,
    website_session_id INTEGER,
    user_id INTEGER,
    primary_product_id INTEGER,
    items_purchased INTEGER,
    price_usd NUMERIC(10,2),
    cogs_usd NUMERIC(10,2),
    order_placed_at DATE
);

SELECT COUNT(*) FROM orders;

select *
from orders
limit 5;

CREATE TABLE order_items (
    order_item_id     INTEGER PRIMARY KEY,
    created_at        TIMESTAMP,
    order_id          INTEGER,
    product_id        INTEGER,
    is_primary_item   BOOLEAN,
    price_usd         NUMERIC(10,2),
    cogs_usd          NUMERIC(10,2),
    date_created_at   DATE
);

select count(*)
from order_items;

select *
from order_items
limit 5;

CREATE TABLE public.order_item_refunds (
    order_item_refund_id INTEGER PRIMARY KEY,
    created_at           TIMESTAMP,
    order_item_id        INTEGER,
    order_id             INTEGER,
    refund_amount_usd    NUMERIC(10,2),
    date_created_at      DATE
);

select count(*)
from order_item_refunds;

CREATE TABLE public.products (
    product_id   INTEGER PRIMARY KEY,
    created_at   TIMESTAMP,
    product_name VARCHAR(255)
);

select count(*)
from products;

CREATE TABLE public.website_sessions (
    website_session_id INTEGER PRIMARY KEY,
    created_at         TIMESTAMP,
    user_id            INTEGER,
    is_repeat_session  BOOLEAN,
    utm_source         VARCHAR(255),
    utm_campaign       VARCHAR(255),
    utm_content        VARCHAR(255),
    device_type        VARCHAR(50),
    http_referer       VARCHAR(500),
    date_created_at    DATE
);

select count(*)
from website_sessions;

CREATE TABLE public.website_pageviews (
    website_pageview_id INTEGER PRIMARY KEY,
    created_at          TIMESTAMP NOT NULL,
    website_session_id  INTEGER NOT NULL,
    pageview_url        VARCHAR(255) NOT NULL,
    date_created_at     DATE NOT NULL,
    
    CONSTRAINT fk_pageviews_session
        FOREIGN KEY (website_session_id)
        REFERENCES public.website_sessions(website_session_id)
);

select count(*)
from website_pageviews;

ALTER TABLE public.orders
ADD CONSTRAINT fk_orders_session
FOREIGN KEY (website_session_id)
REFERENCES public.website_sessions(website_session_id);


ALTER TABLE public.orders
ADD CONSTRAINT fk_orders_product
FOREIGN KEY (primary_product_id)
REFERENCES public.products(product_id);

ALTER TABLE public.order_items
ADD CONSTRAINT fk_orderitems_order
FOREIGN KEY (order_id)
REFERENCES public.orders(order_id);

ALTER TABLE public.order_items
ADD CONSTRAINT fk_orderitems_product
FOREIGN KEY (product_id)
REFERENCES public.products(product_id);

ALTER TABLE public.order_item_refunds
ADD CONSTRAINT fk_refunds_orderitem
FOREIGN KEY (order_item_id)
REFERENCES public.order_items(order_item_id);

ALTER TABLE public.order_item_refunds
ADD CONSTRAINT fk_refunds_order
FOREIGN KEY (order_id)
REFERENCES public.orders(order_id);

-- end of table creation--


--Initial Exploration--

-- total orders

SELECT COUNT(*) FROM public.orders;

-- total revenue
SELECT SUM(price_usd) FROM public.order_items;

-- total returns
SELECT COUNT(*) FROM public.order_item_refunds;

-- total amount refunded

SELECT SUM(refund_amount_usd) FROM public.order_item_refunds;

-- total sessions
SELECT COUNT(*) FROM public.website_sessions;

-- total pageviews
SELECT COUNT(*) FROM public.website_pageviews;

-- total unique users
SELECT COUNT(DISTINCT user_id) FROM public.website_sessions;

-- avg session per users
SELECT COUNT(*)::numeric / COUNT(DISTINCT user_id)
FROM public.website_sessions;

--

-- Further EDA--
--- channel wise analysis--
with channels as (
  select
    website_session_id,
    created_at::date as session_date,
    user_id,
    device_type,

    case
      when utm_source = 'socialbook' and utm_campaign <> 'NULL' and utm_content <> 'NULL' and http_referer <> 'NULL' then 'Paid Social'
      when utm_source <> 'NULL' and utm_source <> 'socialbook' and utm_campaign <> 'NULL' and utm_content <> 'NULL' and http_referer <> 'NULL' then 'Paid'
      when utm_source = 'NULL' and utm_campaign = 'NULL' and utm_content = 'NULL' and http_referer <> 'NULL' then 'Organic'
      when utm_source = 'NULL' and utm_campaign = 'NULL' and utm_content = 'NULL' and http_referer = 'NULL' then 'Direct'
      else 'Other'
    end as primary_channel
  from website_sessions
),

channel_orders as (
  select
    c.primary_channel,
    c.website_session_id,
    o.order_id,
    o.price_usd
  from channels c
  left join orders o
    on c.website_session_id = o.website_session_id
)

select
  primary_channel,
  count(distinct website_session_id) as session_counts,
  count(distinct order_id) as order_counts,
  sum(coalesce(price_usd, 0)) as total_revenue,
  round(
    count(distinct order_id) * 1.0 / nullif(count(distinct website_session_id), 0),
    4
  ) as session_to_order_cvr,
  round(
    sum(coalesce(price_usd, 0)) * 1.0 / nullif(count(distinct website_session_id), 0),
    2
  ) as revenue_per_session
from channel_orders
group by primary_channel
order by session_counts desc;


-- paid channel exploration--
-- non brand website sessions year on year
select extract(year from date_created_at) as yr,count(*) as no_of_nonbrand_sessions
from website_sessions
where utm_campaign='nonbrand'
group by extract(year from date_created_at)
order by yr asc;

-- brand website sessions year on year
select extract(year from date_created_at) as yr,count(*) as no_of_nonbrand_sessions
from website_sessions
where utm_campaign='brand'
group by extract(year from date_created_at)
order by yr asc;

-- conversion rates for paid campaigns

-- non brand campaign
with nonbrand_sessions as (
    select
        extract(year from date_created_at) as yr,
        COUNT(*) as sessions
    from website_sessions
    where utm_campaign = 'nonbrand'
    group by 1
),
nonbrand_orders as (
    select
        extract (year from order_placed_at) as yr,
        COUNT(order_id) as orders
    from orders
    where website_session_id in (
        select website_session_id
        from website_sessions
        where utm_campaign = 'nonbrand'
    )
    group by 1
)
select
    s.yr,
    s.sessions,
    o.orders,
    round((o.orders::DECIMAL / s.sessions)*100.0,2) as conversion_rate
from nonbrand_sessions s
left join nonbrand_orders o
    on s.yr = o.yr
order by s.yr;

-- brand campaign

with brand_sessions as (
   select 
        extract(year from date_created_at) as yr,
        COUNT(*) as sessions
    from website_sessions
    where utm_campaign = 'brand'
    group by 1
),
brand_orders as (
    select
        extract(year from order_placed_at) as yr,
        COUNT(order_id) as orders
    from orders
    where website_session_id in (
        select website_session_id
        from website_sessions
        where utm_campaign = 'brand'
    )
    group by 1
)
select
    s.yr,
    s.sessions,
    o.orders,
    round((o.orders::DECIMAL / s.sessions)*100.0,2) as conversion_rate
from brand_sessions s
left join brand_orders o
    on s.yr = o.yr
order by s.yr;

-- newly introduced campaigns 2014--
with nonbrand_sessions as (
    select
        extract(year from date_created_at) as yr,
        COUNT(*) as sessions
    from website_sessions
    where utm_campaign = 'pilot'
    group by 1
),
nonbrand_orders as (
    select
        extract (year from order_placed_at) as yr,
        COUNT(order_id) as orders
    from orders
    where website_session_id in (
        select website_session_id
        from website_sessions
        where utm_campaign = 'pilot'
    )
    group by 1
)
select
    s.yr,
    s.sessions,
    o.orders,
    round((o.orders::DECIMAL / s.sessions)*100.0,2) as conversion_rate
from nonbrand_sessions s
left join nonbrand_orders o
    on s.yr = o.yr
order by s.yr;

--desktoptargetted--
with nonbrand_sessions as (
    select
        extract(year from date_created_at) as yr,
        COUNT(*) as sessions
    from website_sessions
    where utm_campaign = 'desktoptargeted'
    group by 1
),
nonbrand_orders as (
    select
        extract (year from order_placed_at) as yr,
        COUNT(order_id) as orders
    from orders
    where website_session_id in (
        select website_session_id
        from website_sessions
        where utm_campaign = 'desktoptargeted'
    )
    group by 1
)
select
    s.yr,
    s.sessions,
    o.orders,
    round((o.orders::DECIMAL / s.sessions)*100.0,2) as conversion_rate
from nonbrand_sessions s
left join nonbrand_orders o
    on s.yr = o.yr
order by s.yr;

--- reviewing product categories--
-- individual category analysis (clubbed into one)
select
  extract(year from o.order_placed_at) as yr,
  p.product_id,
  p.product_name,
  count(o.order_id) as no_of_orders
from orders o
join products p
  on o.primary_product_id = p.product_id
where p.product_id in (1, 2, 3, 4)
group by
  extract(year from o.order_placed_at),
  p.product_id,
  p.product_name
order by
  yr asc,
  no_of_orders desc;
--- --
with cte1 as (
  select
    w.website_session_id,
    w.utm_campaign,
    o.order_id,
    o.primary_product_id
  from website_sessions w
  join orders o
    on w.website_session_id = o.website_session_id
  where o.primary_product_id in (1, 2, 3, 4)
)
select
  extract(year from oi.date_created_at) as yr,
  c.utm_campaign,
  c.primary_product_id,
  p.product_name,
  count(c.order_id) as total_orders,
  sum(oi.price_usd) as total_revenue
from cte1 c
join order_items oi
  on c.order_id = oi.order_id
  and oi.is_primary_item = 'True'
join products p
  on c.primary_product_id = p.product_id
group by
  extract(year from oi.date_created_at),
  c.utm_campaign,
  c.primary_product_id,
  p.product_name
order by
  yr asc;

---  products vs nonbrand sessions-- 
with nonbrand_sessions as (
  select website_session_id
  from website_sessions
  where utm_campaign = 'nonbrand'
)
select
  extract(year from o.created_at) as yr,
  extract(month from o.created_at) as mnth,
  p.product_name,
  count(o.order_id) as no_of_orders
from orders o
join nonbrand_sessions s
  on o.website_session_id = s.website_session_id
join products p
  on p.product_id = o.primary_product_id
where o.primary_product_id in(1,2,3,4)
  and extract(year from o.created_at) in (2012, 2013, 2014, 2015)
group by
  extract(year from o.created_at),
  extract(month from o.created_at),
  p.product_name
order by
  yr asc,
  mnth asc;

-- Funnels-
-- by prod, year, and brand and nonbrand--

with product_pages as (
  select 1 as primary_product_id, '/the-original-mr-fuzzy' as product_url
  union all select 2, '/the-forever-love-bear'
  union all select 3, '/the-birthday-sugar-panda'
  union all select 4, '/the-hudson-river-mini-bear'
),

sessions as (
  select
    website_session_id,
    extract(year from created_at) as yr,
    utm_campaign
  from website_sessions
  where utm_campaign in ('brand', 'nonbrand')
),

funnel as (
  select
    s.yr,
    s.utm_campaign,
    wp.website_session_id,
    wp.pageview_url,
    dense_rank() over (
      partition by wp.website_session_id
      order by wp.created_at asc
    ) as ordered
  from website_pageviews wp
  join sessions s
    on wp.website_session_id = s.website_session_id
),

session_product as (
  select
    f.yr,
    f.utm_campaign,
    f.website_session_id,
    pp.primary_product_id
  from funnel f
  join product_pages pp
    on f.pageview_url = pp.product_url
  group by
    f.yr,
    f.utm_campaign,
    f.website_session_id,
    pp.primary_product_id
),

pivoted as (
  select
    f.yr,
    f.utm_campaign,
    sp.primary_product_id,
    f.website_session_id,

    max(case when f.ordered = 1 and f.pageview_url = '/home' then 1 else 0 end) as entry_home,
    max(case when f.ordered = 1 and f.pageview_url = '/lander-1' then 1 else 0 end) as landerpg1_entry,
    max(case when f.ordered = 1 and f.pageview_url = '/lander-2' then 1 else 0 end) as landerpg2_entry,
    max(case when f.ordered = 1 and f.pageview_url = '/lander-3' then 1 else 0 end) as landerpg3_entry,
    max(case when f.ordered = 1 and f.pageview_url = '/lander-4' then 1 else 0 end) as landerpg4_entry,
    max(case when f.ordered = 1 and f.pageview_url = '/lander-5' then 1 else 0 end) as landerpg5_entry,

    max(case when f.pageview_url = '/products' then 1 else 0 end) as viewed_prodpg,
    max(case when f.pageview_url in (select product_url from product_pages) then 1 else 0 end) as viewed_product,
    max(case when f.pageview_url = '/cart' then 1 else 0 end) as cart_reached,
    max(case when f.pageview_url = '/shipping' then 1 else 0 end) as prod_shipped,
    max(case when f.pageview_url = '/billing' then 1 else 0 end) as billed,
    max(case when f.pageview_url = '/billing-2' then 1 else 0 end) as billed_page_2,
    max(case when f.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as conversion_done
  from funnel f
  join session_product sp
    on f.website_session_id = sp.website_session_id
    and f.yr = sp.yr
    and f.utm_campaign = sp.utm_campaign
  group by
    f.yr,
    f.utm_campaign,
    sp.primary_product_id,
    f.website_session_id
)

select
  yr,
  utm_campaign,
  primary_product_id,

  sum(entry_home) as users_entered_homepage,
  sum(landerpg1_entry) as users_entered_lander1,
  sum(landerpg2_entry) as users_entered_lander2,
  sum(landerpg3_entry) as users_entered_lander3,
  sum(landerpg4_entry) as users_entered_lander4,
  sum(landerpg5_entry) as users_entered_lander5,
  sum(viewed_prodpg) as users_viewed_product_pg,
  sum(viewed_product) as users_viewed_product,
  sum(cart_reached) as users_in_cart_page,
  sum(prod_shipped) as users_at_shipping,
  sum(billed) as users_at_billing,
  sum(billed_page_2) as users_at_billing_page2,
  sum(conversion_done) as users_converted
from pivoted
group by
  yr,
  utm_campaign,
  primary_product_id
order by
  yr asc,
  utm_campaign,
  primary_product_id;

---  check out: shipping and billing--
with sessions as (
  select
    website_session_id,
    device_type,
    utm_campaign,
    extract(year from created_at) as yr
  from website_sessions
  where utm_campaign in ('brand', 'nonbrand')
    and extract(year from created_at) in (2012, 2013, 2014)
),

funnel_flags as (
  select
    s.website_session_id,
    s.device_type,
    s.utm_campaign,
    s.yr,
    max(case when wp.pageview_url = '/shipping' then 1 else 0 end) as reached_checkout,
    max(case when wp.pageview_url = '/thank-you-for-your-order' then 1 else 0 end) as converted
  from sessions s
  join website_pageviews wp
    on s.website_session_id = wp.website_session_id
  group by
    s.website_session_id,
    s.device_type,
    s.utm_campaign,
    s.yr
)

select
  yr,
  utm_campaign,
  device_type,
  count(case when reached_checkout = 1 then website_session_id end) as checkout_sessions,
  count(case when converted = 1 then website_session_id end) as order_sessions,
  round(
    count(case when converted = 1 then website_session_id end) * 1.0 /
    nullif(count(case when reached_checkout = 1 then website_session_id end), 0),
    3
  ) as checkout_to_order_cvr
from funnel_flags
group by
  yr,
  utm_campaign,
  device_type
order by
  yr asc,
  utm_campaign,
  device_type;


-- analysing product intent(detail) to cart
with sessions as (
  select
    website_session_id,
    device_type,
    utm_campaign,
    extract(year from created_at) as yr
  from website_sessions
  where utm_campaign in ('nonbrand', 'brand')
    and extract(year from created_at) in (2012, 2013, 2014)
),

funnel_flags as (
  select
    s.website_session_id,
    s.device_type,
    s.utm_campaign,
    s.yr,
    max(case
      when wp.pageview_url in (
        '/the-original-mr-fuzzy',
        '/the-birthday-sugar-panda',
        '/the-forever-love-bear',
        '/the-hudson-river-mini-bear'
      ) then 1 else 0 end) as reached_prod_pages,
    max(case when wp.pageview_url = '/cart' then 1 else 0 end) as added_to_cart
  from sessions s
  join website_pageviews wp
    on s.website_session_id = wp.website_session_id
  group by
    s.website_session_id,
    s.device_type,
    s.utm_campaign,
    s.yr
)

select
  yr,
  utm_campaign,
  device_type,
  count(case when reached_prod_pages = 1 then website_session_id end) as prod_detail_sessions,
  count(case when added_to_cart = 1 then website_session_id end) as added_to_cart_sessions,
  round(
    count(case when added_to_cart = 1 then website_session_id end) * 1.0 /
    nullif(count(case when reached_prod_pages = 1 then website_session_id end), 0),
    3
  ) as prod_detail_tocart_cvr
from funnel_flags
group by
  yr,
  utm_campaign,
  device_type
order by
  yr asc,
  utm_campaign,
  device_type;


--- Analysing repeat sessions- because brand search traffic also shows a huge drop off in the middle funnel
select utm_campaign, is_repeat_session,count(website_session_id) as number_of_repeat_users
from website_sessions
where utm_campaign in('nonbrand','brand') and extract(year from created_at)>=2012 and extract(year from created_at)<=2014
group by utm_campaign,is_repeat_session;

  
--estimation--
-- AOV brand
select count(o.order_id) as total_orders_nb, sum(o.price_usd) as revenue_nb,sum(o.price_usd)/count(o.order_id) as AOV_b
from orders o
inner join website_sessions s
on o.website_session_id=s.website_session_id
where s.utm_campaign='brand'
and extract (year from s.created_at)>=2012 and extract (year from s.created_at)<=2014;