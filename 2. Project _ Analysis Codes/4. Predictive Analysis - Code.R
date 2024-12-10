# ---- Note ----
# This is an Integrated (interdependent) code/script.
# The code is designed to function in coordination with other
# components, modules, or systems to fulfill its specified purpose.
# It relies on external elements, such as libraries, databases,
# or other parts of a code/script, for proper execution.

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

