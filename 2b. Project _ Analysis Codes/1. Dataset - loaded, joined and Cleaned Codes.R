# ---------------------------------------------------------------------------------

# Script Title: Analyzing Revenue and Profitability for Strategic Growth
# # Author: Olumide Balogun
# Date: 2024-09-22
# Purpose: This script analyzes revenue data from 2020 to 2023,
#          transforming raw data into actionable insights through
#          meticulous cleaning and formatting, exploratory data analysis (EDA),
#          and impactful visualizations. It identifies patterns,
#          uncovers trends, explores customer behavior, reveals relationships,
#          and highlights the factors driving revenue and profitability growth
#          to support strategic business decisions.

# ---------------------------------------------------------------------------------

#######   Loading necessary libraries   #######

library(tidyverse)
library(ggplot2)
library(readxl)
library(lubridate)


                          # ------ Importing datasets  -----

Sales_Transactions <- read_excel("Revunue Dataset/Sales _Transactions.xlsx")
View(Sales_Transactions)        # Viewing the table

Sales_Customers <- read_excel("Revunue Dataset/Sales_Customers.xlsx")
View(Sales_Customers)        # Viewing the table

Sales_Markets <- read_excel("Revunue Dataset/Sales_Markets.xlsx")
View(Sales_Markets)        # Viewing the table

Sales_products <-read_excel("Revunue Dataset/Sales_products.xlsx")
View(Sales_products)       # Viewing the table


                     #######  Joining the tables   #######

sales_data <- Sales_Transactions %>%
  left_join(Sales_Customers, by = "customer_code") %>%
  left_join(Sales_Markets, by = "market_code") %>%
  left_join(Sales_products, by = "product_code")    # Performing simultaneous left joins 
# Viewing the joined table
view(sales_data )       


                               #######   Wrangling   #######
# Checking for Missing Data
total_missing_values <- sum(is.na(sales_data))
print(paste("Total missing values in the dataset:", total_missing_values))

# Removing missing data
sales_data <- sales_data %>% 
  na.omit(sales_data)

sum(is.na(sales_data))    # Checking for missing data again

# Removing duplicate rows
sales_data <- sales_data %>% 
  distinct()

# Checking the structure of the dataset
str(sales_data)     # Displaying columns, data types, and sample values

# -----  Updating Column Names: Renaming sales_amount to revenue and sales_qty to volume   -----  
# to enhance clarity, consistency, and alignment with business terminology standards. 
sales_data <- sales_data %>%
  rename(
    markets_state = markets_name,    # Rename market_name to markets_state
    revenue = sales_amount,          # Rename sales_amount to revenue
    volume = sales_qty               # Rename sales_qty to volume
  )

head(sales_data)              # View the updated data frame to confirm changes

# -----  Converting order_date to date format and extract year/month.  -----
sales_data$order_date <- as.Date(sales_data$order_date, format = "%Y-%m-%d")      # Converting order_date to Date format
sales_data$year <- format(sales_data$order_date, "%Y")       # Extracting Year
sales_data$month <- format(sales_data$order_date, "%Y-%m")        # Extracting Year and Month

# Displaying columns, data types, and sample values
str(sales_data)   

# -----  Calculating and displaying the number of rows and columns in sales_data.  ----- 
# Number of Rows
num_rows <- nrow(sales_data)
print(paste("Number of rows:", num_rows))

# Number of Columns
num_columns <- ncol(sales_data)
print(paste("Number of columns:", num_columns))

# Combined Information
print(paste("The Sales_dataset has", num_rows, "rows and",num_columns , "columns."))


           #######  Exploratory Data Analysis 1 (EDA) - statistical summary.  ####### 

# -----  Generating a statistical summary for specific columns in sales_data.  -----
# Columns to Summarize
selected_columns <- c("volume", "revenue", "cost_price", "profit", "profit_margin")

# Viewing Summary of Selected Columns
sales_data %>%
  select(all_of(selected_columns)) %>%
  summary()


                    #######  Wrangling 2 (Removing Outliers).  #######
# ------------------------------------------------------------------------------
# TASK: To Remove Outliers and Summarize the Cleaned Data.

# Purpose: Outliers are data points significantly different from others,
#          and they can distort statistical measures such as mean and 
#          standard deviation. Removing them helps:
#          1. Improve model accuracy.
#          2. Ensure reliable insights.
#          3. Maintain the integrity of predictions and trends.
# ------------------------------------------------------------------------------

# Removing Outliers and Summarizing Cleaned Data
# Function to Directly Remove Outliers from Original Columns
remove_multi_outliers <- function(sales_data, columns) {
  sales_data %>%
    filter(if_all(
      all_of(columns),
      ~ . >= quantile(., 0.25, na.rm = TRUE) - 1.5 * IQR(., na.rm = TRUE) & 
        . <= quantile(., 0.75, na.rm = TRUE) + 1.5 * IQR(., na.rm = TRUE)
    ))
}

# Columns to Remove Outliers From
columns_to_clean <- c("volume", "revenue", "cost_price", "profit", "profit_margin")

# Applying the Function
cleaned_sales_data <- remove_multi_outliers(sales_data, columns_to_clean)

# Viewing Summary of Selected Columns
cleaned_sales_data %>%
  select(all_of(columns_to_clean)) %>%
  summary()

# -----   Calculating and Displaying the number of Rows and columns After Cleaning.  -----
# Number of Rows
num_rows <- nrow(cleaned_sales_data)
print(paste("Number of rows:", num_rows))

# Number of Columns
num_columns <- ncol(cleaned_sales_data)
print(paste("Number of columns:", num_columns))

# Combined Information
print(paste("The Cleaned_Sales_dataset has", num_rows, "rows and", num_columns, "columns."))

# -----  Calculating and Displaying the Reduction in Rows After Cleaning. -----
# To determine the difference in the number of rows before and after outlier removal.
# Number of Rows in the Original Dataset
num_rows_original <- nrow(sales_data)

# Number of Rows in the Cleaned Dataset
num_rows_cleaned <- nrow(cleaned_sales_data)

# Calculate the Difference
rows_removed <- num_rows_original - num_rows_cleaned

# Display the Result
print(paste("The original dataset had", num_rows_original, "rows."))
print(paste("After removing outliers, the dataset has", num_rows_cleaned, "rows."))
print(paste("The number of rows removed from the dataset is", rows_removed, "."))


                  #######  Exploratory Data Analysis 2 (EDA). ####### 

# Generating a statistical summary for specific columns in clearned_sales_data (csd).
# Columns to Summarize
selected_columns_csd <- c("volume", "revenue", "cost_price", "profit", "profit_margin")

# Viewing Summary of Selected Columns
cleaned_sales_data %>%
  select(all_of(selected_columns_csd)) %>%
  summary()

