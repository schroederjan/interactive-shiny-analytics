library(shiny)
source("modules/sample_ui.R")
source("modules/sample_server.R")

ui <- fluidPage(
  sidebarLayout(
    sidebarPanel(
      csvFileUI("datafile", "User data (.csv format)")
    ),
    mainPanel(
      dataTableOutput("table")
    )
  )
)

server <- function(input, output, session) {
  datafile <- csvFileServer("datafile", stringsAsFactors = FALSE)

  output$table <- renderDataTable({
    datafile()
  })
}

shinyApp(ui, server)