# E-Commerce Data Pipeline & Optimization (Data Engineering Pipeline - Python)

 **Python Data Engineering Pipeline To Transform Raw, Static E-Commerce Dataset To A High Performant Dataset Ready For Business Intelligence (BI) And Analytical Use.**

---

##  Project Overview

The nature of many e-commerce datasets is that they are typically not well-structured due to multiple sources of nested JSON fields, many lines of HTML meta-data, and media links associated with the records, which will negatively affect database query performance.

The goal of this project was to create a reproducible data engineering process utilizing `pandas` and `numpy`, that can transform a dataset of **1,000 retail products** into an optimized dataset suitable for Business Intelligence and Analytics by removing duplicate logs, simulating user behavior through mathematical broadcasting, and reducing the schema from **24 features to 7 core analytical features** in a manner that can be reused.

### Project Outcomes:
* **85% Reduction In Storage**: Removed 17 columns of unneeded non-primary key heavy text/JSON fields from the schema to reduce its overall size.
* **No Records Were Lost**: Null data fields were re-mapped into a standardized set of categorical numeric metrics without changing any of the original row logic.
* **Feature Engineering**: Developed absolute transaction values by taking a uniform, seeded, and distributed random volume as input.

---

##  System Architecture & Schema

The pipeline transforms the incoming database table from clutter into clean high-value metrics:

| Attribute | Data Type | Key/Role | Analytical Purpose |
| :--- | :--- | :--- | :--- |
| `product_id` | `int64` | Primary Key | Unique identifier for the item |
| `title` | `object` | Feature | Brand/manufacturer of the item |
| `category` | `object` | Feature | Item classification segment |
| `rating` | `float64` | Feature | Average customer rating (0.0 - 5.0) |
| `price` | `float64` | Feature | Resident currency cost of the item. (INR) |
| `quantity` | `int32` | Synthetic | Simulated Volume of the item sold per transaction |
| `total_amount` | `float64` | Derived/Target | Total amount of money for gross sales per transaction |

---

##  Core Pipeline Implementation Steps

There are three core stages in which the pipeline is constructed:

### 1) Ingesting & Structurally Stabilizing The Data
* **Loading Data**: Load the raw e-commerce dataset into a single data frame.
* **Null Fields**: Address all missing numerical values.


