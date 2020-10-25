# Predict Module

#uncomment for testing
#source("packages.R")

#
#USER INTERFACE
#

predictUI <- function(id) {
  ns <- NS(id)

  tagList(
    sliderInput(ns("H"), label = "Time Horizon:", min = 1, max = 48, value = 6),
    checkboxInput(ns("PI"), label = "Prediction Intervals (PI)?", value = F),
    sliderInput(ns("NPATHS"), label = "How many Calculations (NPATHS for PI)?", min = 1, max = 1000, value = 100)
    )
}

#
#SERVER
#

predictServer <- function(id, data) {
  moduleServer(
    id,
    function(input, output, session) {
      
      H <- input$H
      PI <- input$PI
      NPATHS <- input$NPATHS
      
      #call a prediction function to get the data and the training accuracy returned as a list
      ts.list <- reactive({
        
        #H <- 6
        #PI <- F
        #NPATHS <- 100
        
        ts <- data %>% read.zoo()
        
        #NNETAR FUNCTION
        model.nnetar.fc <- function(data, h, pi, npaths){
          pred_tbl <- data %>% 
            nnetar() %>% 
            {. ->> result.model } %>%  
            forecast(h = h, PI = pi, npaths = npaths) %>% 
            {. ->> result.fc } %>%  
            data.frame() %>% 
            {. ->> result.df } 
        }
        
        #nice function to get everything out of the workflow
        model.nnetar.fc(data$value, h = H, pi = PI, npaths = NPATHS)
        
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
        names(ts.result) <- c("Actual", "Prediction")
        
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
        ts.accuracy <- accuracy(result.fc) %>% data.frame()
        #ts.accuracy <- result.fc
        #accuracy(result.fc)
        
        # Simple Plot
        #ts.plot <- plot(result.fc)
        ts.plot <- result.fc
        
        module.list <- list(ts.extended, ts.accuracy, ts.plot, result.model)
        
        return(module.list)
        
      })
      
      # Return the reactive that yields the timeseries
      return(ts.list)
      
    })
  }

### FOR TESTING

ui <- fluidPage(

  fluidRow(
    column(12,
           h3("Interactive Plot for the Overview"),
           dygraphOutput("dygraph.fc")
    )
  ),

  hr(),

  fluidRow(
    column(6,
           h3("Model Configurations for the Prediction Model"),
           predictUI("predictModule")
           ),

    column(6,
           h3("Training Accuracy (From Model Fit)"),
           tableOutput("acc.tr"),

           h3("Testing Accuracy (From Crossvalidation)"),
           h5("Work in progress: This function will be added soon..."),
           )
    ),

  fluidRow(
    column(8,
           h3("Model Residuals (What patterns are left after using the Model)"),
           plotOutput("plot.res")
    ),
    column(4,
           h3("Prediction Interval Plot (PI)"),
           plotOutput("plot.fc")
    )

  )
)

server <- function(input, output, session) {

  data <- read.csv("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                   stringsAsFactors=FALSE)

  timeseries  <- reactive({
    ts.list <- predictServer("predictModule", data)
  })

   output$dygraph.fc <- renderDygraph({
     ts.list <- timeseries()
     ts <- ts.list()[1] %>% data.frame()
     dygraph(ts)
   })

   output$acc.tr <- renderTable({
     ts.list <- timeseries()
     ts.acc <- ts.list()[[2]]
   })

   output$plot.fc <- renderPlot({
     ts.list <- timeseries()
     ts.plot <- plot(ts.list()[[3]])
   })

   output$plot.res <- renderPlot({
     ts.list <- timeseries()
     ts.model <- ts.list()[4][[1]]
     ts.model %>% checkresiduals()
   })

}

shinyApp(ui, server)
