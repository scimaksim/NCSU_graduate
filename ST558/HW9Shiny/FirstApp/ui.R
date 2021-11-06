#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(caret)
data("GermanCredit")
library(shiny)
library(DT)

# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Summaries for German Credit Data"),
  
  # Sidebar with a slider input for number of bins
  sidebarLayout(
    sidebarPanel(
      h3("This data set comes from the", a(href="https://topepo.github.io/caret/", target = "_blank", "caret package "), "- originally from the UCI machine learning repository"),
      br(),
      h4("You can create a few bar plots using the radio buttons below."),
      radioButtons(inputId = "plotType", 
                   label = "Select the Plot Type",
                   choices = list("Just Classification",
                                  "Classification and Unemployed",
                                  "Classification and Foreign")),
      br(),
      h4("You can find the sample mean for a few variables below:"),
      selectInput(
        inputId = "summaryVariable",
        label = "Variables to Summarize",
        choices = c("Duration", "Amount", "Age"),
        selected = "Age"
      ),
      
      numericInput(inputId = "roundDigits",
                   label = "Select the number of digits for rounding",
                   value = 2, min = 0, max = 5),
      
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
      plotOutput("dataPlot"),
      
      dataTableOutput("dataTable")
      )
    )
  ))

