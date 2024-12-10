# ---- Note ----
# This is an Integrated (interdependent) code/script.
# The code is designed to function in coordination with other
# components, modules, or systems to fulfill its specified purpose.
# It relies on external elements, such as libraries, databases,
# or other parts of a code/script, for proper execution.

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

