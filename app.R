## app.R ##

source("modules/packages.R")
source("modules/uploadModule.R")
source("modules/predictModule.R")

###
#FUNCTIONS
###

custom_dygraph <- function(data) {
  
  dygraph(data) %>% 
    dyRangeSelector() %>% 
    dyOptions(colors = RColorBrewer::brewer.pal(10, "BrBG")[c(9,4)]) %>% 
    dyUnzoom() %>% 
    dyCrosshair(direction = "vertical") %>% 
    dyLegend(width = 400) %>% 
    dyHighlight(highlightCircleSize = 5, 
                highlightSeriesBackgroundAlpha = 0.2,
                hideOnMouseOut = FALSE)
}

###
#UI
###

ui <- dashboardPage(
  dashboardHeader(title = "Interactive Analytics"),
  
  #SIDEBAR
  dashboardSidebar(
    sidebarMenu(
      menuItem("Step 1: Upload", tabName = "upload", icon = icon("upload")),
      menuItem("Step 2: Test", tabName = "test", icon = icon("vial")),
      menuItem("Step 3: Advanced Test", tabName = "advanced-test", icon = icon("vials")),
      menuItem("Step 4: Prediction", tabName = "predict", icon = icon("chart-line"))
    )
  ),
  
  #BODY
  dashboardBody(
    tabItems(
      
      #####
      # First tab content
      #####
      tabItem(tabName = "upload",
              
              fluidPage(
                sidebarLayout(
                  sidebarPanel(
                    uploadUI("data", "User data (.csv format)"),
                  ),
                  mainPanel(
                    dataTableOutput("table")
                    )
                  )
                )
              ),
      
      #####
      # Second tab content
      #####
      tabItem(tabName = "test",
              fluidPage(
                
                fluidRow(
                  h3("Overview: Interactive Data Exploration"),
                  dygraphOutput("visualize")
                ),
                
                fluidRow(
                  column(6,
                         h3("Test 1: Autcorrelation Function"),
                         plotOutput("test.acf")
                  ),
                  
                  column(6,
                         h3("Test 2: Partial Autcorrelation Function"),
                         plotOutput("test.pacf")
                  )
                  )
              )
      ),
              
      #####
      # Third tab content
      #####
      tabItem(tabName = "advanced-test",
              h2("Work in progress:"),
              h3("Crossvalidation test is coming soon....")
              ),
      
      #####
      # Fourth tab content
      #####
      tabItem(tabName = "predict",
              
              fluidPage(
                
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
              
              ),
      
      #####
      # Fifth tab content
      #####
      tabItem(tabName = "download",
              h2("Work in progress:"),
              h3("Here you will be able to download a full report of your analysis.")
              )
    ),
  )
)

###
#SERVER
###

server <- function(input, output, session) {
  
  ###
  #Step 1
  #UPLOADED DATA
  ###
  
  data <- uploadServer("data", stringsAsFactors = FALSE)
  
  #DATA TABLE
  output$table <- renderDataTable({
    data()
  })
  
  ###
  #Step 2
  #DATA Testing
  ###
  
  output$visualize <- renderDygraph({
    #to transform the df from the module into a time series
    data.ts <- data() %>% read.zoo()
    custom_dygraph(data.ts)
  })
  
  output$test.acf <- renderPlot({
    data.acf <- Acf(data()$value, plot = F)
    autoplot(data.acf)
  })
  
  output$test.pacf <- renderPlot({
    data.pacf <- Pacf(data()$value, plot = F)
    autoplot(data.pacf)
  })
  
  ###
  #Step 3
  #Advanced Testing (Crossvalidation)
  ###
  
  #
  # COMING SOON...
  #
  
  ###
  #Step 4
  #PREDICTION
  ###

  timeseries  <- reactive({
    df <- data()
    ts.list <- predictServer("predictModule", df)
  })
  
  output$dygraph.fc <- renderDygraph({
    ts.list <- timeseries()
    ts <- ts.list()[1] %>% data.frame()
    custom_dygraph(ts)
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