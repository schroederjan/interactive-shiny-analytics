## app.R ##

###
#MODULES
###

source("modules/packages.R")
source("modules/uploadModule.R")
source("modules/downloadModule.R")
source("modules/predictModule.R")
source("modules/test_module.R")

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
      menuItem("Step 2: Visualization", tabName = "visualize", icon = icon("chart-bar")),
      menuItem("Step 3: Test", tabName = "test", icon = icon("vial")),
      menuItem("Step 4: Advanced Test", tabName = "advanced-test", icon = icon("vials")),
      menuItem("Step 5: Prediction", tabName = "predict", icon = icon("chart-line")),
      menuItem("Step 6: Download", tabName = "download", icon = icon("download"))
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
                    uploadUI("data", "User data (.csv format)")
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
      tabItem(tabName = "visualize",
              
              fluidPage(
                dygraphOutput("visualize")
              )
      ),
  
      #####
      # Third tab content
      #####
      tabItem(tabName = "test",
              
              fluidRow(
                box(
                  plotOutput("test.acf")
                ),
                box(
                  plotOutput("test.pacf")
                )
              )
      ),
      
      #####
      # Fourth tab content
      #####
      tabItem(tabName = "advanced-test",
              
              h2("Work in progress:"),
              h3("Here you will be able to apply advanced statistical tests to your data.")
              
      ),
      
      #####
      # Fifth tab content
      #####
      tabItem(tabName = "predict",
              
              fluidRow(
                sidebarLayout(
                  sidebarPanel(
                    predictModuleInput("nnetar_config")
                  ),
                  
                  mainPanel(
                    dygraphOutput("predict")
                  )
                )
              )
             
      ),
      
      #####
      # Sixth tab content
      #####
      tabItem(tabName = "download",
              
              h2("Work in progress:"),
              h3("Here you will be able to download a full report of your analysis.")
              
      )
      
    )
  ),
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
  #DATA VISUALIZATION
  ###
  
  output$visualize <- renderDygraph({
    
    #to transform the df from the module into a time series
    data.ts <- data() %>% read.zoo()
    custom_dygraph(data.ts)
    
  })
  
  ###
  #Step 3
  #TEST
  ###

  output$test.acf <- renderPlot({
    data.acf <- acf(data()$value, plot = F)
    autoplot(data.acf)
  })
  
  output$test.pacf <- renderPlot({
    data.pacf <- pacf(data()$value, plot = F)
    autoplot(data.pacf)
  })
  
  ###
  #Step 6
  #PREDICTION
  ###
  
  #DYGRAPH PREDICTION
  output$predict <- renderDygraph({
    
    TS <- testServer("predict", data())
    print(TS())
    #dygraph(TS())
    
    #ts <- predictServer("predict", data())
    #print(ts())
    #dygraph(ts)
    
  })

}

shinyApp(ui, server)