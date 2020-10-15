# Upload Module

uploadModuleInput <- function(id) {
  ns <- NS(id)

  tagList(
    fileInput(ns("file"), "Select a csv file"),
    checkboxInput(ns("heading"), "Has header row", value = T),
    checkboxInput(ns("strings"), "Coerce strings to factors", value = F)
  )
}

uploadModule <- function(input, output, session, ...) {

  userFile <- reactive({
    # If no file is selected, don't do anything
    req(input$file)
  })

  # The user's data, parsed into a data frame
  reactive({
    
    raw <- read.csv(userFile()$datapath,
      header = input$heading,
      stringsAsFactors = input$strings,
      ...)
    
    data <- raw %>% na.omit(value) 
    
  })
}