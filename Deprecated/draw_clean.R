# Draw crayon-like Cartesian functions using rasters!
# Ruan van Mazik
# 2017-08-16

draw <- function(fun_y = "y",
                 fun_x = "x",
                 lwt = 0.05,
                 x = seq(-1, 1, by = 0.02),
                 y = seq(-1, 1, by = 0.02)) {

    if (!require(pacman)) install.packages("pacman")
    library(pacman)
    p_load(raster, tidyverse, glue, stringr)

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
