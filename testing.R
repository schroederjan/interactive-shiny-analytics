library(dygraphs)
library(dplyr)
library(zoo)

#Base import
data <- read.csv("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                 stringsAsFactors=FALSE)
head(data)
str(data)

#Zoo import
data.ts <- read.csv.zoo("/data/R/Projects/interactive-shiny-analytics/data/raw/MONTH CN House Prices Monthly.csv",
                 stringsAsFactors=FALSE)
head(data.ts)
str(data.ts)



ts <- data %>% 
  read.zoo()

dygraph(ts)
