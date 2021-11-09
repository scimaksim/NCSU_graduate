# Author: Maksim Nikiforov
# Dynamic UI Homework
# ST558 - Fall, 2021
# Completed on November 08, 2021

library(shiny)
library(dplyr)
library(ggplot2)

shinyServer(function(input, output, session) {
  
	getData <- reactive({
		newData <- msleep %>% filter(vore == input$vore)
	})
	
  #create plot
  output$sleepPlot <- renderPlot({
  	#get filtered data
  	newData <- getData()
  	
  	#create plot
  	g <- ggplot(newData, aes(x = bodywt, y = sleep_total))
  	
  	# Checkbox-related tasks
  	if(input$conservation){
  	  
  	  # Change opacity of the scatter plot points is "opacity" check box is selected
  	  if(input$opacity) {
  	    g + geom_point(size = input$size, aes(col = conservation, alpha = sleep_rem))
  	    
  	  } else{
  	    g + geom_point(size = input$size, aes(col = conservation))
  	  }
  	  
  	} else {
  		g + geom_point(size = input$size)
  	}
  })
  
  # If "opacity" checkbox is selected, 
  # change minimum value of "size" slider from 1 to 3. 
  # If unclicked, the minimum goes back to 1.
  observe(if(input$opacity){
    updateSliderInput(session, "size", min = 3)
  } else {
    updateSliderInput(session, "size", min = 1)
  })

  #create text info
  output$info <- renderText({
  	#get filtered data
  	newData <- getData()
  	
  	paste("The average body weight for order", input$vore, "is", round(mean(newData$bodywt, na.rm = TRUE), 2), "and the average total sleep time is", round(mean(newData$sleep_total, na.rm = TRUE), 2), sep = " ")
  })
  
  #create output of observations    
  output$table <- renderTable({
		getData()
  })
  
  output$dynamicTitle <- renderUI({
    if(input$vore == "carni"){
      titleText <- paste0("Investigation of Carnivore Mammal Sleep Data")
    } else if(input$vore == "herbi") {
      titleText <- paste0("Investigation of Herbivore Mammal Sleep Data")
    } else if(input$vore == "insecti") {
      titleText <- paste0("Investigation of Insectivore Mammal Sleep Data")
    } else {
      titleText <- paste0("Investigation of Omnivore Mammal Sleep Data")
    }
    
    h1(titleText)
  })
  
})
