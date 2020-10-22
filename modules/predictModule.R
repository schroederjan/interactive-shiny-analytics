# Predict Module

#
#USER INTERFACE
#

predictUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    sliderInput(ns("time_horizon"), "Time Horizon:", min = 1, max = 48, value = 6),
    checkboxInput(ns("PI"), "Activate PI?", value = F)
  )
  
}

#
#SERVER
#

predictServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    h <- input$time_horizon
    PI <- input$PI
    
    print(PI)
    
    timeseries <- reactive({
      
      prediction_function <- function(data, h, PI) {
        
        ts <- data %>% read.zoo()
        
        #NNETAR FUNCTION
        model.nnetar.fc <- function(data, h, PI){
          pred_tbl <- data %>% 
            nnetar() %>% 
            {. ->> result.model } %>%  
            forecast(h = h, PI = PI) %>% 
            {. ->> result.fc } %>%  
            data.frame() %>% 
            {. ->> result.df } 
        }
        
        #nice function to get everything out of the workflow
        model.nnetar.fc(data$value, h = h, PI = PI)
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
        
        return(ts.extended)
        
      }
      timeseries <- prediction_function(data, h, PI)
      
    })
    
    # Return the reactive that yields the timeseries
    return(timeseries)
  }
  )
}
