#-------------------------------------
# ACF & PACF
#-------------------------------------

tidy_acf <- function(data, value, lags = 0:50) {
  
  value_expr <- enquo(value)
  
  acf_values <- data %>%
    pull(value) %>%
    acf(lag.max = tail(lags, 1), plot = F) %>%
    .$acf %>%
    .[,,1]
  
  ret <- tibble(acf = acf_values) %>%
    rowid_to_column(var = "lag") %>%
    mutate(lag = lag - 1) %>%
    filter(lag %in% lags)
  
  return(ret)
}
tidy_pacf <- function(data, value, lags = 0:50) {
  
  value_expr <- enquo(value)
  
  acf_values <- data %>%
    pull(value) %>%
    pacf(lag.max = tail(lags, 1), plot = F) %>%
    .$acf %>%
    .[,,1]
  
  ret <- tibble(acf = acf_values) %>%
    rowid_to_column(var = "lag") %>%
    mutate(lag = lag - 1) %>%
    filter(lag %in% lags)
  
  return(ret)
}