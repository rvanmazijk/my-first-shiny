# Draw crayon-like Cartesian functions using rasters! (app.R version)
# Ruan van Mazik
# 2017-08-16

if (!require(pacman)) install.packages("pacman")
library(pacman)
p_load(raster, tidyverse, glue, stringr, shiny)

draw <- function(fun_y = "y",
                 fun_x = "x",
                 lwt = 0.05,
                 x = seq(-1, 1, by = 0.02),  # i.e. in 100ths
                 y = seq(-1, 1, by = 0.02)) {

    fun_child <- function(x, y) {}
    body(fun_child) <- parse(text = glue(
        "({y} < {x} + {lwt}) && ({y} > {x} - {lwt})",
        x = fun_x, y = fun_y, lwt = lwt
    ))

    z <- matrix(nrow = length(x), ncol = length(y))
    for (i in 1:nrow(z)) {
        for (j in 1:ncol(z)) {
            z[nrow(z) + 1 - i, ncol(z) + 1 - j] <- fun_child(-x[i], y[j])
        }
    }

    op <- par()
    par(mar = c(0.2, 0.2, 0.2, 0))
    plot(raster(t(z)), legend = FALSE, xaxt = "n", yaxt = "n")
    par(op)

}

ui <- shinyUI(fluidPage(
    titlePanel("Graph functions using rasters"),
    sidebarLayout(
        sidebarPanel(

            # Formula input to draw
            textInput(inputId = "formula_y", label = "LHS:", value = "y"),
            textInput(inputId = "formula_x", label = "RHS:", value = "x"),

            # X & Y plotting ranges
            sliderInput(inputId = "range_y", label = "y-range",
                        min = -10, max = 10,
                        value = c(-1, 1), dragRange = TRUE)
        ),
        # Draw!
        mainPanel(plotOutput("drawPlot"))
    )
))

server <- shinyServer(function(input, output) {
    output$drawPlot <- renderPlot({
        draw(fun_y = input$formula_y, fun_x = input$formula_x)
    })
})

shinyApp(ui = ui, server = server)

# TODO: add functionality to display more/less of the Cartesian plain,
#       i.e. beyond the [|1|,|1|] square
