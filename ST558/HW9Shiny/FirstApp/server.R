#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(caret)
library(tidyverse)
library(DT)
data("GermanCredit")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

    output$distPlot <- renderPlot({

        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')

    })
    
    dataSet<-reactive({
      var <- input$summaryVariable
      GermanCreditSub <- GermanCredit[, c("Class", "InstallmentRatePercentage", var),
                                      drop = FALSE]
      tab <- aggregate(GermanCreditSub[[var]] ~ Class + InstallmentRatePercentage,
                       data = GermanCreditSub, FUN = mean)      
      
    })

    #create plot
    output$dataPlot<-renderPlot({
      data<-dataSet()
      
      p<-ggplot(data=data,aes(x=Class))+geom_bar()
      p
    })   

    
    output$dataTable <- renderDataTable(dataSet())
      
    })

    
    


