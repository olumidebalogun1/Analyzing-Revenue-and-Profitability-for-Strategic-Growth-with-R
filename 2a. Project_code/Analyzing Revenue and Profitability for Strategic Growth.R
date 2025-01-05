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


# ---------------------------------------------------------------------------------------------

                     #######  DESCRIPTIVE ANALYSIS  #######

#######   1 Annual Revenue, Profit, and Volume Performance with Percentage Growth.   #######

# --------------------------------------------------------------------------------------------
#  TASK/QUESTION: Did any years experience negative or stagnant growth? 
#                Furthermore, are there significant differences in the data?

#  PURPOSE: To identify trends over time and detect periods of under performance
#           or stagnation, as well as to assess whether variations in key metrics
#           (e.g., revenue, profit, Volume ) are statistically or 
#           practically significant.This helps pinpoint problem areas that  
#           may require further investigation or corrective action.  
# -------------------------------------------------------------------------------------------

# loading necessary libraries
library(RColorBrewer)
library(gtExtras)

# ------  Calculating the Annual Total Revenue , Profit, and Volume Summary  -------
# Grouping the Cleaned Sales Data by year and computing the annual aggregates for revenue, profit, and volume
Annual_Summary <- cleaned_sales_data %>%
  group_by(year) %>%      # Grouping the dataset by the 'year' column
  summarise(
    Total_Revenue = round(sum(revenue) / 1e6, 2),      # Calculating total revenue in millions ($M), rounded to 2 decimal places
    Total_Profit = round(sum(profit) / 1e6, 2),        # Calculating total profit in millions ($M), rounded to 2 decimal places
    Total_Volume = round(sum(volume) / 1e3, 2)         # Calculating total volume in thousands (K), rounded to 2 decimal places
  )

# -------  Analyzing Annual Performance with Revenue, Profit, and Volume Growth  ------
Annual_Summary <- Annual_Summary %>%
  arrange(year) %>%
  mutate(
    Pct_diff_Revenue = paste0(round((Total_Revenue  - lag(Total_Revenue )) / lag(Total_Revenue ) * 100, 2), "%"),
    Pct_diff_Profit = paste0(round((Total_Profit  - lag(Total_Profit))  / lag(Total_Profit ) * 100, 2), "%"),
    Pct_diff_Volume = paste0(round((Total_Volume  - lag(Total_Volume))  / lag(Total_Volume)  * 100, 2), "%")
  )

# ------  Visualizing Annual Revenue , Profit, and Volume Performance with Growth Trends  ------
# Creating table to display annual performance metrics and growth trends
Plot_Annual_Summary <- Annual_Summary %>% 
  gt() %>% 
  tab_header(title = "Annual Performance: Revenue ($ Million), Profit ($ Million), 
             and Volume (Thousand) with Percentage Growth") %>%          # Adding descriptive title to the table
  cols_align(align = "left")                                             # Aligning all columns to the left for better readability
Plot_Annual_Summary          # Displaying the basic visualization table

# ------  Highlighting Key Data Points with Conditional Formatting  ------
# Enhancing the table visualization by applying themes and highlighting important data points
plot_annual_performance <- Plot_Annual_Summary %>% 
  gt_theme_pff() %>%                                                        # Applying professional theme for consistent styling
  gt_highlight_rows(column = Total_Revenue, fill="lightpink") %>%           # Highlighting cells in the "Total Revenue" column with light pink
  gt_highlight_rows(column = Total_Profit, fill="lightblue") %>%            # Highlighting cells in the "Total Profit" column with light blue
  gt_highlight_rows(column = Pct_diff_Revenue, fill="lightpink") %>%        # Highlighting cells in "Revenue Growth %" column with light pink
  gt_highlight_rows(column = Pct_diff_Profit, fill="lightblue") %>%         # Highlighting cells in "Profit Growth %" column with light blue
  gt_highlight_rows(rows = Pct_diff_Revenue < 0, fill="steelblue")          # Highlighting rows where revenue growth is negative with steel blue

plot_annual_performance        # Displaying the final formatted table with conditional formatting 


#######  2. Analyzing Top 20 Performers by Customer Type, Product Type, and Market Zone: Revenue and Profitability Analysis.  ######

# ------------------------------------------------------------------------------------
#  TASK/QUESTION: Which customer types, product types, and market zones rank
#                 among the top 20 with total revenue surpassing $4.00 million?
 
#  PURPOSE: To identify the highest-performing customer type,
#           product type, and market zones based on total revenue, 
#           enabling businesses to prioritize resources and optimize 
#           strategies for growth. This analysis helps uncover key 
#           success factors and target areas for expansion. 
# ------------------------------------------------------------------------------------
 
 # -------  Summarizing Total Profit and Revenue by Category  ------
summarized_sales_1 <- cleaned_sales_data%>%
  group_by(customer_type, product_type, markets_zone) %>%
  summarise(
    Total_Profit_in_M = round( sum(profit)/ 1e6, 2),
    Total_Revenue_in_M = round( sum(revenue)/ 1e6, 2), 
    .groups = "drop" ) %>%              # to avoid keeping grouped structure
  arrange(desc(Total_Revenue_in_M))

# ------  Ranking Top 20 Records Based on Total Revenue  ------
revenue_top_20 <- summarized_sales_1 %>%
  slice_max(Total_Revenue_in_M , n = 20)       # Extracting Insights from Top 20 Revenue Performers from summarized_sales_1 

# ------  Visualizing Top Twenty by Total Revenue  ------
# Creating table visualization for the top 20 performers by Total Revenue
plot_revenue <- revenue_top_20 %>% 
  gt() %>% 
  tab_header(title = "Top Twenty (20) by Total Revenue ($ Million)") %>%         # Adding  title to the table
  cols_align(align = "left")     # Aligning all columns to the left for better readability

# ------  Highlighting Key Data Points with Conditional Formatting  ------
# Applying custom theme and highlight specific rows and columns with colors for better emphasis
revenue_domain <- range(summarized_sales_1$Total_Revenue_in_M)          # Extract the observed range for Total_Revenue_in_M from summarized_sales_1

plot_revenue <- plot_revenue %>% 
  gt_theme_pff() %>%          # Applying pre-defined professional theme to the table
  gt_highlight_rows(rows = Total_Revenue_in_M >= 4.00, fill="lightpink") %>%     # Highlighting rows where Total Revenue >= 90 with light pink color
  gt_color_rows(columns = "Total_Revenue_in_M", palette = "Pastel1",             # Adding pastel color gradient to the "Total Revenue" column for better visual impact
                domain = revenue_domain               # Specify domain for consistent color scaling
  )
plot_revenue        # Displaying the final formatted table with conditional formatting


#######   3. Analyzing Top 20 Performers by Customer Type, Product Type, and Market Zone: Profit and Revenue Insights.  #######

# ------------------------------------------------------------------------------------------
#  TASK/QUESTION: Which customer types, product types, and market zones
#                 rank among the top 20 with total profits exceeding $0.06 million?

#  PURPOSE: To identify profitable , customer types, product types, 
#           and market zones that drive significant profit, 
#           beyond just sales volume. This analysis helps optimize
#           resource allocation and evaluate the relationship between
#           sales and profitability for sustainable growth.
# -------------------------------------------------------------------------------------------

# ------  Summarizing Total Revenue and Profit by Category  -------
summarized_sales_2 <- cleaned_sales_data%>%
  group_by(customer_type, product_type, markets_zone) %>%
  summarise(
    Total_Revenue_in_M = round( sum(revenue)/ 1e6, 2), 
    Total_Profit_in_M = round( sum(profit)/ 1e6, 2), 
    .groups = "drop" ) %>%              # to avoid keeping grouped structure
  arrange(desc(Total_Revenue_in_M))

# -------  Ranking Top 20 Records Based on Total Profit  ------
top_20_profit <- summarized_sales_2 %>%
  arrange(desc(Total_Profit_in_M)) %>% 
  slice_max(Total_Profit_in_M, n = 20)       #  Extracting Insights from Top 20 Profit Performers from summarized_sales_2

# ------  Visualizing Top Twenty by Profit  ------
# Creating table visualization for the top 20 performers by profit
plot_profit <- top_20_profit %>% 
  gt() %>% 
  tab_header(title = "Top Twenty (20) by Total Profit ($ Million)") %>%     # Adding title to indicate the table represents top 20 profits
  cols_align(align = "left")      # Aligning columns to the left for better readability

# ------  Highlighting Key Data Points with Conditional Formatting  ------
# Applying custom theme and highlight specific rows and columns for visual emphasis
revenue_domain <- range(summarized_sales_2$Total_Profit_in_M)      # Extract the observed range for Total_Profit_in_M from summarized_sales_2

plot_profit <- plot_profit %>% 
  gt_theme_pff() %>%     # Applying professional table theme for consistent styling
  gt_highlight_rows(rows = Total_Profit_in_M >= 0.06, fill="lightblue") %>%    # Highlighting rows where Total Profit is >= $1M with light blue
  gt_color_rows(columns = "Total_Profit_in_M", palette = "Pastel1",            # Adding pastel color gradient to the "Total Profit" column for better visualization
                domain = revenue_domain               # Specify domain for consistent color scaling
  )
plot_profit      # Displaying the final formatted table with conditional formatting


#######   4. Trend Analysis of Revenue Performance Over Time.  #######

# -----------------------------------------------------------------------------
#  TASK/QUESTION: Is there a clear upward or downward trend 
#                 in performance over time?

#  PURPOSE: To identify key metrics (revenue) over time to identify 
#           long-term trends, assess whether performance is improving 
#           or declining, and understand business growth sustainability.
#           This insight helps spot early signs of decline and guide 
#           strategic decisions to optimize performance.
# -----------------------------------------------------------------------------

# ------ Grouping Cleaned Sales Data by Year and Month  ------
# Summarizing revenue, profit, and volume data at the monthly level
sales_group <- cleaned_sales_data %>% 
  group_by(year, month) %>%             # Grouping the data by 'year' and 'month'
  summarise(
    sum_revenue = sum(revenue),         # Calculating the total revenue amount for each month
    sum_profit = sum(profit),           # Calculating the total profit for each month
    sum_volume = sum(volume),           # Calculating the total volume sold for each month
    .groups = "drop"                    # Dropping the grouping structure after summarizing to simplify further operations
  )

# ------  Monthly Revenue Analysis: Conversion to Millions and Thousands for Clarity  ------
# Transforming raw values into more interpretable units (millions for revenue and profit, thousands for volume)
sales_group <- sales_group %>% 
  mutate(Revenue_in_M = round(sum_revenue / 1e6, 2)) %>%         # Converting total revenue to millions ($M) and round to 2 decimal places
  mutate(Profit_in_M = round(sum_profit / 1e6, 2)) %>%           # Converting total profit to millions ($M) and round to 2 decimal places
  mutate(Volume_in_K = round(sum_volume / 1e3, 3)) %>%           # Converting total volume to thousands (K) and round to 3 decimal places
  select(month, Revenue_in_M)                                    # Selecting only the 'month' and converted 'Revenue_in_M' columns for output
# Displaying the final grouped and summarized data in an interactive view
view(sales_group)       

# ------  Creating Time Series Data to Analyze Revenue Trends  ------
Revenue_in_M_ts<- ts(sales_group$Revenue_in_M, start = c(2020,10), end = c(2023,12), frequency = 12) 
Revenue_in_M_ts

# ------  Visualizing Monthly Revenue Trends with Time Series Plot  ------
plot(Revenue_in_M_ts, xaxt = "n", xlab = "Year_Month", ylab = "Revenue ($ Millions)", type = "l",
     lwd=2, main = "Total Revenue per Month", col ="red")
abline(h = mean(Revenue_in_M_ts), col = "blue", lty = 2)          # Dashed line at average revenue level
points(Revenue_in_M_ts, pch = 16, col = "steelblue",cex = 0.7)    # Adding points with specific shape and color
grid(col = "gray", lty = "dotted")

# Extracting and Formatting Time Points for Month-Year Labels
time_labels <- time(Revenue_in_M_ts)
month_year_labels <- format(as.Date(paste(floor(time_labels), (time_labels - floor(time_labels)) * 12 + 1, "01", sep="-")), "%b-%Y")

# Adding the x-axis with formatted month-year labels
axis(1, at = time(Revenue_in_M_ts), labels = month_year_labels, las = 2, cex.axis = 0.8)


#######   5. Market Zone Performance Analysis.   #######

# ------------------------------------------------------------------------------
#  TASK/QUESTION: How do revenue and profitability differ
#                 across various market zones?

#  PURPOSE: To compare revenue and profitability across market zones,
#           identifying high-performing and under performing zones.
#           These insights support the optimization of resource allocation,
#           marketing strategies, and sales efforts, ultimately driving
#           business growth and enhancing overall profitability.
# ------------------------------------------------------------------------------

# loading necessary libraries
library(patchwork)
library(ggprism)

#  Revenue and Profit by Market Zone
zone_performance <- cleaned_sales_data %>%
  group_by(markets_zone) %>%        # Grouping the data by 'markets_zone' to analyze performance across different zones
  summarise(total_revenue_in_M = round((sum(revenue))/ 1e6, 2),    # Calculating total revenue in millions and rounding to 2 decimal places
            total_profit_in_M = round((sum(profit))/ 1e6, 2))      # Calculating total profit in millions and rounding to 2 decimal places

#######   5a.  Evaluation of Revenue Across Market Zone.  #######

# ------  Bar plot of total revenue by Market Zone  ------
r_m <- ggplot(zone_performance, aes(x = reorder(markets_zone,-total_revenue_in_M), y = total_revenue_in_M)) +
  geom_bar(stat = "identity", fill = "tomato") +
  geom_text(aes(label = paste0(total_revenue_in_M,"M")), 
            position = position_dodge(width = 0.9), 
            vjust = -0.4, size = 2.5) +      # Adjusting size and position of text
  labs(title = "Total Revenue by Market Zone", x = "Market Zone", y = "Total Revenue ($ Million)") +
  theme_classic()
r_m        # Displaying the plot

# ------  Statistical Test: Kruskal-Wallis Test  ------
# Analyzing Revenue by Market Zone
# The Kruskal-Wallis test evaluates if there are significant differences in revenue across different market zones
kruskal_test_market_sales <- kruskal.test(revenue ~ markets_zone, data = cleaned_sales_data)
kruskal_test_market_sales                  # Display the results of the Kruskal-Wallis test

#######  5b.  Evaluation of Profitability  Across Market Zone.   #######

# ------  Bar plot of total profit by Market Zone  ------
p_m <- ggplot(zone_performance, aes(x = reorder(markets_zone,-total_profit_in_M), y = total_profit_in_M)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  geom_text(aes(label = paste0(total_profit_in_M,"M")), 
            position = position_dodge(width = 0.9), 
            vjust = -0.4, size = 2.5) +    # Adjusting size and position of text
  labs(title = "Total Profit by Market Zone", x = "Market Zone", y = "Total Profit ($ Million)") +
  theme_classic()
p_m         # Displaying the plot

# ------  Statistical Test: Kruskal-Wallis Test  ------
# Performing the Kruskal-Wallis test on Profit by Market Zone
# This test checks if there are significant differences in Profit across different market zones
kruskal_test_market_profit <- kruskal.test(profit ~ markets_zone, data = cleaned_sales_data)
kruskal_test_market_profit          # Displaying the results of the Kruskal-Wallis test

# ------  Combining and Displaying the plots  ------
combined_plot_1 <- r_m/p_m     # Combining the revenue plot (r_m) and profit plot (p_m)
combined_plot_1                # Displaying the combined plot


#######  6. Revenue and Profitability Analysis by Product Type.  #######

# -----------------------------------------------------------------------
#  TASK/QUESTION: How do revenue and profit vary across
#                 different product types?

#  PURPOSE: Is to identify which product types are
#           most profitable and which are under performing.
#           This insight helps businesses optimize resources,
#           marketing strategies, and inventory management
#           to drive growth and reduce costs.
# ----------------------------------------------------------------------

#######   6a. Evaluation of Revenue Across Product Types.  #######

# ------  Revenue Performance Across Product Types. ------
product_revenue <- cleaned_sales_data %>%
  group_by(product_type) %>%        # Grouping the data by product type
  summarise(total_revenue_in_M = round((sum(revenue))/ 1e6, 2))    # Summing revenue and converting to millions

# ------  Bar plot of total revenue across Product Type  ------
r_p <- ggplot(product_revenue, aes(x = reorder(product_type, -total_revenue_in_M), y = total_revenue_in_M)) +    # Reordering product types by revenue
  geom_bar(stat = "identity", fill = "tomato") +             # Creating a bar plot with "tomato" color
  geom_text(aes(label = paste0(total_revenue_in_M,"M")),     # Adding revenue labels to each bar
            position = position_dodge(width = 0.9), 
            vjust = -0.4, size = 2.5) +                      # Adjusting the text position and size for clarity
  labs(title = "Total Revenue by Product Type", x = "Product Type", y = "Total Revenue ($ Million)") +  # Customizing plot labels
  theme_classic()   
r_p       # Displaying the plot

# ------  Statistical Test: Kruskal-Wallis Test  ------
# Performing the Kruskal-Wallis test on Revenue by Product Type
kruskal_test_product <- kruskal.test(revenue ~ product_type, data = cleaned_sales_data)     # Checking if revenue vary across product types
kruskal_test_product      # Displaying the result of the test

#######   6b. Evaluation of Profitability Across Product Types  #######

# ------  Profit Performance Across Product Types  ------
product_profit <- cleaned_sales_data %>%
  group_by(product_type) %>%
  summarise(total_profit_in_M = round((sum(profit)) / 1e6, 2))    # Summarizing total profit by product type

# ------  Bar Plot of Total Profit across Product Type  ------
p_p <- ggplot(product_profit, aes(x = reorder(product_type, -total_profit_in_M), y = total_profit_in_M)) +
  geom_bar(stat = "identity", fill = "steelblue") +        # Bar chart with steel blue color
  geom_text(aes(label = paste0(total_profit_in_M, "M")), 
            position = position_dodge(width = 0.9), 
            vjust = -0.4, size = 2.5) +                    # Adding labels above bars with adjusted position and text size
  labs(title = "Total Profit by Product Type", x = "Product Type", y = "Total Profit ($ Million)") +  # Chart labels
  theme_classic()       
p_p      # Displaying the plot

# ------  Statistical Test: Kruskal-Wallis Test  ------
# Performing the Kruskal-Wallis Test on Profit by Product Type
kruskal_test_product_profit <- kruskal.test(profit ~ product_type, data = cleaned_sales_data)    # Testing for differences in profit by product type
kruskal_test_product_profit         # Displaying test results

# ------  Combining and Displaying the revenue and Profit Plots  ------
combined_plot_2 <- r_p / p_p      # Combining the revenue plot (s_p) and profit plot (p_p)
combined_plot_2                   # Displaying the combined plot


#######  7. Revenue and Profitability Analysis by Customer Types.   #######

# ------------------------------------------------------------------------------
#  TASK/QUESTION: How do revenue and profit vary across
#                 different product types?

#  PURPOSE: To uncover the revenue and profit contributions of different
#           customer types to inform resource allocation, optimize
#           marketing strategies, and drive targeted initiatives
#           for customer retention and revenue growth.
# ------------------------------------------------------------------------------

#######  7a. Evaluation of Revenue Across Customer Types.  #######

# ------   Revenue Performance Across Customer Types  ------
# Grouping Cleaned_Sales_Data by customer type and calculate the total revenue in millions
customer_sales <- cleaned_sales_data %>%
  group_by(customer_type) %>%
  summarise(total_revenue_in_M = round((sum(revenue)) / 1e6, 2))

# ------  Visualizing Total Revenue by Customer Type  ------
# Creating bar plot to show total revenue for each customer type
r_c <- ggplot(customer_sales, aes(x = reorder(customer_type, -total_revenue_in_M), y = total_revenue_in_M)) +
  geom_bar(stat = "identity", fill = "tomato") +             # Bar plot with tomato-colored bars
  geom_text(aes(label = paste0(total_revenue_in_M, "M")),    # Adding labels showing revenue values in millions
            position = position_dodge(width = 0.9), 
            vjust = -0.4, size = 3) +                        # Adjusting label size and vertical position
  labs(
    title = "Total Revenue by Customer Type",       # Adding an informative title
    x = "Customer Type",  # Label for x-axis        # Labeling for x-axis
    y = "Total Revenue ($ Million)"               # Labeling for y-axis
  ) +
  theme_classic()     
r_c                   # Displaying the plot

# ------  Statistical Test: Kruskal-Wallis Test  ------
# Performing the Kruskal-Wallis test to assess if revenue vary significantly across customer types
kruskal_test_customer <- kruskal.test(revenue ~ customer_type, data = cleaned_sales_data)
kruskal_test_customer      # Displaying test results

#######  7b. Evaluation of Profitability Across Customer Types  #######

# ------  Profit Performance Across Customer Types  ------
# Grouping Cleaned Sales Data by customer type and calculate total profit in millions
customer_profit <- cleaned_sales_data %>%
  group_by(customer_type) %>%
  summarise(total_profit_in_M = round((sum(profit)) / 1e6, 2))

# ------  Visualizing Total Profit by Customer Type  ------
# Creating bar plot to show total profit for each customer type
p_c <- ggplot(customer_profit, aes(x = reorder(customer_type, -total_profit_in_M), y = total_profit_in_M)) +
  geom_bar(stat = "identity", fill = "steelblue") +         # Bar plot with steel-blue bars
  geom_text(aes(label = paste0(total_profit_in_M, "M")),    # Adding labels showing profit values in millions
            position = position_dodge(width = 0.9), 
            vjust = -0.4, size = 3) +  # Adjust label size and vertical position
  labs(
    title = "Total Profit by Customer Type",     # Adding an informative title
    x = "Customer Type",  # Label for x-axis     # Labeling for x-axis
    y = "Total Profit ($ Million)"               # Labeling for y-axis
  ) +
  theme_classic()           
p_c     # Displaying the plot

# ------  Statistical Test: Kruskal-Wallis Test  ------
# Performing the Kruskal-Wallis test to assess if profit varies significantly across customer types
kruskal_test_customer_profit <- kruskal.test(profit ~ customer_type, data = cleaned_sales_data)
kruskal_test_customer_profit        # Displaying test results

# ------  Combined Visualization: Revenue and Profit by Customer Type  ------
# Combining the sales (s_c) and profit (p_c) plots for a side-by-side comparison
combined_plot_3 <- r_c + p_c
combined_plot_3       # Displaying the combined plots


# ---------------------------------------------------------------------------------

                        #######  DIAGNOSTIC ANALYSIS  #######

#######  8. Exploratory and Statistical Correlation Analysis with Significance Testing.  #######

# --------------------------------------------------------------------------------
#  TASK: To display the correlation matrix and perform statistical correlation 
#        analysis with significance testing using the psych package.

#  PURPOSE: To identify the strength and direction of relationships
#           between variables while incorporating statistical rigor
#           through significance testing and confidence intervals
#           for more reliable interpretations.
# ---------------------------------------------------------------------------------

# Loading necessary libraries
library(corrplot)
library(psych)
library(ggstatsplot)

# -------  8a. Correlation Matrix with corrplot.  -------
# Prepare the data for correlation analysis
cor_data <- cleaned_sales_data %>%
  select(revenue, profit, cost_price, volume) 

# Visualize the correlation matrix
corrplot(corr = cor(cor_data ),
         addCoef.col = "white",
         number.cex = 0.9,
         number.digits = 1,
         diag = FALSE,
         bg = "lightgray",
         outline = "black",
         addgrid.col = "white",
         mar = c(1,1,1,1),
         main = "Correlation Matrix: Revenue, Profit, Cost Price, and Volume"
           )

# ------  8b. Correlation Matrix with psych.   -------
# Select only the numeric columns
numerical_data <- cleaned_sales_data %>%
  select(revenue, profit, volume, cost_price)

# Compute the correlation matrix
correlation_results <- psych::corr.test(
  numerical_data,        # Dataset containing numeric variables
  method = "pearson",    # Method for correlation (default is Pearson)
  adjust = "none"        # Adjustment method for p-values (e.g., none, Holm)
)

# View the correlation matrix
print(correlation_results$r)       # Correlation coefficients (r-values)

# View the p-values to test significance of correlations
print(correlation_results$p)       # P-values


#######   9. The Impact of Volume on Revenue.   #######
   
# ----------------------------------------------------------------------------
#  TASK/QUESTION: How Does Volume Directly Impact Revenue Growth? 

#  PURPOSE: Is to explore the relationship between Volume and revenue,
#           aiming to identify key revenue drivers, optimize pricing 
#           and sales strategies, improve forecasting accuracy,
#           analyze segment contributions, and support data-driven
#           decision-making to maximize revenue generation. 
# ----------------------------------------------------------------------------

# ------  Scatter Plot with Statistical Analysis: Volume vs. Revenue  ------
# This section creates a scatter plot to visualize the relationship between volume and revenue ($).
# A nonparametric statistical method is used to evaluate the correlation, with an ellipse added to highlight the distribution pattern.

s1 <- ggscatterstats(
  data = cleaned_sales_data, 
  x = volume,                 # Independent variable: Volume in thousands
  y = revenue,                # Dependent variable: Revenue in millions
  type = "nonparametric"      # Correlation type: Nonparametric
) + 
  labs(
    title = "Scatter Plot: Volume vs Revenue with Correlation Analysis ",      # Title of the plot
    x = "Volume of Sales",               # X-axis label
    y = "Revenue Generated ($)"          # Y-axis label
  )
s1 + stat_ellipse()      # Adding an ellipse to illustrate data distribution

# ------  Correlation Analysis: Spearman Correlation Coefficient  ------
# This step calculates the Spearman correlation coefficient to quantify  
# the strength and direction of the relationship between Volume and Revenue.
volume_revenue_correlation <- cor(
  cleaned_sales_data$volume,        
  cleaned_sales_data$revenue,       
  method = "spearman"            # Correlation method: Spearman
)
volume_revenue_correlation       # Displaying the correlation result


#######  10. The Impact of Volume on Profitability.  #######

# ---------------------------------------------------------------------------------
#  TASK/QUESTION: How Does Volume Drive Profitability? 

#  PURPOSE: Is to examine the correlation between the volume 
#           of products sold and the profit generated. 
#           This analysis aims to uncover key drivers of profitability,
#           enhance business strategies, and support informed decision-making. 
# ---------------------------------------------------------------------------------

# ------  Scatter Plot with Regression Line, Correlation, and p-value  ------
# This section generates a scatter plot to visualize the relationship between volume and profit ($).
# It includes statistical analysis, showing a regression line, correlation coefficient, and p-value for nonparametric correlation.

s2 <- ggscatterstats(
  data = cleaned_sales_data, 
  x = volume,           # Independent variable: Volume  in thousands
  y = profit,           # Dependent variable: Profit in millions
  type = "nonparametric"     # Correlation type: Nonparametric
) +
  labs(
    title = "Scatter Plot: Volume vs Profit with Correlation Analysis ",      # Title of the plot
    x = "Volume of Sales",           # X-axis label
    y = "Profit Generated ($)"       # Y-axis label
  )
s2 + stat_ellipse()             # Adding an ellipse to illustrate the distribution of data points

# ------  Correlation Analysis: Spearman Correlation Coefficient  ------
# This step calculates the Spearman correlation coefficient to evaluate  
# the strength and direction of the relationship between volume and profit.
volume_profit_correlation <- cor(
  cleaned_sales_data$volume,    # Volume in thousands
  cleaned_sales_data$profit,    # Profit in millions
  method = "spearman"           # Correlation method: Spearman
)
volume_profit_correlation   # Displaying the correlation result


#######  11.  Revenue and Profitability: Analyzing the Correlation.   #######

# ------------------------------------------------------------------------------------
#  TASK/QUESTION: How Does Revenue Influence Profitability?

#  PURPOSE: Is to explore the relationship between revenue and profitability,
#           helping to identify profit drivers, optimize business strategies,
#           enhance financial efficiency, and support data-driven decision-making
#           for prioritizing profitable revenue streams. 
# ------------------------------------------------------------------------------------

# ------  Scatter Plot with Regression Line, Correlation, and p-value  ------
# This section generates a scatter plot to visualize the relationship between revenue ($) and profit ($).
# It includes statistical analysis, showing a regression line, correlation coefficient, and p-value for nonparametric correlation.

s3 <- ggscatterstats(
  data = cleaned_sales_data, 
  x = revenue,            # Independent variable: Revenue in millions
  y = profit,             # Dependent variable: Profit in millions
  type = "nonparametric"       # Correlation type: Nonparametric
) +
  labs(
    title = "Scatter Plot: Revenue vs Profit with Correlation Analysis",       # Title of the plot
    x = "Revenue Generated ($)",      # X-axis label
    y = "Profit Generated ($)"        # Y-axis label
  )
s3 + stat_ellipse()                   # Adding an ellipse to illustrate the distribution of data points

# ------  Calculating Spearman Correlation for Revenue vs Profit  ------
# This calculates the strength and direction of the monotonic relationship between revenue and profit.
revenue_profit_correlation <- cor(cleaned_sales_data$revenue, 
                                  cleaned_sales_data$profit, 
                                method = "spearman") 
revenue_profit_correlation        # Displaying the correlation result


#######  12. The Impact of Cost Price on Revenue    #######

# --------------------------------------------------------------------------------
#  TASK/QUESTION: How Does Cost Price Influence Revenue Streams?

#  PURPOSE: Is to understand how the cost of production or acquiring a product
#           impacts revenue generation. This analysis helps identify
#           cost-related revenue drivers, optimize pricing strategies,
#           improve forecasting, enhance business efficiency by
#           addressing cost inefficiencies, and support data-driven
#           decisions for better pricing and revenue optimization. 
# --------------------------------------------------------------------------------

# ------  Scatter Plot for Cost Price vs Revenue with Regression Line, Correlation, and P-value  ------
# This plot visualizes the relationship between cost price and revenue, incorporating a regression line and statistical annotations.
# It provides insights into whether higher costs lead to higher revenue and helps understand the pricing-sales relationship.

s4 <- ggscatterstats(cleaned_sales_data, 
                     x = cost_price, 
                     y = revenue, 
                     type = "nonparametric") +     # Using nonparametric analysis for robust insights
labs(title = "Scatter Plot: Cost Price vs Revenue with Correlation Analysis",       # Title of the plot
       x = "Cost Price ($)",                # X-axis label
       y = "Revenue Generated ($)") +       # Y-axis label
theme_minimal()     
  
s4 + stat_ellipse()       # Adding an ellipse to highlight the spread and clustering of data points


#  ------  Calculating Spearman Correlation for Cost Price and Revenue  ------
# This computes the strength and direction of the monotonic relationship between cost price and revenue.
cost_revenue_correlation <- cor(cleaned_sales_data$cost_price, 
                                cleaned_sales_data$revenue, 
                              method = "spearman") 
cost_revenue_correlation       # Displaying the correlation result


#######  13. The Impact of Cost Price on Profitability.   #######

# -----------------------------------------------------------------------------------
#  TASK/QUESTION: What Role Does Cost Price Play in Driving Profitability?

#  PURPOSE: Is to investigate how the cost of producing or acquiring a product
#           impacts the overall profitability of a business.
#           This analysis ultimately supports strategic decision-making
#           to ensure that businesses optimize costs and maximize profitability. 
# -----------------------------------------------------------------------------------

# ------  Scatter Plot for Cost Price vs Profit with Regression Line, Correlation, and P-value  ------
# This plot visualizes the relationship between cost price and profit, incorporating a regression line and statistical annotations.
# It aims to provide insights into how changes in cost affect profitability, aiding in cost optimization strategies.

s5 <- ggscatterstats(cleaned_sales_data, 
                    x = cost_price, 
                    y = profit, 
                    type = "nonparametric") +    # Nonparametric analysis for robust relationship detection
  labs(title = "Scatter Plot: Cost Price vs Profit with Correlation Analysis",       # Title of the plot
       x = "Cost Price ($)",              # X-axis label
       y = "Profit Generated ($)") +      # Y-axis label
  theme_minimal()       
 
s5 + stat_ellipse()         # Adding an ellipse to highlight the spread and clustering of data points


# ------  Calculating Spearman Correlation for Cost Price and Profit  ------
# This computes the strength and direction of the monotonic relationship between cost price and profit.
cost_profit_correlation <- cor(cleaned_sales_data$cost_price, 
                               cleaned_sales_data$profit, 
                               method = "spearman") 
cost_profit_correlation        # Displaying the correlation result



#######  14. The Impact of Cost Price on Volume.   #######

# ------------------------------------------------------------------------------
#  TASK/QUESTION: What Role Does Cost Price Play in Driving Volume Sold?

#  PURPOSE: Is to evaluate the relationship between cost price
#           and sales volume, identify pricing sensitivity,
#           and uncover insights that can guide pricing strategies,
#           optimize production costs, and predict how variations in 
#           cost price impact customer demand and sales performance. 
# ------------------------------------------------------------------------------

# ------  Scatter Plot for Cost Price vs volume with Regression Line, Correlation, and P-value  ------
# This plot visualizes the relationship between cost price and volume, incorporating a regression line and statistical annotations.
# It aims to provide insights into how changes in cost affect volume, aiding in cost optimization strategies.

s6 <- ggscatterstats(cleaned_sales_data, 
                     x = cost_price, 
                     y = volume, 
                     type = "nonparametric") +    # Nonparametric analysis for robust relationship detection
  labs(title = "Scatter Plot: Cost Price vs Volume with Correlation Analysis",       # Title of the plot
       x = "Cost Price ($)",      # X-axis label
       y = "Volume Sold" ) +       # Y-axis label
  theme_minimal()         

s6 + stat_ellipse()         # Adding an ellipse to highlight the spread and clustering of data points

# ------  Calculating Spearman Correlation for Cost Price and volume  ------
# This computes the strength and direction of the monotonic relationship between cost price and volume.
cost_volume_correlation <- cor(cleaned_sales_data$cost_price, 
                               cleaned_sales_data$volume, 
                               method = "spearman") 
cost_volume_correlation        # Displaying the correlation result


# --------------------------------------------------------------------------------------------------------------------------

                     #######  PREDICTIVE ANALYSIS  #######


#######  15. Identifying Key Drivers of Revenue Performance: Insights from Feature Importance & Regression Analysis.  #######

# --------------------------------------------------------------------------------
#  TASK/QUESTION: What Key Drivers Contribute to Revenue Performance?

#  PURPOSE: The goal is to identify the factors that significantly impact 
#           revenue outcomes, enabling businesses to optimize strategies 
#           and make informed decisions to enhance sales effectiveness. 
# --------------------------------------------------------------------------------

# Convert categorical variables into factors
cleaned_sales_data$product_type <- as.factor(cleaned_sales_data$product_type)
cleaned_sales_data$customer_type <- as.factor(cleaned_sales_data$customer_type)
cleaned_sales_data$markets_state <- as.factor(cleaned_sales_data$markets_state)
cleaned_sales_data$markets_zone <- as.factor(cleaned_sales_data$markets_zone)

str(cleaned_sales_data)

# -------  15a. Feature Importance Plot with XGBoost Model.  -------
# Loading necessary libraries
library(xgboost)
library(Matrix)

# Preparing data
revenue_matrix <- model.matrix(revenue ~ customer_type + product_type + 
                               markets_state + markets_zone + volume + cost_price + profit + profit_margin, data = cleaned_sales_data)
revenue_target <- cleaned_sales_data$revenue

# Using XGBoost Model
# Training the XGBoost model
xgb_model <- xgboost(data = as.matrix(revenue_matrix), label = revenue_target, 
                     nrounds = 50, objective = "reg:squarederror")

# Feature Importance Plot with XGBoost Model
importance_matrix <- xgb.importance(model = xgb_model)
xgb.plot.importance(importance_matrix, main = "Feature Importance for Revenue Using the XGBoost Model")


# ------  15b. Variables Significantly Influencing Revenue Using a Regression Model.  ------
# The Key Drivers of Revenue using multiple linear regression model.
revenue_model <- lm(revenue ~ cost_price + profit + profit_margin + volume + customer_type + product_type + 
                      markets_state + markets_zone  , data = cleaned_sales_data)

summary(revenue_model)

       
       #####  16. Revenue Seasonality and Trend Analysis: Using Decomposition.   #####

# --------------------------------------------------------------------------------
#  TASK/QUESTION: What are the seasonal patterns and long-term trends in revenue over time?

#  PURPOSE: To uncover recurring seasonal patterns and identify long-term growth or
#           decline trends in revenue, enabling better forecasting, resource allocation,
#           and strategic decision-making for sustained business performance.
# --------------------------------------------------------------------------------

# Decomposition of Revenue into Trend and Seasonal Components
# Recalling Revenue_in_M_ts from Creating Time Series Data to Analyze Revenue Trends
plot(stl(Revenue_in_M_ts, "per"), main = "Revenue Decomposition into Seasonal and Trend Components")


     #####  17. Forecasting Revenue Trends with Time Series Analysis.    #####

# --------------------------------------------------------------------------------
#  TASK/QUESTION: What are the predicted revenue trends for the next 36 months, and  
#                 how can these insights be leveraged to drive favorable business decisions?

#  PURPOSE: To leverage these predictions in decision-making that optimizes 
#           business strategies, such as pricing, marketing, and resource allocation,
#           to achieve positive financial outcomes. 
# --------------------------------------------------------------------------------

# loading necessary library
library(tseries)
    
# Recalling the time series object
Revenue_in_M_ts<- ts(sales_group$Revenue_in_M, start = c(2020,10), end = c(2023,12), frequency = 12) 
Revenue_in_M_ts

# ------  Augmented Dickey Fuller Test for Stationarity  ------
# Checking stationarity 
revenue_adf_test <- adf.test(Revenue_in_M_ts)
print(revenue_adf_test)

# ------  Performing differencing on the series to make it stationary, as the p-value is greater than 0.05  ------
# Checking for stationarity again (1st order differencing)
revenue_adf_test_diff <- adf.test(diff(diff(Revenue_in_M_ts)))
print(revenue_adf_test_diff)

# -------    Revenue Trend Forecast using ARIMA Model.  -------
# loading necessary library
library(forecast)         

# Since the series is stationary, fit ARIMA and specify d = 1 (1st order differencing)
revenue_arima_model <- auto.arima(Revenue_in_M_ts, d = 1)  # 'd=1' means first-order differencing
summary(revenue_arima_model)

# Forecasting Revenue Trends using ARIMA Model
revenue_arima_model <- auto.arima(Revenue_in_M_ts)
forecast_revenue <- forecast(revenue_arima_model, h=36)
plot(forecast_revenue, main = "Revenue Forecast for the Next 3 Years",
     xlab = "Year_Month", ylab = "Revenue Generated ($ million)")

# Print the forecasted values (numeric values)
print(forecast_revenue$mean)


                  #####  18.  Pricing Analysis  #####

# --------------------------------------------------------------------------------
#  TASK/QUESTION: What insights can be derived from analyzing the relationships between
#                 selling price, cost price, and profit margin using statistical models?

#  PURPOSE: Is to uncover how selling price and cost price influence profit margins, 
#           optimize pricing strategies, support data-driven decisions, identify
#           segment-specific patterns, forecast financial outcomes, and detect 
#           inefficiencies to improve profitability and guide strategic planning.
# --------------------------------------------------------------------------------

# -------  18a. Calculating Key Pricing Metrics. -------
# Calculating the average selling price and profit margin for each transaction
pricing_data <- cleaned_sales_data %>%
  mutate(selling_price = round(revenue / volume, 2),    # Average selling price per unit
         profit_margin = (profit / revenue) * 100)      # Profit margin as a percentage of revenue
view(pricing_data)      # View the updated pricing data

# Grouping data by product_type and customer_type to calculate the average selling price and average profit margin
pricing_summary <- pricing_data %>%
  group_by(product_type, customer_type) %>%
  summarise(avg_selling_price = round(mean(selling_price), 2),      # Average selling price by group
            avg_profit_margin = round(mean(profit_margin), 2))      # Average profit margin by group
view(pricing_summary)        # View the summarized pricing data

# ------ 18b. Analyzing Price Elasticity of Demand.  ------
# Price Elasticity = % Change in Quantity Sold / % Change in Price
pricing_data <- pricing_data %>%
  arrange(order_date) %>%
  mutate(price_change = (selling_price - lag(selling_price)) / lag(selling_price),    # % Change in price
         quantity_change = (volume - lag(volume)) / lag(volume),                      # % Change in quantity sold
         price_elasticity = quantity_change / price_change)                           # Price elasticity of demand
view(pricing_data)       # View data with price elasticity

# Filtering out rows where price elasticity is NA or zero
pricing_data <- pricing_data %>%
  filter(!is.na(price_elasticity) & price_elasticity != 0)  # Remove NA and zero values
summary(pricing_data$price_elasticity)  # Summary of price elasticity

# ------  Identifying Elastic Products Based on Price Elasticity.  ------
# Assuming `elasticity_data` is a vector of price elasticity values
elasticity_data <- data.frame(elasticity = c(-Inf, -1.8489, -0.1290, 0.9541, Inf))

# Filter for products with elasticity greater than 1 (elastic products)
elastic_products <- elasticity_data[elasticity_data$elasticity > 1, ]
print(elastic_products)  # View elastic products

# Removing infinite values and viewing valid elasticities
valid_elasticity <- elasticity_data[!is.infinite(elasticity_data$elasticity), ]
print(valid_elasticity)  # View valid elasticity values

# -------   18c. The Effect of Selling Price and Cost Price on Profit Margin.  ------

# Building a linear regression model to analyze the effect of selling price, cost price, and revenue on profit margin
pricing_model <- lm(profit_margin ~ selling_price + cost_price + revenue  , data = pricing_data)
summary(pricing_model)      # View model summary


#--------------------------------------------------------------------------

                        #######  PRESCRIPTIVE ANALYSIS  #######


              #####  19.  Top Customers Who Make Up 80% of Total Revenue.  #####
  
# --------------------------------------------------------------------------------
#  TASK/QUESTION: Which customers contribute to the majority (80%) of the business's total revenue?

#  PURPOSE: To identify key customers who contribute significantly to total revenue, enabling 
#           businesses to prioritize engagement, optimize marketing, allocate resources efficiently, 
#           and make data-driven decisions to retain and grow these high-value customers,
#            ultimately maximizing revenue and fostering long-term success.
# --------------------------------------------------------------------------------

# ------  Grouping by Customer Name and Calculating Total Revenue and Volume  ------
# This block aggregates total revenue and volume for each customer and calculates additional metrics such as 
# average volume value, revenue contribution percentage, and cumulative percentage.
revenue_clustering <- cleaned_sales_data %>%
  group_by(custmer_name  ) %>% 
  summarise(Total_Revenue_in_M = round(sum(revenue)/1e6, 2),
            Total_Volume_in_K = round(sum(volume)/1e3, 2), .groups = "drop") %>% 
  arrange(desc(Total_Revenue_in_M)) %>% 
  mutate(Average_Volume_Value = round(Total_Revenue_in_M/Total_Volume_in_K, 2)) %>% 
  mutate(Total_Revenue_percent = round(Total_Revenue_in_M *100/sum(Total_Revenue_in_M), 2)) %>% 
  mutate(Cum_percent = round(cumsum(Total_Revenue_percent), 2)) %>% 
  select(custmer_name , Total_Revenue_in_M, Total_Volume_in_K , 
         Average_Volume_Value , Total_Revenue_percent, Cum_percent) %>% 
  arrange(desc(Total_Revenue_in_M))

view(revenue_clustering)

# ------ Creating a Table for Customers Who Make Up 80% of Total Revenue ------
# Filtering the customers contributing up to 80% of total revenue.
top_80_customers <- revenue_clustering %>%
  filter(Cum_percent <= 80)

view(top_80_customers)        # Display the top 80% customers data

# ------  Creating a Table for Customers Who Make Up 80% of Total Revenue. -------
# Identifying Top Customers Contributing 80% of Revenue
# Plotting a Table for Top Customers 
plot <- top_80_customers  %>% 
  select(custmer_name, Total_Revenue_in_M, Total_Volume_in_K,Total_Revenue_percent, Cum_percent ) %>% 
  gt() %>% 
  tab_header(title = "Top Customers Who Make Up 80% of Total Revenue ($ Million)") %>% 
  cols_align(align = "left")

# Enhancing Table with Styling
plot <- plot %>% 
  gt_theme_pff() %>% 
  gt_highlight_rows(rows = Total_Revenue_in_M >=5.00, fill="lightpink" ) %>% 
  gt_highlight_rows(rows = Total_Revenue_in_M >=3.00 & Total_Revenue_in_M <=5.00 , fill="lightblue" ) %>% 
  gt_plt_bar_pct(Total_Revenue_percent, fill = "steelblue",height = 15, width = 100)

plot    # Displaying the styled table


              #######  20. Clustering and Customer Segmentation.  #######

# --------------------------------------------------------------------------------
#  TASK/QUESTION: Which customer segments, based on clustering, contribute
#                 the most to overall revenue and sales volume?

#  PURPOSE: To identify customer segments generating the highest revenue
#           and sales volume, uncovering trends to guide strategic decisions.
#           Insights help optimize resources, target marketing, and tailor engagement
#           strategies for profitability and growth.
# --------------------------------------------------------------------------------

# loading necessary library
library(cluster)
 
# --------  Clustering Model for Customer Segmentation  -------
# K-Means Clustering 
kmeans_result <- kmeans(revenue_clustering[, c("Total_Revenue_in_M", "Total_Volume_in_K")], centers = 3)

# Assigning Cluster Labels
# Adding a new column to the dataset to indicate which cluster each customer belongs to.
revenue_clustering$cluster <- kmeans_result$cluster

# -------  Visualizing K-Means Clustering Results  -------
# Creating a scatter plot to visualize customer segments based on revenue and volume.
# Points are colored according to their assigned cluster.
plot(
  revenue_clustering$Total_Revenue_in_M,    # X-axis: Total Revenue
  revenue_clustering$Total_Volume_in_K,     # Y-axis: Total Volume
  col = revenue_clustering$cluster,         # Color based on cluster assignment
  main = "Customer Segmentation using Clustering Model",  # Plot title
  xlab = "Total Revenue ($ Million)",       # X-axis label
  ylab = "Total Volume (Thousand)"          # Y-axis label
)

# ---- Notes ----
# 1. K-Means clustering identifies patterns in customer data, grouping customers with similar revenue and volume characteristics.
# 2. This visualization helps in interpreting customer behavior and identifying high-value clusters.
# 3. The number of clusters (`centers = 3`) can be adjusted based on business requirements or results of Elbow Method analysis.
