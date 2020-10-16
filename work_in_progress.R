library(dygraphs)
library(dplyr)
library(zoo)
library(forecast)
library(timetk)
library(tibble)
library(purrr)
library(rlang)
library(tibbletime)
library(lubridate)
library(xts)

#Base import
data <- read.csv("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                 stringsAsFactors=FALSE)

#Zoo import
#data.ts <- read.csv.zoo("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
#                 stringsAsFactors=FALSE)

ts <- data %>% 
  read.zoo()

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
#result as df uncomment:
#result.df
#result as plot uncomment:
#autoplot(result.fc)
#result as model uncomment:
#result.model
  
# create future dates for the time horizon predicted
idx <- ts %>%
  tk_index() %>%
  tk_make_future_timeseries(length_out = h)
#idx

# Retransform values
result.tbl <- tibble(
  index   = idx,
  value   = result.df$Point.Forecast)

#result.tbl
#str(result.tbl)

# Combine actual data with predictions
df.act <- data %>%
  read.zoo() %>% 
  tk_tbl() %>% 
  mutate(index = as_date(index)) %>%
  as_tbl_time(index = index) %>% 
  data.frame() %>% 
  add_column(key = "actual")

df.fc <- result.tbl %>%
  tk_tbl() %>% 
  mutate(index = as_date(index)) %>%
  as_tbl_time(index = index) %>% 
  data.frame() %>% 
  add_column(key = "predict")
 
df.result <- rbind(df.act, df.fc)

ts.act <- df.result %>%
  filter(key == "actual") %>% 
  select(index, value) %>% 
  read.zoo() 

ts.fc <- df.result %>%
  filter(key == "predict") %>% 
  select(index, value) %>% 
  read.zoo() 

ts.act_fc <- merge(ts.act, ts.fc)
names(ts.act_fc) <- c("Actual", "Prediction")

ts.fit <- data.frame(data.act, result.fc$fitted) %>% 
  select("index","result.fc.fitted") %>%
  na.omit() %>% 
  read.zoo()
names(ts.fit) <- c("index", "Fit")

ts.all <- merge(ts.act_fc, ts.fit)
names(ts.all) <- c("Actual", "Prediction", "Fit")
dygraph(ts.all)

### Accuracy
accuracy(result.fc)

