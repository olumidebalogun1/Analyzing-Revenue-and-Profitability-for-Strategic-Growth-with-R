# ---- Note ----
# This is an Integrated (interdependent) code/script.
# The code is designed to function in coordination with other
# components, modules, or systems to fulfill its specified purpose.
# It relies on external elements, such as libraries, databases,
# or other parts of a code/script, for proper execution.

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
             and Volume ($ Thousand) with Percentage Growth") %>%        # Adding descriptive title to the table
  cols_align(align = "left")                                             # Aligning all columns to the left for better readability
Plot_Annual_Summary      # Displaying the basic visualization table

# ------  Highlighting Key Data Points with Conditional Formatting  ------
# Enhancing the table visualization by applying themes and highlighting important data points
plot_annual_performance <- Plot_Annual_Summary %>% 
  gt_theme_pff() %>%                                                        # Applying professional theme for consistent styling
  gt_highlight_rows(column = Total_Revenue, fill="lightpink") %>%           # Highlighting cells in the "Total Revenue" column with light pink
  gt_highlight_rows(column = Total_Profit, fill="lightblue") %>%            # Highlighting cells in the "Total Profit" column with light blue
  gt_highlight_rows(column = Pct_diff_Revenue, fill="lightpink") %>%        # Highlighting cells in "Revenue Growth %" column with light pink
  gt_highlight_rows(column = Pct_diff_Profit, fill="lightblue") %>%         # Highlighting cells in "Profit Growth %" column with light blue
  gt_highlight_rows(rows = Pct_diff_Revenue < 0, fill="steelblue")          # Highlighting rows where revenue growth is negative with steel blue

plot_annual_performance    # Displaying the final formatted table with conditional formatting 


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
  tab_header(title = "Top Twenty (20) by Total Revenue ($ Million)") %>%      # Adding  title to the table
  cols_align(align = "left")     # Aligning all columns to the left for better readability

# ------  Highlighting Key Data Points with Conditional Formatting  ------
# Applying custom theme and highlight specific rows and columns with colors for better emphasis
revenue_domain <- range(summarized_sales_1$Total_Revenue_in_M)      # Extract the observed range for Total_Revenue_in_M from summarized_sales_1

plot_revenue <- plot_revenue %>% 
  gt_theme_pff() %>%          # Applying pre-defined professional theme to the table
  gt_highlight_rows(rows = Total_Revenue_in_M >= 4.00, fill="lightpink") %>%     # Highlighting rows where Total Revenue >= 90 with light pink color
  gt_color_rows(columns = "Total_Revenue_in_M", palette = "Pastel1",             # Adding pastel color gradient to the "Total Revenue" column for better visual impact
                domain = revenue_domain               # Specify domain for consistent color scaling
  )
plot_revenue       # Displaying the final formatted table with conditional formatting


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

