# Predict Module

#
#USER INTERFACE
#

predictUI <- function(id) {
  
  ns <- NS(id)
  
  tagList(
    sliderInput(ns("time_horizon"), "Time Horizon:", min = 1, max = 48, value = 6),
    checkboxInput(ns("PI"), "Activate PI?", value = F)
  )
}

#
#SERVER
#

testServer <- function(id, data) {
  moduleServer(id, function(input, output, session) {
    
    data <- reactive({data})
    ts <- data %>% read.zoo()
    
    # Return the reactive that yields the timeseries
    return(ts)
  }
  )
}
