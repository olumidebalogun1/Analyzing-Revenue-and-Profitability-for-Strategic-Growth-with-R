# ---- Note ----
# This is an Integrated (interdependent) code/script.
# The code is designed to function in coordination with other
# components, modules, or systems to fulfill its specified purpose.
# It relies on external elements, such as libraries, databases,
# or other parts of a code/script, for proper execution.

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
  mutate(Cum_percernt = round(cumsum(Total_Revenue_percent), 2)) %>% 
  select(custmer_name , Total_Revenue_in_M, Total_Volume_in_K , 
         Average_Volume_Value , Total_Revenue_percent, Cum_percernt) %>% 
  arrange(desc(Total_Revenue_in_M))

view(revenue_clustering)


# ------  Creating a Table for Customers Who Make Up 80% of Total Revenue. -------
# Identifying Top Customers Contributing 80% of Revenue
# This block extracts the top customers based on total revenue and visualizes the data.
Top_Revenue_customer <- revenue_clustering %>%
  slice_max(Total_Revenue_in_M, n = 15)  # Selecting top 15 customers contributing to revenue
view(Top_Revenue_customer)  # Viewing the resulting subset
print(Top_Revenue_customer)
# Plotting a Table for Top Customers 
plot <- Top_Revenue_customer %>% 
  select(custmer_name, Total_Revenue_in_M, Total_Volume_in_K,Total_Revenue_percent, Cum_percernt ) %>% 
  gt() %>% 
  tab_header(title = "Top Customers Who Make Up 80% of Total Revenue") %>% 
  cols_align(align = "left")

# Enhancing Table with Styling
plot <- plot %>% 
  gt_theme_pff() %>% 
  gt_highlight_rows(rows = Total_Revenue_in_M >=4.00, fill="lightpink" ) %>% 
  gt_highlight_rows(rows = Total_Volume_in_K >=15.00, fill="lightblue" ) %>% 
  gt_plt_bar_pct(Total_Revenue_percent, fill = "steelblue",height = 15, width = 100) %>% 
  gt_color_rows(columns = "Total_Volume_in_K", palette = "Pastel1")

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
