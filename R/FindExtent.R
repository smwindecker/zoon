#' @name FindExtent
#' @title Determine the Extent of Interest
#'
#' @description Helper function to define an extent (in latitude and longitude)
#'   describing the area of interest for modelling. Opens a world map, on which
#'   you can click to twice to determine the area of interest.
#'
#' @details This is just a thin wrapper around \code{raster::getExtent},
#'   providing the world map to click on and reporting the extent as a rounded
#'   vector.
#'
#' @param initial_extent optional numeric vector or extent object defining the
#'   giving the extent (in latitude and longitude) of the world map to plot.
#'   This should be larger than the target extent so that you can click within
#'   it. Can be useful for 'zooming in' to an area to define an extent more
#'   precisely.
#'
#' @param resolution how detailed to make national borders in the plotted world
#'   map. "low" is less accurate, but faster to load than "medium"
#'
#' @param round to how many decimal places the extent should be reported. The
#'   default value rounds to 3 decimal places. Set this to \code{Inf} to prevent
#'   any rounding. This only affects the vector version of the extent printed in
#'   the console, not the extent object returned.
#'
#' @return invisibly returns an extent object, also prints a vector version of
#'   that extent to the console.
#'
#' @import rworldmap
#' @importFrom raster drawExtent
#' @importFrom grDevices grey
#' @importFrom utils data
#' @export
#'
#' @examples
#' \dontrun{
#'  # open a world map and click on two spots to print the extent to the console
#'  FindExtent()
#'
#'  # you can get the corresponding extent object too
#'  ext <- FindExtent()
#'  ext
#'
#'  # you can zoom in on an area and increase the resolution, and precision of
#'  # the extent vector
#'  FindExtent(c(112, 156, -44, -8),
#'             resolution = "medium",
#'             round = 6)
#' }
FindExtent <- function (initial_extent = c(-180, 180, -90, 90),
                        resolution = c("low", "medium"),
                        round = 3) {

  # reset the graphics parameters on exit
  old_mar <- par()$mar
  on.exit({
    par(mar = old_mar)
  })

  resolution <- match.arg(resolution)
  env <- environment()
  data_name <- switch(resolution,
    low = data(
      "countriesCoarse",
      package = "rworldmap",
      envir = env
    ),
    medium = data(
      "countriesLow",
      package = "rworldmap",
      envir = env
    )
  )

  initial_extent_vector <- as.vector(initial_extent)

  par(mar = rep(0, 4))
  plot(
    get(data_name),
    col = grey(0.85),
    xlim = initial_extent_vector[1:2],
    ylim = initial_extent_vector[3:4],
    border = grey(0.9)
  )

  message("click at two points on the map to define an extent")
  ext <- raster::drawExtent()

  # return the vector as text and the extent as an object
  ext_vector <- round(as.vector(ext), round)
  message("extent: ", capture.output(dput(ext_vector)))
  invisible(ext)
}
