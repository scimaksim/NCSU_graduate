# Author: Maksim Nikiforov
# Dynamic UI Homework
# ST558 - Fall, 2021
# Completed on November 08, 2021

library(ggplot2)

shinyUI(fluidPage(
  
  # Application title
  # Change the title based on which "vore" is selected
  uiOutput("dynamicTitle"),
  
  # Sidebar with options for the data set
  sidebarLayout(
    sidebarPanel(
      h3("Select the mammal's biological order:"),
      selectizeInput("vore", "Vore", selected = "omni", choices = levels(as.factor(msleep$vore))),
      br(),
      sliderInput("size", "Size of Points on Graph",
                  min = 1, max = 10, value = 5, step = 1),
      checkboxInput("conservation", h4("Color Code Conservation Status", style = "color:red;")),
      
      # Only show if "Color Code Conservation Status" is selected
      conditionalPanel(condition = "input.conservation",
                       checkboxInput("opacity", h5("Also change symbol based on REM sleep?")))
    ),
    
    # Show outputs
    mainPanel(
      plotOutput("sleepPlot"),
      textOutput("info"),
      tableOutput("table")
      )
  )
))
