# Module definition, new method
myModuleUI <- function(id, label = "Input text: ") {
  ns <- NS(id)
  tagList(
    textInput(ns("txt"), label),
    textOutput(ns("result"))
  )
}

myModuleServer <- function(id, prefix = "") {
  moduleServer(
    id,
    function(input, output, session) {
      output$result <- renderText({
        paste0(prefix, toupper(input$txt))
      })
    }
  )
}

# Use the module in an application
ui <- fluidPage(
  myModuleUI("myModule1"),
  myModuleUI("myModule2")
)
server <- function(input, output, session) {
  myModuleServer("myModule1", prefix = "Converted to uppercase: ")
  myModuleServer("myModule2", prefix = "Converted to uppercase: ")
}
shinyApp(ui, server)