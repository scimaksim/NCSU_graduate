# Application author: Maksim Nikiforov
# ST558 - Fall, 2021
# Completed November 07, 2021
# 
# FirstShiny application (assignment 9)
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(caret)
data("GermanCredit")
library(shiny)
library(DT)

# Define UI for application
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Summaries for German Credit Data"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h3("This data set comes from the", a(href="https://topepo.github.io/caret/", target = "_blank", "caret package "), "- originally from the UCI machine learning repository"),
      # Line break
      br(),
      # Text line
      h4("You can create a few bar plots using the radio buttons below."),
      
      # Radio buttons for plot type
      radioButtons(inputId = "plotType", 
                   label = "Select the Plot Type",
                   choices = c("Just Classification" = "justClass",
                                  "Classification and Unemployed" = "classUnemployed",
                                  "Classification and Foreign" = "classForeign")),
      # Line break
      br(),
      # Line of text with bold "sample mean"
      h4("You can find the ", strong("sample mean "), "for a few variables below:"),
      
      # Dropdown ("variables to summarize")
      selectInput(
        inputId = "summaryVariable",
        label = "Variables to Summarize",
        choices = c("Duration", "Amount", "Age"),
        selected = "Age"
      ),
      
      # Numeric input (number of digits to use when rounding)
      numericInput(inputId = "roundDigits",
                   label = "Select the number of digits for rounding",
                   value = 2, min = 0, max = 5),
    ),
    
    
    mainPanel(
      # Show a bar plot ("Class" count in GermanCredit data set)
      plotOutput("dataPlot"),
      
      # Show a DT data frame 
      dataTableOutput("dataTable")
      )
    )
  ))

