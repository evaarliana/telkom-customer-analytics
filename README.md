# Telkomsel Customer Analytics

## Project Overview

This project analyzes customer growth, revenue performance, network experience, and customer retention for a Telkomsel case study developed as part of the Telkomsel × RevoU Virtual Internship. Using customer, subscription, billing, usage, network quality, complaint, and churn data, the analysis identifies business opportunities to improve customer experience, strengthen retention, and support sustainable revenue growth.

**Project Duration:** [Month Year]

---

## Business Problem

Customer and Monthly Recurring Revenue (MRR) continue to grow, but growth momentum is gradually slowing. Meanwhile, differences in network quality, customer complaints, and churn behavior may indicate opportunities to improve customer experience and retention.

How can customer, revenue, network experience, and churn data be used to identify actionable opportunities for sustainable growth and stronger customer retention?

---

## Objectives

- Analyze customer growth, MRR, and ARPU trends over time.
- Identify customer packages that contribute most to customer volume and revenue.
- Evaluate network quality and customer experience across districts.
- Identify churn patterns across contract types, packages, districts, and recorded churn reasons.
- Develop data-driven recommendations to improve customer experience and retention.

---

## Analytical Approach

The analysis follows an end-to-end workflow:

**Data Understanding → Data Quality & Preparation → Exploratory Data Analysis → Dashboard Development → Business Recommendations**

### 1. Data Understanding and Preparation

- Reviewed customer, subscription, billing, usage, network quality, complaint, and churn datasets.
- Used cleaned analytical tables to support consistent customer, revenue, network, and retention analysis.
- Examined data coverage and checked missing district-month combinations in network quality data.

### 2. Exploratory Data Analysis

- Analyzed customer growth, monthly revenue, MRR, ARPU, and package performance using SQL in BigQuery.
- Evaluated network quality scores, latency, downtime, complaint patterns, and customer satisfaction.
- Compared retention and churn across contract types, package speeds, districts, and recorded churn reasons.
- Investigated customer usage behavior to identify potential opportunities for targeted retention and package strategies.

### 3. Dashboard Development

Developed a three-page Power BI dashboard to communicate key findings and support business decision-making.

- **Page 1 — Customer & Revenue Overview:** Customer growth, MRR, ARPU, package performance, and revenue contribution.
- **Page 2 — Network & Customer Experience:** Network quality, latency, downtime, complaints, and customer satisfaction.
- **Page 3 — Customer Retention:** Retention rate, churn trends, churn reasons, and churn patterns across customer segments.

---

## Key Findings

### 1. Customer and Revenue Growth

- The dataset contains **20,000 customers**, with an overall customer retention rate of **90%**.
- Monthly revenue reached approximately **Rp5.17 billion**, while ARPU remained relatively stable at around **Rp260,000 per month**.
- Revenue continued to grow, but monthly revenue growth slowed to **3.49%**, indicating a need to monitor growth momentum.

### 2. Package Performance

- The **50 Mbps package** contributed the largest revenue share at **38.34%**, supported by its large customer base.
- The **200 Mbps package** generated the highest revenue per customer at approximately **Rp4 million**.
- Lower-speed packages contributed to customer volume, while higher-speed packages generated greater revenue per customer.

### 3. Network and Customer Experience

- Average network quality score was **81.68**, with substantial variation across districts.
- Average network downtime was approximately **3.21 hours per customer-month**.
- Network reliability and internet speed were the primary complaint themes.
- Average customer satisfaction among customers who submitted complaints was **3.1 out of 5**, indicating room for improvement.

### 4. Customer Retention and Churn

- The overall churn rate was **10%**, representing **2,000 churned customers**.
- Monthly-contract customers recorded the highest churn rate at **11.49%**, compared with **6.02%** for six-month contracts and **3.18%** for twelve-month contracts.
- Network quality was the leading recorded churn reason, accounting for **43.45%** of churned customers.
- Churn rates varied considerably across districts, highlighting opportunities for more targeted retention initiatives.

---

## Business Recommendations

- **Improve network experience:** Prioritize network monitoring and improvement in districts with elevated churn rates, complaint intensity, or weaker network quality.
- **Strengthen retention initiatives:** Develop targeted retention strategies for monthly-contract customers and other high-churn segments.
- **Optimize package strategies:** Explore suitable package upgrades for customers whose usage patterns indicate potential for higher-value plans.
- **Monitor revenue growth:** Track MRR, ARPU, customer acquisition, and growth momentum together to identify early signs of slowing performance.
- **Integrate customer experience metrics:** Monitor network quality, complaints, satisfaction, and churn together to support more informed retention decisions.

---

## Dashboard

The Power BI dashboard consists of three pages, covering:

- Customer growth, MRR, ARPU, and package revenue contribution
- Network quality, latency, downtime, complaints, and customer satisfaction
- Customer retention, churn trends, and churn patterns across customer segments

### Page 1 — Customer & Revenue Overview

![Customer & Revenue Overview](./dashboard/Page%201%20%E2%80%94%20Customer%20%26%20Revenue%20Overview.jpg)

### Page 2 — Network & Customer Experience

![Network & Customer Experience](./dashboard/Page%202%20%E2%80%94%20Network%20%26%20Customer%20Experience.jpg)

### Page 3 — Customer Retention

![Customer Retention](./dashboard/Page%203%20%E2%80%94%20Customer%20Retention.jpg)

---

## Tools

- SQL
- Google BigQuery
- Power BI
- Data Cleaning & Preparation
- Exploratory Data Analysis (EDA)
- Data Visualization
- Business Analysis

---

## Project Files

| File | Description |
|---|---|
| `analysis/` | SQL queries for exploratory data analysis and business findings |
| `dashboard/` | Three-page dashboard visualizations |
| `presentation/` | Project presentation and business insights |

---

## Disclaimer

This project was developed for educational and portfolio purposes as part of the Telkomsel × RevoU Virtual Internship. The analysis is based on the datasets provided for the case study and should not be interpreted as a representation of actual Telkomsel customer data, operational performance, or business results.
