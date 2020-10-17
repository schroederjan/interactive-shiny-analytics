# Upload Module
library(shiny)

uploadInput <- function(id, label = "upload") {
  ns <- NS(id)
  tagList(
    fileInput(ns("file"), "Select a csv file"),
    checkboxInput(ns("heading"), "Has header row", value = T),
    checkboxInput(ns("strings"), "Coerce strings to factors", value = F)
  )
}

uploadServer <- function(id){
  moduleServer(
    id,
    function(input, output, session, ...) {
      userFile <- reactive({
        # If no file is selected, don't do anything
        req(input$file)
      })
      # The user's data, parsed into a data frame
      output$data <- reactive({
        raw <- read.csv(userFile()$datapath,
                        header = input$heading,
                        stringsAsFactors = input$strings,
                        ...)
        data <- raw %>% na.omit(value)
        })
    }
  )
}
  
#
# TESTING
#

ui <- fluidRow(
  sidebarLayout(
    sidebarPanel(
      uploadInput("upload", "Upload")
    ),
    mainPanel(
      dataTableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  datafile <- uploadServer("upload")
  
  #DATA TABLE
  output$table <- renderDataTable({
    datafile()
  })
  
}

shinyApp(ui, server)