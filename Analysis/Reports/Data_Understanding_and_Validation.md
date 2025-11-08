# Phase 2 – Data Understanding & Validation

## 1. Objective

The purpose of this phase was to **load all raw CSVs into a staging schema (`stg_*`)**, run a comprehensive set of validation checks, and record anomalies before transforming the data into final analytical tables.

This stage ensures the data quality and structural integrity required for the subsequent data cleaning and derivation steps in Phase 3.

---

## 2. Process Overview

1. Created a separate **staging database – `quickbite_staging`** with all columns as `VARCHAR`.
2. Loaded all datasets using `LOAD DATA INFILE` (or MySQL Workbench import).
3. Performed checks for:
   - Primary key and uniqueness  
   - Referential integrity (foreign keys)  
   - Data type and date format validation  
   - Value range verification for numeric columns  
   - Business logic reconciliation (e.g., subtotal − discount + delivery_fee = total)
4. Documented all issues found and deferred heavy cleaning to **Phase 3**.

---

## 3. Validation Summary Matrix

| Table | Checks Performed | Results / Issues Found | Action / Next Step |
|:------|:-----------------|:-----------------------|:------------------|
| **fact_orders** | PK uniqueness, FK (customer → dim_customer), amount reconciliation, value range | ✅ PK OK  • ❌ 4 930 missing customers  • ❌ 11 112 rows `total_amount = 0`  | Clean or drop invalid FKs; recompute totals in Phase 3; Total Amount is 0 due to not delivered. |
| **fact_order_items** | (order_id, menu_item_id) uniqueness; FK (order → fact_orders); numeric logic | ❌ 36 348 items without matching order  • ❌ 79 971 line_total mismatch | Filter orphan items; recalc line_total |
| **fact_ratings** | FK (order → fact_orders); timestamp format; rating & sentiment ranges | ✅ Detected format `DD-MM-YYYY HH:MM` → convert  • 17 blank rows deleted | Re-encode dates; cast types on load |
| **fact_delivery_performance** | PK (order_id); FK (order → fact_orders); range checks for time & distance | ✅ No negative values or anomalies | Ready for final load |
| **dim_customer** | PK unique; date format; valid acquisition_channel; city spelling | ❌ Special chars in `acquisition_channel` → fixed with `CASE` enum logic | Clean and cast during Phase 3 load |
| **dim_restaurant** | PK unique; type & status fields validated | ❌ Truncated `is_active` values → trim with `CASE WHEN` | Apply trim logic on load |
| **dim_delivery_partner** | PK unique; rating range; ENUM validity | ✅ No issues | — |
| **dim_menu_item** | PK unique; FK (restaurant → dim_restaurant); price > 0 | ✅ No major issues | — |

---

## 4. Representative Validation Queries

```sql
-- Missing customers referenced in orders
SELECT DISTINCT f.customer_id
FROM stg_fact_orders f
LEFT JOIN stg_dim_customer c ON f.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Order items with missing parent orders
SELECT f.order_id
FROM stg_fact_order_items f
LEFT JOIN stg_fact_orders o ON f.order_id = o.order_id
WHERE o.order_id IS NULL;
```



