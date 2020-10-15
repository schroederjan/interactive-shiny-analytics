## app.R ##
library(shinydashboard)
library(shiny)

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
      menuItem("Step 2: Visualize", tabName = "visualize", icon = icon("table"))
    )
  ),
  
  #BODY
  dashboardBody(
    tabItems(
      # First tab content
      tabItem(tabName = "upload",
              
              fluidRow(
                sidebarLayout(
                  sidebarPanel(
                    uploadModuleInput("datafile"),
                    tags$hr(),
                    checkboxInput("row.names", "Append row names"),
                    downloadModuleInput("download")
                  ),
                  mainPanel(
                    dataTableOutput("table")
                    )
                  )
                )
            
              ),
      
      # Second tab content
      tabItem(tabName = "visualize",
              h2("Widgets tab content")
      )
    )
  ),
)

###
#SERVER
###

server <- function(input, output, session) {
  
  datafile <- callModule(uploadModule, "datafile")
  
  output$table <- renderDataTable({
    datafile()
  })
  
  callModule(downloadModule, "download", datafile, reactive(input$row.names))

}

shinyApp(ui, server)