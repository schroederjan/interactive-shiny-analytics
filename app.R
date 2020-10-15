## app.R ##
library(shinydashboard)
library(shiny)
library(dygraphs)
library(glue)
library(zoo)

###
#MODULES
###

source("modules/uploadModule.R")
source("modules/downloadModule.R")

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
              
              fluidRow(
                sidebarLayout(
                  sidebarPanel(
                    uploadModuleInput("datafile"),
                    tags$hr(),
                    checkboxInput("row.names", "Append row names"),
                    #downloadModuleInput("download")
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
                dygraphOutput("dygraph")
              )
      ),
  
      #####
      # Third tab content
      #####
      tabItem(tabName = "test",
              h2("Work in progress:"),
              h3("Here you will be able to apply simple statistical tests to your data.")
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
              h2("Work in progress:"),
              h3("Here you will be able to predict your data.")
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
  
  #UPLOADED DATA
  datafile <- callModule(uploadModule, "datafile")
  
  #DATA TABLE
  output$table <- renderDataTable({
    datafile()
  })
  
  #DATA VISUALIZATION
  output$dygraph <- renderDygraph({
    
    #to transform the df from the module into a time series
    data.ts <- datafile() %>% 
      read.zoo()
  
    #TODO add the files name as a header
    dygraph(data.ts, main = glue("Uploaded Data:")) %>% 
    dyRangeSelector() %>% 
    #dyOptions(colors = RColorBrewer::brewer.pal(10, "BrBG")[c(9,4)]) %>% 
    dyUnzoom() %>% 
    dyCrosshair(direction = "vertical") %>% 
    dyLegend(width = 400) %>% 
    dyHighlight(highlightCircleSize = 5, 
                highlightSeriesBackgroundAlpha = 0.2,
                hideOnMouseOut = FALSE)
    
  })

  #not included here, for later use
  #callModule(downloadModule, "download", datafile, reactive(input$row.names))

}

shinyApp(ui, server)