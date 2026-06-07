# README: Superstore Customer Sales Analytics (Assignment 3)

## Project Overview
This project focuses on normalizing a flat, unstructured dataset (`superstore_raw`) into a clean, relational database schema (`customers`, `products`, and `orders`) using standard database validation techniques. Once the tables are structured, advanced analytical SQL techniques—such as Subqueries, Common Table Expressions (CTEs), and Window Functions—are applied to extract deep business intelligence and complete a targeted customer segmentation case study.

---

## Repository Contents

### 1. `advanced_superstore_analytics.sql`
A production-grade SQL script containing the complete pipeline:
* **DDL Blueprints:** Structural data layout configurations with strict constraints (`PRIMARY KEY`, `FOREIGN KEY`, and logic domain rules like `CHECK(sales >= 0)`).
* **ETL Normalization:** Automated pipeline using `SELECT DISTINCT` routines to ingest and de-duplicate the staging data into separate operational dimensions.
* **Core Advanced Queries:** Step-by-step query implementations utilizing nested subqueries, standalone CTE blocks, and partition-based window sequences (`ROW_NUMBER()` and `DENSE_RANK()`).
* **Mini-Project Solutions:** Clean, documented business logic queries targeting precise customer behavior metrics.

### 2. `advanced_superstore_analytics.ipynb`
An interactive, step-by-step Jupyter Notebook workbook built for immediate execution:
* **Self-Contained Engine:** Powered by a local, fast in-memory SQLite database (`sqlite3`), removing the need for external server setup.
* **Verifiable Milestones:** Uses Python's `pandas` data frame tables to preview, verify, and track the state of your data after every single transformation.
* **Granular Layout:** Divided into 5 logical project development blocks (Ingestion -> Modeling -> In-depth Analysis -> Master Matrix -> Case Study Completion).

---

## Strategic Business Insights Extracted

Running this workbook on the Superstore dataset surfaces critical behavioral insights:

* **Revenue Concentration:** Identifies elite high-value spenders tracking well above the historical company mean. These accounts are ideal targets for premium retention and high-tier loyalty funnel campaigns.
* **Lifecycle Friction & Churn:** Isolates single-purchase, low-frequency customer profiles. Recognizing these early single-transaction drop-offs allows marketing teams to deploy automated re-engagement workflows before accounts churn completely.
* **Wholesale vs. Retail Spikes:** Evaluates an individual's lifetime sales against their maximum single order value. This helps separate steady, predictable retail shoppers from irregular, high-volume corporate B2B wholesale buyers.

---

## How to Get Started

### To Run the Interactive Jupyter Notebook:
1. Open the file `advanced_superstore_analytics.ipynb` using JupyterLab, VS Code, or Google Colab.
2. Click **Run All Cells**. The notebook will automatically spin up the local database engine, generate mock data to clear string literal boundaries, format the dates, and render the analytical tables directly on your screen.

### To Run the Pure SQL Script on Your Own Database:
1. Import your raw Superstore CSV file into your target database server tool (e.g., MySQL Workbench, DBeaver, or pgAdmin) and name the staging table **`superstore_raw`**.
2. Open and run `advanced_superstore_analytics.sql` in your query editor. The script will handle the structural normalization, key associations, and analysis automatically.
