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
    
    # Numeric summaries (provided in "hint")
    dataSet<-reactive({
      roundDig <- input$roundDigits
      
      var <- input$summaryVariable
      GermanCreditSub <- GermanCredit[, c("Class", "InstallmentRatePercentage", var),
                                      drop = FALSE]
      tab <- aggregate(GermanCreditSub[[var]] ~ Class + InstallmentRatePercentage,
                       data = GermanCreditSub, FUN = mean) 
      
    })
    
    # Barplot 
    dataPlot<-reactive({
      # Grab selection from radio buttons
      radioInput <- input$plotType
      
      # Select plot based on radio butotn choice
      if (radioInput == "justClass") {
        p<-ggplot(data=GermanCredit,aes(x=Class))+geom_bar()
        
      } else if (radioInput == "classUnemployed") {
        p<-ggplot(data=GermanCredit,aes(x=Class))+
          geom_bar(aes(fill = as.character(EmploymentDuration.Unemployed)), position = "dodge") +
          scale_fill_discrete(name = "Unemployment Status", labels=c("Employed", "Unemployed"))
        
      } else  {
        p<-ggplot(data=GermanCredit,aes(x=Class))+
          geom_bar(aes(fill = as.character(ForeignWorker)), position = "dodge") +
          scale_fill_discrete(name = "Status", labels=c("German", "Foreign"))
      }
      
      # Draw plot
      p
    })

    # Render plot
    output$dataPlot<-renderPlot(dataPlot())   

    # Render DT data table
    output$dataTable <- renderDataTable(dataSet())
      
    })

    
    


