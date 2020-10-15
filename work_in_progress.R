library(dygraphs)
library(dplyr)
library(zoo)
library(forecast)
library(timetk)

#Base import
data <- read.csv("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                 stringsAsFactors=FALSE)
head(data)
str(data)

#
#VISUAL
#

#Zoo import
data.ts <- read.csv.zoo("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                 stringsAsFactors=FALSE)
head(data.ts)
str(data.ts)

ts <- data %>% 
  read.zoo()

dygraph(ts)

#
#TEST
#

source("modules/acf.R")

data <- data %>% na.omit(value) 
# Seasonal Differencing
nsdiffs(ts)  # number for seasonal differencing needed
# Make it stationary
ndiffs(ts)  # number of differences need to make it stationary

#
#Prediction
#

#data$value %>% 
#  nnetar() %>% 
#  forecast() %>% 
#  data.frame()

h = 10

#NNETAR FUNCTION
model.nnetar.fc <- function(data, h){
  pred_tbl <- data %>% 
    nnetar() %>% 
    {. ->> result.model } %>%  
    forecast(h = h) %>% 
    {. ->> result.fc } %>%  
    data.frame() %>% 
    {. ->> result.df } 
}

#nice function to get everything out of the workflow
model.nnetar.fc(data$value, h = h)

#result as df
result.df
#result as plot
autoplot(result.fc)
#result as model
result.model
  
# Make future index using tk_make_future_timeseries()
idx <- ts %>%
  tk_index() %>%
  tk_make_future_timeseries(length_out = h)

idx

# Retransform values
pred_tbl <- tibble(
  index   = idx,
  value   = result.fc$mean)

pred_tbl

###
### UNDERCONSTRUCTION
###
  
# Combine actual data with predictions
tbl_1 <- df %>%
  add_column(key = "actual")
  
tbl_3 <- pred_tbl %>%
  add_column(key = "predict")
names(tbl_3) <- c("index", "value", "key")
  
  # Create time_bind_rows() to solve dplyr issue
  time_bind_rows <- function(data_1, data_2, index) {
    index_expr <- enquo(index)
    bind_rows(data_1, data_2) %>%
      as_tbl_time(index = !! index_expr)
  }
  
  ret <- list(tbl_1, tbl_3) %>%
    reduce(time_bind_rows, index = index) %>%
    arrange(key, index) %>%
    mutate(key = as_factor(key))
  
  return(ret)
}


