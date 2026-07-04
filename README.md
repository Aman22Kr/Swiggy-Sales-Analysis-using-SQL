# 🍔 Swiggy Sales Analysis using SQL

A complete SQL-based Data Analytics project that demonstrates **data cleaning, dimensional modeling (Star Schema), and business KPI analysis** using Swiggy food delivery data.

This project follows a real-world Business Intelligence workflow—from cleaning raw transactional data to building an analytical data warehouse and generating actionable business insights.

---

## 📌 Project Overview

The dataset contains Swiggy food delivery records across multiple states, cities, restaurants, cuisines, and dishes.

The project focuses on:

- Data Quality Assessment
- Data Cleaning & Validation
- Duplicate Detection & Removal
- Star Schema (Dimensional Modeling)
- KPI Development
- Business Performance Analysis using SQL

---

## 🛠️ Technologies Used

- SQL
- MySQL / SQL Server (Compatible with minor syntax changes)
- Relational Database
- Star Schema Data Warehouse Design

---

# 📂 Dataset

The raw table contains the following information:

- State
- City
- Order Date
- Restaurant Name
- Location
- Category (Cuisine)
- Dish Name
- Price (INR)
- Rating
- Rating Count

---

# 🧹 Data Cleaning & Validation

Before performing analysis, the raw data is validated to improve data quality.

### ✅ Null Value Checks

The following columns are checked for missing values:

- State
- City
- Order_Date
- Restaurant_Name
- Location
- Category
- Dish_Name
- Price_INR
- Rating
- Rating_Count

---

### ✅ Blank Value Checks

Identify records containing:

- Empty Strings
- Blank Spaces

These values can negatively impact reporting and aggregations.

---

### ✅ Duplicate Detection

Duplicate records are identified by comparing all business-critical columns.

---

### ✅ Duplicate Removal

Duplicates are removed using:

```sql
ROW_NUMBER()
```

Only one unique record is retained while removing redundant entries.

---

# ⭐ Dimensional Modeling (Star Schema)

To improve reporting performance, the cleaned dataset is transformed into a Star Schema.

## Dimension Tables

### dim_date

- Date
- Year
- Month
- Quarter
- Week

### dim_location

- State
- City
- Location

### dim_restaurant

- Restaurant Name

### dim_category

- Cuisine / Category

### dim_dish

- Dish Name

---

## Fact Table

### fact_swiggy_orders

Contains measurable business metrics:

- Price_INR
- Rating
- Rating_Count

Foreign Keys:

- Date Key
- Location Key
- Restaurant Key
- Category Key
- Dish Key

---

# 📊 Star Schema

```
                   dim_date
                      |
                      |
dim_location ---- fact_swiggy_orders ---- dim_restaurant
                      |
                      |
                dim_category
                      |
                      |
                  dim_dish
```

---

# 📈 Business KPIs

## Basic KPIs

- Total Orders
- Total Revenue (INR Million)
- Average Dish Price
- Average Rating

---

## 📅 Date Analysis

- Monthly Order Trends
- Quarterly Order Trends
- Year-wise Growth
- Day of Week Analysis

---

## 📍 Location Analysis

- Top 10 Cities by Order Volume
- Revenue Contribution by State

---

## 🍽 Restaurant Analysis

- Top 10 Restaurants by Orders
- Restaurant Performance

---

## 🍜 Cuisine Analysis

- Top Categories
- Cuisine-wise Orders
- Average Rating by Cuisine

---

## 🥘 Dish Analysis

- Most Ordered Dishes
- Popular Dishes by Revenue
- Highest Rated Dishes

---

# 📊 Business Insights

The project enables stakeholders to answer questions like:

- Which cities generate the highest order volume?
- Which states contribute the most revenue?
- Which cuisines are most popular?
- Which restaurants receive the highest customer ratings?
- Which dishes drive the maximum sales?
- How do sales change over months and quarters?

---

# 📁 Project Structure

```
Swiggy-Sales-Analysis/
│
├── Dataset/
│   └── swiggy_data.csv
│
├── SQL/
│   ├── 01_Data_Cleaning.sql
│   ├── 02_Duplicate_Removal.sql
│   ├── 03_Star_Schema.sql
│   ├── 04_Insert_Dimensions.sql
│   ├── 05_Fact_Table.sql
│   └── 06_KPI_Analysis.sql
│
├── ERD/
│   └── Star_Schema.png
│
├── README.md
│
└── LICENSE
```

---

# 🚀 Learning Outcomes

This project demonstrates practical experience in:

- SQL Data Cleaning
- Data Validation
- Window Functions
- ROW_NUMBER()
- Common Table Expressions (CTEs)
- Star Schema Design
- Fact & Dimension Tables
- Data Warehousing Concepts
- Business KPI Development
- Analytical SQL Queries

---

# 🎯 Future Enhancements

- Interactive Power BI Dashboard
- Tableau Dashboard
- SQL Stored Procedures
- Performance Optimization using Indexes
- Automated ETL Pipeline
- Predictive Sales Analysis

---

# 📄 License

This project is open-source and available under the MIT License.

---

## ⭐ If you found this project helpful, consider giving it a star!
