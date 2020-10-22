#Upload Module

#
#USER INTERFACE
#

# Module UI function
uploadUI <- function(id, label = "CSV file") {

  ns <- NS(id)
  
  tagList(
    fileInput(ns("file"), label),
    checkboxInput(ns("heading"), "Has heading", value = T),
    selectInput(ns("quote"), "Quote", c(
      "None" = "",
      "Double quote" = "\"",
      "Single quote" = "'"
    ))
  )
}

#
#SERVER
#

# Module server function
uploadServer <- function(id, stringsAsFactors) {
  moduleServer(
    id,
    ## Below is the module function
    function(input, output, session) {
      # The selected file, if any
      userFile <- reactive({
        # If no file is selected, don't do anything
        validate(need(input$file, message = FALSE))
        input$file
      })
      
      # The user's data, parsed into a data frame
      dataframe <- reactive({
        read.csv(userFile()$datapath,
                 header = input$heading,
                 quote = input$quote,
                 stringsAsFactors = stringsAsFactors
        )
        
      })
      
      # We can run observers in here if we want to
      observe({
        msg <- sprintf("File %s was uploaded", userFile()$name)
        cat(msg, "\n")
      })
      
      # Return the reactive that yields the data frame
      return(dataframe)
    }
  )    
}

### FOR TESTING

# ui <- fluidPage(
#   sidebarLayout(
#     sidebarPanel(
#       uploadUI("datafile", "User data (.csv format)")
#     ),
#     mainPanel(
#       dataTableOutput("table")
#     )
#   )
# )
# 
# server <- function(input, output, session) {
#   
#   datafile <- uploadServer("datafile", stringsAsFactors = FALSE)
#   
#   output$table <- renderDataTable({
#     datafile()
#   })
# }
# 
# shinyApp(ui, server)