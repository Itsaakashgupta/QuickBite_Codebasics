# 📊 Phase 4 — Exploratory Data Analysis (EDA) Findings  
**Project:** QuickBite Express Business Recovery Challenge  
**Goal:** Identify operational bottlenecks, behavioral shifts, and business recovery opportunities from transactional, customer, and restaurant data.

---

## 🧩 1. Order Trends Analysis

### 🔹 Monthly Order Trend
- Orders dropped sharply during the **crisis months**.
- Monthly revenue pattern mirrors the order decline trend.
- Indicates direct correlation between order volume and overall sales performance.

### 🔹 Phase Comparison (Pre-Crisis vs Crisis)
| Phase | Total Orders | Total Revenue | Avg Order Value |
|--------|---------------|---------------|-----------------|
| Pre-Crisis | Highest - 1,10,672  | Maximum revenue - 376,20,964 | Stable average order value - 327.15 |
| Crisis | Significant drop - 33,441 | Major revenue loss - 109,40,151 | Slight decrease in AOV due to fewer high-value orders - 327.15 |

**Insight:**  
Crisis period caused both demand shrinkage and loss in customer frequency.

---

## 🏙️ 2. City-Level Insights

### 🔹 Top 5 Declining Cities
- Cities with **largest order declines** show >70% drop in order volume.
- These cities need **targeted re-engagement** through localized offers or partnerships.
- The decline is consistent among cities.

### 🔹 Cancellation by City and Phase
- Crisis phase shows **higher cancellation rates** across every cities Which jumps from **around 3% to 7%**.
- Some cities show **spike >7% cancellations**, possibly due to supply chain or delivery disruptions.

**Insight:**  
Customer dissatisfaction during crisis likely amplified by operational inefficiencies.

---

## 🍽️ 3. Restaurant Performance

### 🔹 High-Volume Restaurant Decline
- Restaurants with **≥15 pre-crisis orders** analyzed.
- Top 8 high-volume restaurants saw **Upto >90% decline** during crisis.

**Insight:**  
Restaurant Identity strongly linked to company image, speed, and consistent service quality.

---

## 🚚 4. Delivery & SLA Performance

### 🔹 Cancellation Trend by Phase
| Phase | Cancelled Orders % |
|--------|--------------------|
| Pre-Crisis | ~3–4% |
| Crisis | ~6–7% |

**Observation:**  
Cancellation rate **doubled** during crisis, emphasizing the need for SLA improvement.

### 🔹 SLA (Service Level Agreement) Compliance
| Phase | Avg Delay (mins) | SLA Met (%) |
|--------|------------------|-------------|
| Pre-Crisis | Low - **~2 Mins** | 43%+ |
| Crisis | Higher delays - **~18 Mins** | ~12% SLA met |

**Insight:**  
SLA performance degradation correlates with order decline and poor ratings.

---

## ⭐ 5. Customer Sentiment & Ratings

### 🔹 Average Ratings by Phase
| Phase | Avg Rating |
|--------|-------------|
| Pre-Crisis | **4.5** |
| Crisis | **2.5** |

**Insight:**  
Ratings declined significantly during crisis, reflecting customer dissatisfaction.

### 🔹 Monthly Ratings Trend
- Noticeable **drop in rating scores** during Crisis months.
- It can be seen Ratings significant drops from **June onward ~2**.

### 🔹 Negative Reviews (Crisis Period)
- To be visualized in Power BI **Word Cloud** for qualitative sentiment analysis.

---

## 💰 6. Revenue Impact

### 🔹 Revenue Comparison
| Phase | Total Revenue | Change (%) |
|--------|----------------|------------|
| Pre-Crisis | 100% (baseline) | — |
| Crisis | ~30% of pre-crisis | ↓ 70% |

**Insight:**  
Severe revenue contraction during crisis mainly due to lower order counts and higher cancellations.

---

## 👥 7. Customer Behavior & Loyalty

### 🔹 Repeat vs One-Time Customers
| Phase | One-time % | Repeat % |
|--------|-------------|----------|
| Pre-Crisis | 73% | 27% |
| Crisis | 91% | 9% |

**Insight:**  
Loss of repeat customers signals **loyalty erosion** — recovery campaigns should target these churned segments.

### 🔹 Churn Analysis
- Customers with ≥4 pre-crisis orders: **significant churn** observed during crisis.
- Among churned customers, **high satisfaction (avg rating > 4.5)** group was also lost — indicating **trust issues, not quality**.

**Recommendation:**  
Prioritize **personalized recovery campaigns** and **faster delivery commitments** for these high-value customers.

---

## 🔍 8. Key Takeaways
| Category | Observation | Actionable Recommendation |
|-----------|--------------|---------------------------|
| Orders & Revenue | ~70% decline during crisis | Optimize promotions and pricing recovery plans |
| Cities | 5 cities with 70%+ drop | Launch localized campaigns & influencer tie-ups |
| Restaurants | High-volume partner drop ~90% | Incentivize top restaurants to rejoin with recovery bonuses |
| Delivery | SLA met ↓ 30% | Improve logistics routing & partner training |
| Sentiment | More negative keywords | Strengthen feedback response and trust recovery |
| Loyalty | Churned high-rated customers | Personalized win-back programs |

---

## 📈 9. Next Steps
1. Visualize key metrics in **Power BI dashboard**:
   - Order trends, SLA metrics, sentiment cloud, and customer churn.  
2. Perform **predictive modeling** for restaurant performance and churn probability.  
3. Support business team with **targeted campaign simulations** for recovery.

---

**Prepared by:** *Akash Gupta* 
