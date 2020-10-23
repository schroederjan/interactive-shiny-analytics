# Test Module

source("packages.R")

#
#USER INTERFACE
#

crossvalidationUI <- function(id) {
  ns <- NS(id)
  
  tagList(
    sliderInput(ns("splits"), label = "How many splits?:", min = 2, max = 6, value = 2),
    #checkboxInput(ns("PI"), label = "Prediction Intervals (PI)?", value = F),
    #sliderInput(ns("NPATHS"), label = "How many Calculations (NPATHS for PI)?", min = 1, max = 1000, value = 100)
  )
}

#
#SERVER
#

crossvalidationServer <- function(id, data) {
  moduleServer(
    id,
    function(input, output, session) {
      
      s <- input$splits
      #PI <- input$PI
      #NPATHS <- input$NPATHS
      
      #call a prediction function to get the data and the training accuracy returned as a list
      split.list <- reactive({
        
        # ts <- data %>% read.zoo()
        # 
        # #NNETAR FUNCTION
        # model.nnetar.fc <- function(data, h, pi, npaths){
        #   pred_tbl <- data %>% 
        #     nnetar() %>% 
        #     {. ->> result.model } %>%  
        #     forecast(h = h, PI = pi, npaths = npaths) %>% 
        #     {. ->> result.fc } %>%  
        #     data.frame() %>% 
        #     {. ->> result.df } 
        # }
        # 
        # #nice function to get everything out of the workflow
        # model.nnetar.fc(data$value, h = H, pi = PI, npaths = NPATHS)
        # 
        # # create future dates for the time horizon predicted
        # idx <- ts %>%
        #   tk_index() %>%
        #   tk_make_future_timeseries(length_out = H)
        # #idx
        # 
        # # Retransform values
        # result.tbl <- tibble(
        #   index   = idx,
        #   value   = result.df$Point.Forecast)
        # #result.tbl
        # #str(result.tbl)
        # 
        # #easy function to avoid double code
        # ts_to_df <- function(start_ts) {
        #   end_df <- start_ts %>% 
        #     tk_tbl() %>% 
        #     mutate(index = as_date(index)) %>%
        #     as_tbl_time(index = index) %>% 
        #     data.frame()
        # }
        # #add "actual" string for actuals and "predict for prediction df to be transformed to ts for visuals
        # df_to_ts <- function(start_df, actual_predict) {
        #   end_ts <- start_df %>% 
        #     filter(key == actual_predict) %>% 
        #     select(index, value) %>% 
        #     read.zoo() 
        # }
        # 
        # df.act <- ts_to_df(ts) %>% add_column(key = "actual")
        # df.fc <- ts_to_df(result.tbl) %>% add_column(key = "predict")
        # #RESULT AS DF
        # df.result <- rbind(df.act, df.fc)
        # 
        # ts.act <- df_to_ts(df.result, "actual")
        # #str(ts.act)
        # ts.fc <- df_to_ts(df.result, "predict")
        # #str(ts.fc)
        # #RESULT AS TS
        # ts.result <- merge(ts.act, ts.fc)
        # names(ts.result) <- c("Actual", "Prediction")
        # 
        # #add fit from the model to the results
        # ts.fit <- data.frame(df.act, result.fc$fitted) %>% 
        #   select("index","result.fc.fitted") %>%
        #   na.omit() %>% 
        #   read.zoo()
        # names(ts.fit) <- c("index", "Fit")
        # 
        # #RESULT EXTENDED AS TS
        # ts.extended <- merge(ts.result, ts.fit)
        # names(ts.extended) <- c("Actual", "Prediction", "Fit")
        # 
        # # Accuracy
        # ts.accuracy <- accuracy(result.fc) %>% data.frame()
        # #ts.accuracy <- result.fc
        # #accuracy(result.fc)
        # 
        # # Simple Plot
        # #ts.plot <- plot(result.fc)
        # ts.plot <- result.fc
        # 
        # module.list <- list(ts.extended, ts.accuracy, ts.plot, result.model)
        # 
        # return(module.list)
        # 
      })
      
      # Return the reactive that yields the timeseries
      return(split.list)
      
    })
}

### FOR TESTING

ui <- fluidPage(
  
  fluidRow(
    h3("Choosing how many different splits to be done:"),
    crossvalidationUI("cv")
    ),
  
  ### SPLIT 1
  
  fluidRow(
    h3(""),
    dygraphOutput("split1")
    ),
  
  fluidRow(
    #h3(""),
    #tableOutput("split1.acc")
  ),
  
  ### SPLIT 2
  
  fluidRow(
    #h3(""),
    #dygraphOutput("split1")
  ),
  
  fluidRow(
    #h3(""),
    #tableOutput("split1.acc")
  )
)

server <- function(input, output, session) {
  
  data <- read.csv("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                   stringsAsFactors=FALSE)
  
  splits <- reactive({
    split.list <- crossvalidationServer("cv", data)
  })
  
  output$split1 <- renderDygraph({
    #split.list <- splits()
    #ts <- split.list()[1] %>% data.frame()
    #dygraph(ts)
    dygraph(data %>% read.zoo())
  })
  
}

shinyApp(ui, server)
