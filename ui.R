
# This is the user-interface definition of a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)

shinyUI(fluidPage(

    # Application title
    titlePanel("Draw functions using rasters!"),

    # Formula input to draw
    sidebarLayout(
        sidebarPanel(
            textInput(inputId = "formula_y", label = "Function formula Y:"),
            textInput(inputId = "formula_x", label = "Function formula X:"),
            submitButton(text = "Submit")
        ),
        # Draw!
        mainPanel(plotOutput("drawPlot"))
    )

))
