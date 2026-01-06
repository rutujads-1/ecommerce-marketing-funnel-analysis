# ecommerce-marketing-funnel-analysis


Analyzed e-commerce marketing performance using session-level data to evaluate acquisition channels, campaign efficiency, and funnel health. Built SQL models and BI dashboards to identify conversion drivers, drop-offs, and optimization opportunities across channels.



# Table of contents

1. Project Background

2. Data Structure and Overview

3. Executive Summary

4. Insights Deep Dive

5. Recommendations

6. Assumptions and Caveats

7. Appendix Summary 



# Background and Overview

This analysis is conducted using an e-commerce database for Fuzzy Factory, an online retailer that has sold teddy bears since 2012 and has progressively expanded and diversified its product offerings over time. The business relies heavily on digital marketing to drive traffic, customer acquisition, and revenue growth.


The primary objective of this analysis is to **support profitable revenue growth** and is intended to support two primary business audiences:

1. **Marketing and Growth teams**, responsible for acquisition strategy, campaign optimization, and channel investment decisions.

2. **E-commerce and Conversion Optimization teams**, responsible for improving on-site user experience, reducing funnel friction, and increasing conversion efficiency.


Insights and recommendations are developed in the following areas-

**1. Executive Performance Overview:** evaluates overall business scale, growth, and efficiency using *website sessions,orders and gross revenue,conversion rate(CVR) and revenue per session(RPS)*.

**2. Acquisition Channel Performance:** assesses how different marketing channels contribute to volume and efficiency using *sessions, orders, and revenue by channel,conversion rate by channel and revenue per session by channel*.

**3. Campaign Performance:**  Compares campaign performance within a channel using _sessions, orders, conversion rate, RPS, and gross revenue_ to highlight what is working best.

**4. Paid Funnel Health (brand vs nonbrand):** Evaluates the performance of Paid Search campaigns by comparing brand and nonbrand traffic through the conversion funnel, with a focus on identifying differences in intent, efficiency, and friction across key funnel stages. This analysis uses both outcome metrics and funnel diagnostics, including- *brand and nonbrand funnel conversion rates,conversion rate gap (percentage points) between brand and nonbrand traffic,funnel entry rates and stage-level drop-offs and checkout completion rates*.

**5. Unpaid Channel Funnel Health(organic and direct):** evaluates funnel performance for Direct and Organic traffic analysing  funnel behavior across both channels  using *funnel conversion rates for direct and organic traffic, conversion rate gap (percentage points) between direct and organic channels, stage-level funnel drop-off percentages and checkout completion rates*.


link for dashboard:

link for sql query:






# Data Structure and Overview 




Fuzzy Factory's database structure as seen below consists of 6 tables- `orders`, `order_items`,`order_item_refunds`,`products`, `website_sessions` and `website_pageviews` with a total of 1,735,068 records. 

<br>
<br>

<p align="center">
  <img src="images/ERD.png" alt="ERD" width="600">
</p>

<br>
<br>



Prior to the analysis, exploratory data analysis (EDA) was performed for quality control and familirization with the datasets. The SQL queries utilised for intital EDA can be found here- 


**Dataset modelling and simplification**

The dataset was simplified using SQL views to remove unnecessary attributes and structure the data specifically for analysis and visualisation.  

All dashboards and insights are based on these analytical views rather than the raw source tables.

Views Used:

1. `view_fact_table_sessions` – Session-level view with derived marketing channels and device attributes
    
2.  `view_fact_orders` – Order-level view including gross revenue, refunds, net revenue, and profit metrics
   
3. `view_funnelsessiontable` – Funnel progression flags across key website stages
  
4. `vw_dim_products` – Product dimension with product names and launch dates
  
5. `vw_bridged_converted_sessions` – Bridge view identifying sessions that resulted in an order


<br>
<br>

<p align="center">
  <img src="images/sql_views_BI.png" alt="Views" width="600">
</p>

<br>
<br>


# Executive Summary
<br>
<br>


<div align="center">
  <img src="images/exec_traffic_dist.png" width="30%" />
  
</div>

<br/>


<div align="center">
  <img src="images/exec_summ_sessions_orders_movement.png" width="45%",style="display:inline-block;" />
  <img src="images/exec_summ_convr_sessions.png" width="45%" ,style="display:inline-block;"/>
</div>


<br>
<br>



Between 2012 and 2014, the business recorded approximately **409K website sessions**, resulting in **27K orders** and **$1.6M in gross revenue**. Paid Search was the dominant acquisition channel, accounting for roughly **81%** of total website traffic.

Website sessions increased steadily over the three-year period, coinciding with new product launches. Importantly, order volumes scaled proportionally with traffic growth, indicating that higher session volumes translated into tangible business outcomes rather than superficial traffic gains.

Across acquisition channels, overall conversion performance  improved year over year, suggesting that traffic quality was maintained as the business scaled.

A pronounced surge in both sessions and orders was consistently observed during the Q3–Q4 period across all years. I hypothesize this pattern is driven by holiday season demand, supported by the fact that conversion rates during Q3–Q4 either increased or remained stable, indicating sustained user intent. This trend was particularly evident in Paid Search, the primary traffic driver, which suggests an influx of higher-intent users toward year-end.

Overall, the data suggests that traffic growth did not dilute user intent. Instead, the business appears to have successfully scaled acquisition while continuing to attract and convert high-intent customers, particularly during peak seasonal periods.

Given the strong year-over-year growth in traffic, orders, and conversion rate — alongside the heavy reliance on paid search which raises questions around efficiency, scalibility and dependency risk — the next step is to evaluate performance at the acquisition channel level.


Channel-level analysis will assess whether growth was driven by efficient, high-intent channels or by sheer traffic volume, identify relative channel effectiveness, and surface opportunities to optimize or diversify acquisition strategy.



# Insights Deep Dive

## Channel Performance

Website traffic is segmented into four acquisition channels based on the dataset: **Paid Search, Organic, Direct, and Paid Social**. Paid Search, Organic, and Direct channels are present throughout the analysis period (2012–2014), while Paid Social was introduced in 2014.

Channel performance is evaluated using a combination of efficiency and revenue metrics, including: conversion rate, gross revenue generated and revenue per session.

This analysis compares how each channel contributes to traffic scale, conversion efficiency, and revenue generation, providing a foundation for identifying channels that drive volume versus those that deliver higher efficiency.

**Conversion Rate By Channel**

<br>
<br>

<p align="center">
  <img src="images/channle_perf_cvr.png" alt="CVR by channel" width="650">
</p>

<br>
<br>


Conversion rates across channels have increased over time, with Organic (7.4%) and Direct(7%) performing at levels comparable to Paid Search(6.6%), despite Paid operating at significantly higher traffic volumes. In my view, this parity suggests that traffic scale alone is not driving conversion performance, and highlights the need to examine funnel efficiency and stage-level behavior rather than relying solely on aggregate conversion metrics.



**Gross Revenue By Channel**

<br>
<br>

<p align="center">
  <img src="images/gross_revenue_channel_perf.png" alt="Gross Rev by Channel" width="650">
</p>

<br>
<br>

Gross revenue trends closely track order volume, with Paid Search generating the highest total revenue ($1.28M) due to its ability to scale traffic. In contrast, Organic and Direct contribute lower absolute revenue primarily as a function of lower session volumes, rather than weaker per-session performance. This indicates that differences in revenue contribution across channels are volume-driven rather than efficiency-driven.




**Revenue per session**
<br>
<br>

<p align="center">
  
  <img src="images/channel_perf_RPS.png" alt="RPS by Channel" width="650">
  
</p>

<br>
<br>


Revenue per session is broadly comparable across Paid ($3.88), Organic ($4.40), and Direct ($4.23) channels, indicating that sessions from each source generate similar economic value. Notably, Organic and Direct maintain this level of revenue efficiency despite substantially lower traffic volumes, reinforcing my interpretation that these channels represent high-intent, high-efficiency acquisition sources



Channel-level analysis indicates that traffic scaling and session quality were not mutually exclusive over the period analyzed. Paid Search successfully scaled traffic, orders, and revenue without a clear decline in revenue efficiency, while Organic and Direct channels demonstrated strong conversion efficiency and comparable revenue per session despite lower traffic volumes.

In my view, overall growth was therefore driven by a combination of scalable paid acquisition and high-intent, high-efficiency non-paid channels, with aggregate performance metrics masking underlying funnel constraints that warrant deeper stage-level and campaign-level analysis.




## Campaign Performance

highlighting the need for deeper campaign-level analysis to understand differences in brand awareness, user intent, and conversion efficiency between Brand and Non-Brand campaigns.



**Traffic and Order Volume**

<br>
<br>

<div align="center">
  <img src="images/campaign_perf_traffic.png" width="45%",style="display:inline-block;" />
  <img src="images/campaign_perf_orders.png" width="45%" ,style="display:inline-block;"/>
</div>

<br>
<br>

Nonbrand campaigns consistently dominate Paid Search traffic, contributing **approximately 90% of paid sessions** between 2012 and 2014. This higher traffic volume translated into a greater number of orders relative to brand campaigns throughout the period, positioning **nonband as the primary driver of scale** within Paid Search.

In my view, this distribution suggests that a large proportion of demand is captured through generic, nonbrand queries, indicating that **brand awareness** is **not yet the primary entry point** for a large share of users at the top of the funnel.


**Revenue Contribution**
<br>
<br>

<p align="center">
  <img src="images/campaign_perf_gross_rev.png" alt="Gross Rev by campaign" width="500">
</p>

<br>
<br>

Gross revenue increased steadily from 2012 to 2014, with nonbrand campaigns accounting for approximately 88% of Paid Search revenue. This indicates that revenue growth within Paid Search was largely scale-driven, fueled by higher traffic volumes from nonbrand acquisition rather than superior per-session efficiency.


**Conversion Efficiency**

<br>
<br>

<p align="center">
  <img src="images/campaign_perf_cvr.png" alt="CVR by campaign" width="500">
</p>

<br>
<br>

Despite lower traffic volumes, brand campaigns consistently achieved higher conversion rates than nonbrand campaigns across all years. This pattern reflects stronger purchase intent among brand users, as searches containing the brand name are more likely to originate from users already familiar with the product and closer to conversion.

**Revenue per Session (RPS)**

 <br>
<br>

<p align="center">
  <img src="images/channel_perf_RPS.png" alt="RPS by campaign" width="500">
</p>

<br>
<br>

Across all four product categories, brand campaigns generated higher revenue per session than nonbrand campaigns. This further reinforces the conclusion that brand traffic is more efficient at monetization once acquired, even though it contributes a smaller share of overall traffic.


Together, these findings highlight a clear trade-off within Paid Search: nonbrand campaigns drive scale and revenue growth, while brand campaigns deliver superior efficiency and monetization per session.


### Drivers of Campaign Performance Differences

Further breakdown of campaign performance indicates that device type and ad content contribute meaningfully to observed differences in conversion and order volume.

**Device Type**

Across nonbrand and brand campaigns, **desktop traffic** consistently outperformed mobile traffic in terms of conversion rate, order volume, and revenue generation. While mobile sessions contributed incremental traffic, lower conversion rates suggest that device experience plays a role in overall campaign efficiency.



**Ad Content (UTM Content)**

Comparison of Google and Bing ad variations within both brand and nonbrand campaigns shows that **Bing ads** consistently achieved comparable or higher conversion rates and revenue per session despite significantly lower traffic volumes. This suggests that Bing ads attract higher-intent users but suffer from limited reach relative to Google ads. 


These patterns indicate that campaign performance differences are influenced not only by traffic volume, but also by device experience and ad-level targeting, highlighting opportunities for optimization beyond budget allocation alone.


While campaign-level analysis explains acquisition performance, it does not capture how users progress through the conversion journey. The analysis therefore moves to funnel-level evaluation across paid and non-paid channels.


## Funnel Analysis (Brand vs Nonbrand)

To identify where improvements in conversion performance can be most effectively achieved, funnel analysis is applied to Paid Search sessions, segmented into Brand and Non-Brand campaigns. 

The objective of this analysis is to determine which stages of the purchase funnel exhibit the highest drop-offs and therefore represent the greatest opportunities for optimization.For clarity, the funnel is defined as follows:

1. **Top of funnel:** Landing pages and product listing/discovery pages


2. **Middle of funnel:** Product detail pages and add-to-cart interactions


3. **Bottom of funnel:** Checkout experience, including shipping, billing, and order completion


<br>
<br>


<div align="center">
  <img src="images/NB campaign funnel.png" width="45%",style="display:inline-block;" />
  <img src="images/Brand Campaign Funnel.png" width="45%" ,style="display:inline-block;"/>
</div>


<br>
<br>

<br>


<div align="center">
  <img src="images/nb_b_dropoff.png" width="85%" />
  
</div>

<br/>



**1. Top of the Funnel**

Significant top-of-funnel drop-off is observed across both brand (~40%) and non-brand (~46%) traffic, with **nearly half of users failing to reach product pages**. This highlights a clear opportunity to optimize landing pages, particularly in how quickly and clearly products are surfaced.

**The drop-off is more pronounced on mobile devices**, suggesting that mobile usability, page load performance, or content hierarchy may be key drivers of early-stage attrition.

**2. Middle of the funnel**


The middle funnel exhibits significant attrition at the add-to-cart stage, with approximately **55% drop-off** observed across both **brand and non-brand traffic**. This indicates that a substantial share of users disengage at the product detail page level, failing to translate browsing interest into purchase intent.

While higher attrition among **non-brand traffic** is generally expected due to lower baseline intent, the fact that **brand traffic exhibits a comparable drop-off** is unexpected. Given that brand searches typically reflect stronger purchase intent, this pattern suggests that **product page experience, pricing perception, or value communication** may be constraining conversion even among high-intent users.

To validate this hypothesis, repeat-session behavior within **Brand Search** was examined. Despite approximately **63% of brand sessions being repeat visits**, add-to-cart drop-off remains nearly identical for **repeat (55.02%) and non-repeat sessions (55.26%)**. This parity strongly indicates that mid-funnel loss is **experience-driven rather than intent-driven**, reinforcing the need for targeted improvements at the product page level.


**3. Bottom of the Funnel**

The bottom of the funnel shows meaningful attrition during the checkout stage across nonbrand and brand, indicating potential friction within the checkout experience, particularly across shipping and billing steps.

Device-level analysis suggests that **checkout abandonment varies significantly by device**. Desktop users exhibit lower drop-off rates overall (45% for brand, 48% for non-brand) compared to mobile users, where abandonment is substantially higher (64% for brand, 61% for non-brand).

This disparity supports the hypothesis that device experience plays a material role in checkout completion, with mobile users likely encountering greater friction during shipping and payment flows. Potential contributors include form complexity, page load performance, input usability, or payment method availability on mobile devices.




## Funnel Analysis (Organic and Direct)

To evaluate whether Organic and Direct traffic can be scaled without compromising conversion efficiency, funnel analysis was applied to unpaid acquisition channels. The assessment examines stage-level progression and drop-offs within the purchase funnel to determine whether growth constraints stem from acquisition volume or funnel performance.


<br>
<br>


<div align="center">
  <img src="images/Direct Channel Funnel.png" width="45%",style="display:inline-block;" />
  <img src="images/Organic Channel Funnel.png" width="45%" ,style="display:inline-block;"/>
</div>


<br>
<br>

<br>


<div align="center">
  <img src="images/direct&org_dropoff.png" width="85%" />
  
</div>

<br/>

Initial funnel validation shows broadly consistent stage-level patterns across Organic and Direct traffic. However, deeper analysis reveals that mid-funnel attrition at the add-to-cart stage remains persistently high, and critically, this drop-off persists among repeat sessions, which account for a substantial share of traffic (61% for Organic and 64% for Direct).

The presence of significant mid-funnel loss among repeat and brand-aware users indicates that conversion inefficiencies are not primarily driven by lack of intent or awareness, but are instead concentrated at the product-to-cart transition. As a result, while Organic and Direct channels are often constrained by limited traffic supply, the data suggests that scaling acquisition alone would amplify existing funnel leakage rather than deliver proportional gains.

These findings indicate that mid-funnel optimization—particularly improving add-to-cart performance—is a prerequisite for efficient scaling within Organic and Direct channels.


# Recommendations 

**1. Landing Page Optimization (Top of Funnel)**

Analysis indicates substantial top-of-funnel drop-off across channels, suggesting that a significant share of users do not progress from landing pages to product discovery. 

This highlights the need to optimize landing pages to more effectively surface products, align messaging with user intent, and reduce early-stage friction. Improvements in content hierarchy, load performance, and clarity of value proposition could help increase progression into the product exploration stage.

**2. Product Page Optimization (Mid Funnel)**

Persistent mid-funnel attrition at the add-to-cart stage, including among repeat and brand-aware users, indicates that product detail pages are a critical bottleneck in the purchase journey. 

Optimization efforts should focus on improving product information clarity, pricing and value perception, and add-to-cart usability to better convert existing interest into purchase intent. Addressing these issues is a necessary prerequisite before scaling acquisition can be expected to deliver proportional gains.

**3. Checkout Optimization by Device (Bottom of Funnel)**
   
Checkout attrition is significantly higher on mobile devices compared to desktop across both brand and non-brand traffic, indicating that device-specific friction is a key contributor to bottom-of-funnel loss. Given that mobile users abandon checkout at materially higher rates, optimization efforts should prioritize the mobile checkout experience.

Recommended focus areas include simplifying shipping and billing forms, reducing input effort through autofill and address lookup, improving mobile page load performance, and expanding mobile-friendly payment options (e.g., digital wallets). Improving mobile checkout usability is likely to yield disproportionate gains in order completion, particularly given the volume of mobile traffic entering the funnel.


**Estimated Impact**

Applying a conservative benchmark-based scenario—improving checkout completion for Non-Brand traffic from ~49.6% to 55% while holding traffic and average order value constant—suggests a potential ~10–11% increase in Non-Brand revenue. 

Based on observed Non-Brand revenue of approximately $1.35M over the analysis period, this represents an estimated **$145K in incremental revenue without additional acquisition spend.**


 

# Assumptions and Caveats 

Impact estimates are based on conservative industry benchmarks and assume constant traffic volume, stable average order value, and improvement at a single funnel stage; results are directional and reflect associations observed in session-level data rather than causal effects.






   
