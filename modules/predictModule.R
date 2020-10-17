# Upload Module

predictModuleInput <- function(id) {
  ns <- NS(id)
  
  tagList(
    
    sliderInput(ns("time_horizon"), "Time Horizon:", min = 1, max = 48, value = 6),
    checkboxInput(ns("PI"), "Activate PI?", value = F)
    
  )
}

predictModule <- function(input, output, session, data, ...) {
  
  # The user's data, parsed into a data frame
  reactive({
    
    #FUNCTIONS
    model.nnetar.fc <- function(data, h){
      pred_tbl <- data %>% 
        nnetar() %>% 
        {. ->> result.model } %>%  
        forecast(h = h) %>% 
        {. ->> result.fc } %>%  
        data.frame() %>% 
        {. ->> result.df } 
    }
    
    #load the raw data
    df <- data
    ts <- data %>% read.zoo()
    
    h = 10
    
    #run the model function
    model.nnetar.fc(df$value, h = h)
  
    # create future dates for the time horizon predicted
    idx <- ts %>%
      tk_index() %>%
      tk_make_future_timeseries(length_out = h)
    # add future dates to the fc results
    result.tbl <- tibble(
      index   = idx,
      value   = result.df$Point.Forecast)
    
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
    
    #TODO for later functionality
    # Accuracy
    #accuracy(result.fc)
    
  })
}