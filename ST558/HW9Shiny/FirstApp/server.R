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

library(shiny)
library(caret)
library(tidyverse)
library(DT)
data("GermanCredit")

# Define server logic 
shinyServer(function(input, output) {
    
    # Numeric summaries 
    dataSet<-reactive({
      # Store number of digits by which to round third column
      roundDig <- input$roundDigits
      
      # Use hint from assignment
      var <- input$summaryVariable
      GermanCreditSub <- GermanCredit[, c("Class", "InstallmentRatePercentage", var),
                                      drop = FALSE]
      tab <- aggregate(GermanCreditSub[[var]] ~ Class + InstallmentRatePercentage,
                       data = GermanCreditSub, FUN = mean)
      
      # Rename third column
      colRename <- paste0("Average ", var)
      colnames(tab) <- c("Class", "InstallmentRatePercentage", colRename)
      
      # Round third column values using values from numericInput in ui.R
      tab[3] <- round(tab[3], roundDig)
      
      # Print final table
      tab
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

    
    


