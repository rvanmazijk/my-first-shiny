# Draw crayon-like Cartesian functions using rasters!
# Ruan van Mazik
# created:     2017-07-17
# last edited: 2017-07-19

library(pacman)
p_load(raster, tidyverse, glue, reticulate, rPython, stringr, magrittr)
# not() is only from magrittr :)/:(/:?

draw <- function(fun_y = "y",
                 fun_x = "x",
                 lwt = 0.05,
                 x = seq(-1, 1, by = 0.02),
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

draw_py <- function(fun_y = "y",
                    fun_x = "x",
                    lwt = 0.05,
                    x = seq(-1, 1, by = 0.02),
                    y = seq(-1, 1, by = 0.02),
                    debug = FALSE) {
    if (debug) {
        fun_y = "-y^2 / 0.25"
        fun_x = "(x^2 / 0.75) - 1"
    }
    fun_child <- function(x, y) {}
    body(fun_child) <- parse(text = glue(
        "({y} < {x} + {lwt}) && ({y} > {x} - {lwt})",
        x = fun_x, y = fun_y, lwt = lwt
    ))
    foo <- character()
    for (i in 1:length(head(fun_child)[-1])) {
        foo %<>% paste0(
            head(fun_child)[-1][
                length(head(fun_child)[-1]) -
                (length(head(fun_child)[-1]) - i)
            ]
        )
    }
    fun_child_char <- foo %>%
        str_replace_all("&&", replacement = "and") %>%
        str_replace_all("\\^", replacement = "**") %>%
        str_replace_all("y", replacement = "float(y)") %>%
        str_replace_all("x", replacement = "float(x)")
    rm(foo)
    if (debug) {
        return(fun_child_char)
    } else if (not(debug)) {
        z <- matrix(nrow = length(x), ncol = length(y))
        #x <- 1:10; y <- seq(0, 0.1, by = 0.1/10)
        python.assign(value = x, var.name = "x")
        python.assign(value = y, var.name = "y")
        python.assign(value = z, var.name = "z")
        python.assign(value = fun_child_char, var.name = "fun_child_char")
        python.exec('
            def fun_child(x, y):
                if eval(fun_child_char):
                    return True
                else:
                    return False
            for i in range(len(x)):
                for j in range(len(y)):
                    z[i][j] = fun_child(-x[i], y[j])
        ')
        z_py <- python.get("z")
        for (i in 1:nrow(z)) {
            for (j in 1:ncol(z)) {
                z[nrow(z) + 1 - i, ncol(z) + 1 - j] <- z_py[[i]][j]
            }
        }
        op <- par()
        par(mar = c(0.2, 0.2, 0.2, 0))
        z %>%
            t() %>%
            raster() %>%
            plot(legend = FALSE, xaxt = "n", yaxt = "n")
        on.exit(par(op))
    }
}

# Some straight lines
draw()
draw_py()
draw("y", "x")
draw_py("y", "x")
draw("y", "2*x + 1")
draw_py("y", "2*x + 1")
# Some polynomials
draw("y", "x^2")
draw_py("y", "x^2")
draw("y", "4*x^3")
draw_py("y", "4*x^3")
# Some circles
draw("-y^2", "x^2")
draw_py("-y^2", "x^2")
draw("-y^2 + 2", "x^2 + 1.5")
draw_py("-y^2 + 2", "x^2 + 1.5")

# Some ellipses
draw("-y^2 / 0.25", "(x^2 / 0.75) - 1", lwt = 0.25)
draw_py("-y^2 / 0.25", "(x^2 / 0.75) - 1.0", lwt = 0.25)

python.exec('print float(1)')

# Weird stuff (experimental)
draw("-y^2 / x", "(x^2 / y) - 1", lwt = 0.1)
draw_py("-y^2 / x", "(x^2 / y) - 1", lwt = 0.1)  # FIXME
# (^-- Python indexes by 0... so y/(x=0) is a problem)

draw("-y^3 / x", "(x^3 / y) - 1", lwt = 0.1)
draw("-y^2 / exp(x)", "(x^2 / y) - 1", lwt = 0.1)
for (i in seq(-2, 2, by = 0.25)) {
    draw(
        glue("-y^2 / x"),
        glue("(x^2 / y) + {i}"),
        lwt = 0.1
    )
}
for (i in seq(-10, 10, by = 1)) {
    draw(
        glue("-y^{i} / x"),
        glue("(x^{i} / y + 1)"),
        lwt = 0.1
    )
}
