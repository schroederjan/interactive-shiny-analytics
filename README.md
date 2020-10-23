# Interactive Analytics with Shiny
> Want a quick, professional and interactive way of predicting some time series data without needing to code? Look no further! This is supposed to be a go to template for interactive advanced analytics for time series data.

## Table of contents
* [Introduction](#introduction)
* [Background](#background)
* [Dependencies](#dependencies)
* [Setup](#setup)
* [Features](#features)
* [Status](#status)
* [Inspiration](#inspiration)
* [Contact](#contact)

## Introduction
This projects contains a ready to go shiny web application for interactive quick advanced predictive data analytics. Shiny is a package from RStudio that makes it possible to build interactive web applications with R.

{COMING SOON} For a more detailed tutorial of how to use this applicaion in praxis, visit my [Homepage](http://schroederjan.com/).

## Background
This projects is a showcase for an idea that I had when working at Siemens in Chengdu, China.
I want to provide a simple and easy way for non-programmers to use advanced algorithms for time series predictions. You can think about sales, orders, deliveries, storage or other logistical, financial or even technical data sets that are still not yet been analysed in a structured way. 

In an data science team you can surerly just exchange the code for some advanced analytics, but the insight will be limited to people that can code (R in this case). With a shiny application you can share your insight with colleagues and give them a customised tool for future reference for similar problems. 
And all that without endless IT resources bound to it.

## Dependencies
For the project to work you need R, Rstudio, knowledge of Shiny (To get the app running locally) and install all packages used in this project (more below).

* [R & RStudio](https://rstudio.com)

All R versions should be fine, I was using the stable version 3.6.3 though.
If you need more help of what R and RStudio is and how to install it you can look it up [here](https://rstudio.com/products/rstudio/download/#download)

* [Shiny](http://shiny.rstudio.com/tutorial/)

To learn more I recommend you check out the [Shiny Tutorial](http://shiny.rstudio.com/tutorial/). The tutorial explains the framework in-depth, walks you through building a simple application, and includes extensive annotated examples.

* R Packages

In my experience, there is no big problem with different versions of those packages on Windows or Ubuntu.
In general it should be the easiest to just install the packages written in the [packages.R](https://github.com/AionosChina/interactive-shiny-analytics/blob/main/modules/packages.R) file.

If there are some issues you can have a look at my session information below.
```r
sessionInfo()

R version 3.6.3 (2020-02-29)
Platform: x86_64-pc-linux-gnu (64-bit)
Running under: Ubuntu 20.04.1 LTS

#attached base packages:
stats
graphics
grDevices
utils
datasets
methods
base     

#other attached packages:
readr_1.4.0
glue_1.4.2
shinydashboard_0.7.1
xts_0.12.1
lubridate_1.7.9
tibbletime_0.1.6
rlang_0.4.8
purrr_0.3.4
tibble_3.0.4
timetk_2.4.0        
forecast_8.13
zoo_1.8-8 
dplyr_1.0.2 
dygraphs_1.1.1.6  
shiny_1.5.0         
```
## Setup
Describe how to install / setup your local environement / add link to demo version.

## Module Examples
Show examples of usage:
`put-your-code-here`

## Features:
* Awesome feature 1
* Awesome feature 2
* Awesome feature 3

## To-do list:
* Setup
* Module Examples
* Features
* Live Usecase
* Crossvalidation

## Status
Project is _in progress_ and will be expanded with new features soon.
My goal is it to build a state of the art "Prediction Tool" template that can be customised at will.

## Inspiration
TBD

## Contact
Created by [Jan Schroeder](https://www.schroederjan.com/) - feel free to contact me!

