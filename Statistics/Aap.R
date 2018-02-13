library(shiny)
library(ggplot2)
library(ggthemes)

# server logic required to draw a histogram
shinyServer(function(input, output) {
  trials = 100
  
  balls <- c(1, 1, 1, 0, 0)
  number_of_red_balls <- vector(mode = "integer", length = trials)
  
  for (n in 1:trials){
    s = sample(balls, 4, replace = T)
    number_of_red_balls[n] <- sum(s)
    
  }
  # Takes the value of 'action' from input
  output$redPlot <- renderPlot({
    t = min(trials, input$action)
    qplot(number_of_red_balls[1:t], fill="#f98866", binwidth=0.25, col=I("black"))  + 
      xlab("X (Number of red balls)") +
      ylab("Frequency") +
      scale_x_continuous(breaks=c(0,1,2,3,4)) +
      coord_cartesian(xlim = c(0, 5), expand = T) + coord_cartesian(ylim = c(0, 40)) +
      theme_minimal()+theme(legend.position = "none")+theme(text = element_text(size=14))
    
  })
  
  output$probPlot <- renderPlot({
    t = min(trials, input$action)
    red = data.frame(number_of_red_balls[1:t])
    colnames(red) <- "red"
    
    r = red$red
    s = summary(factor(r, levels=c(0,1,2,3,4)))
    agg = sum(s)
    s = s/agg
    s = data.frame(s)
    s$x1 = c(0, 1, 2, 3, 4)
    ggplot(s, aes(x=factor(x1), y=s, width=0.45)) + geom_bar(stat="identity", fill="#f98866", colour="black") +
      theme_minimal() +
      coord_cartesian(ylim = c(0, 1)) + xlab("X (Number of red balls)") +
      ylab("Probability")+theme(legend.position = "none")+theme(text = element_text(size=14))
    
  })
  
  output$value <- renderPrint({
    number_of_red_balls[1:min(trials,input$action)]
  })
})