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
library(shiny)
library(shinydashboard)
library(glue)

#library(fable)
#library(tidyquant)
#library(fpp3)
#library(fpp2)   
#library(tidyverse)

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

#source("modules/acf.R")

#data <- data %>% na.omit(value) 
# Seasonal Differencing
#nsdiffs(ts)  # number for seasonal differencing needed
# Make it stationary
#ndiffs(ts)  # number of differences need to make it stationary

#
#Prediction
#

H = 48
PI = T
NPATHS = 100

prediction_function <- function(df, H, PI, NPATHS) {
  
  ts <- data %>% read.zoo()
  
  #NNETAR FUNCTION
  model.nnetar.fc <- function(data, H, PI, NPATHS){
    pred_tbl <- data %>% 
      nnetar() %>% 
      {. ->> result.model } %>%  
      forecast(h = H, PI = PI, npaths = NPATHS) %>% 
      {. ->> result.fc } %>%  
      data.frame() %>% 
      {. ->> result.df } 
  }
  
  #nice function to get everything out of the workflow
  model.nnetar.fc(data$value, h = H, PI = PI, npaths = NPATHS)
  #result as df uncomment:
  #result.df
  #result as plot uncomment:
  #autoplot(result.fc)
  #result as model uncomment:
  #result.model
  
  # create future dates for the time horizon predicted
  idx <- ts %>%
    tk_index() %>%
    tk_make_future_timeseries(length_out = H)
  #idx
  
  # Retransform values
  result.tbl <- tibble(
    index   = idx,
    value   = result.df$Point.Forecast)
  #result.tbl
  #str(result.tbl)
  
  #easy function to avoid double code
  ts_to_df <- function(start_ts) {
    end_df <- start_ts %>% 
      tk_tbl() %>% 
      mutate(index = as_date(index)) %>%
      as_tbl_time(index = index) %>% 
      data.frame()
  }
  #add "actual" string for actuals and "predict for prediction df to be transformed to ts for visuals
  df_to_ts <- function(start_df, actual_predict) {
    end_ts <- start_df %>% 
      filter(key == actual_predict) %>% 
      select(index, value) %>% 
      read.zoo() 
  }
  
  df.act <- ts_to_df(ts) %>% add_column(key = "actual")
  df.fc <- ts_to_df(result.tbl) %>% add_column(key = "predict")
  #RESULT AS DF
  df.result <- rbind(df.act, df.fc)
  
  ts.act <- df_to_ts(df.result, "actual")
  #str(ts.act)
  ts.fc <- df_to_ts(df.result, "predict")
  #str(ts.fc)
  #RESULT AS TS
  ts.result <- merge(ts.act, ts.fc)
  names(ts.act_fc) <- c("Actual", "Prediction")
  
  #add fit from the model to the results
  ts.fit <- data.frame(df.act, result.fc$fitted) %>% 
    select("index","result.fc.fitted") %>%
    na.omit() %>% 
    read.zoo()
  names(ts.fit) <- c("index", "Fit")
  
  #RESULT EXTENDED AS TS
  ts.extended <- merge(ts.result, ts.fit)
  names(ts.extended) <- c("Actual", "Prediction", "Fit")
  
  # Accuracy
  ts.accuracy <- accuracy(result.fc)
  
  # Simple Plot
  ts.plot <- plot(result.fc)
  
  #gg_tsresiduals(result.model)
  res.plot <- result.model$residuals %>% plot(main = "Plot of Residuals")
  res.acf <- result.model$residuals %>% na.omit() %>% Acf(main = "ACF of Residuals")
  res.hist <- result.model$residuals %>% hist(main = "Histogram of Residuals")
  ts.residuals <- list(res.plot, res.acf, res.hist)
  
  ts.list <- list(ts.extended, ts.accuracy, ts.plot, ts.residuals)
  
  return(ts.list)
  
}
ts.list <- prediction_function(data, H = H, PI = PI, NPATHS = NPATHS)

#TESTING FUNCTION OUTPUT
ts.acc <- ts.list[2] %>% data.frame()
ts <- ts.list[1] %>% data.frame()
ts.plot <- ts.list[3][[1]]

res.plot <- ts.list[4][1]

#VISUAL
dygraph(ts)
ts.acc
ts.plot[[1]]



# ### Accuracy
# accuracy(result.fc)

custom_dygraph <- function(data) {
  dygraph(data, main = glue("Uploaded Data:")) %>% 
    dyRangeSelector() %>% 
    dyOptions(colors = RColorBrewer::brewer.pal(10, "BrBG")[c(9,4)]) %>% 
    dyUnzoom() %>% 
    dyCrosshair(direction = "vertical") %>% 
    dyLegend(width = 400) %>% 
    dyHighlight(highlightCircleSize = 5, 
                highlightSeriesBackgroundAlpha = 0.2,
                hideOnMouseOut = FALSE)
}
custom_dygraph(ts.extended)

