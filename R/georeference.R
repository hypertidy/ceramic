#' @importFrom tibble tibble
#' @importFrom dplyr filter
spherical_mercator <- function(provider) {
  #MAXEXTENT is the bounds between [-180, 180] and [-85.0511, 85.0511]
  tibble::tibble(provider = "mapbox",
                 MAXEXTENT = 20037508.342789244,
                 A = 6378137.0, B = 6378137.0,
                 crs = glue::glue("+proj=merc +a={A} +b={A}")) %>%
    dplyr::filter(provider == provider)
}
#' Tile extent
#'
#' Calculate tile extent for a given x, y tile at a zoom level.
#'
#' Currently only spherical Mercator is supported.
#'
#' @param tile_x x coordinate of tile
#'
#' @param tile_y y coordinate of tile
#' @param zoom  zoo level
#' @param tile_size tile dimensions (assumed square, i.e. 256x256)
#'
#' @importFrom stats setNames
#' @export
#' @return A numeric vector of the spatial extent, in 'xmin', 'xmax', 'ymin', 'ymax' form.
#' @examples
#' mercator_tile_extent(2, 4, zoom = 10)
#'
#' global <- mercator_tile_extent(0, 0, zoom = 0)
#' plot(NA, xlim = global[c("xmin", "xmax")], ylim = global[c("ymin", "ymax")])
#' rect_plot <- function(x) rect(x["xmin"], x["ymin"], x["xmax"], x["ymax"])
#' rect_plot(mercator_tile_extent(1, 1, zoom = 2))
#' rect_plot(mercator_tile_extent(2, 1, zoom = 2))
#' rect_plot(mercator_tile_extent(1, 2, zoom = 2))
#'
#' rect_plot(mercator_tile_extent(1, 1, zoom = 4))
#' rect_plot(mercator_tile_extent(2, 1, zoom = 4))
#' rect_plot(mercator_tile_extent(1, 2, zoom = 4))
mercator_tile_extent <- function(tile_x, tile_y, zoom, tile_size = 256) {
  if (any(!c(length(tile_x), length(tile_y), length(zoom), length(tile_size)) == 1)) {
    stop("tile_x, tile_y, zoom, tile_size must all be of length 1")
  }
  params <- spherical_mercator(provider = "mapbox")
  params <- params[1, ]  ## FIXME: param query should provide a unique set, this is WIP
  #st_transform(st_as_sfc(my_bbox), glue("+proj=merc +a={A} +b={A}"))
  MAXEXTENT <- params$MAXEXTENT
  A <- params$A
  ## literal width/height of a square tile at zoom = 0
  z0_size <- (MAXEXTENT * 2)
  xlim <- -MAXEXTENT + (tile_x + c(0, 1)) * (z0_size/(2^zoom))
  ## upside down Ms. Jane
  ylim <- range(MAXEXTENT - (tile_y + c(0, 1) - 0) * (z0_size/(2^zoom)))
  stats::setNames(c(xlim, ylim), c("xmin", "xmax", "ymin", "ymax"))
}

add_extent <- function(x) {
  ## assert tibble with tile_x, tile_y, zoom
  l <- purrr::map(purrr::transpose(x), ~mercator_tile_extent(.x$tile_x, .x$tile_y, .x$zoom))
  x[c("xmin", "xmax", "ymin", "ymax")] <- tibble::as_tibble(do.call(rbind, l))
  x
}

#' Plot slippy map tiles
#'
#' Create a new plot of tile rectangles, or add to an existing plot.
#'
#' The extent ('xmin', 'xmax', 'ymin', 'ymax') is used directly to draw the tiles so must be in the
#' native Mercator coordinate system used by most tile servers.
#' @param x tiles as create by `ceramic_tiles()`
#' @param ... arguments passed to `graphics::rect()`
#' @param add add to an existing plot?
#' @param label include text label?
#' @param cex relative size of text label if drawn (see `text()`)
#' @param add_coast include a basic coastline on the plot?
#' @param include_zoom include zoom level with text label if drawn?
#' @export
#' @return [plot_tiles()] is called for its side-effect, a plot, and returns `NULL` invisibly.
#' [tiles_to_polygon] returns a simple features polygon data frame.
#' @importFrom sp plot
#' @importFrom graphics rect text
#' @aliases tiles_to_polygon
#' @examples
#' if (!is.null(get_api_key())) {
#'   get_tiles_zoom(zoom = 1)
#'   tiles <- ceramic_tiles(zoom = 1)
#'   plot_tiles(tiles)
#' }
plot_tiles <- function(x, ..., add = FALSE, label = TRUE, cex = 0.6, add_coast = TRUE, include_zoom = TRUE) {
  if (!all(c("xmin", "xmax", "ymin", "ymax") %in% names(x))) stop("need xmin, xmax, ymin, ymax columns")
  if (include_zoom && !"zoom" %in% names(x) ) stop("need zoom columns for 'include_zoom = TRUE'")
  if (!add) plot(range(c(x$xmin, x$xmax)), range(c(x$ymin, x$ymax)), type = "n", xlab = "x", ylab = "y")
  graphics::rect(x$xmin, x$ymin, x$xmax, x$ymax, ...)
  if (label) {
    if (include_zoom) {
      tile_lab <- sprintf("%i [%i,%i]", x$zoom, x$tile_x, x$tile_y)
      } else {
      tile_lab <- sprintf("[%i,%i]", x$tile_x, x$tile_y)
      }
    graphics::text((x$xmin + x$xmax) / 2,
         (x$ymin + x$ymax) / 2, label = tile_lab, cex = cex)
  }
  if (add_coast) sp::plot(merc_world, border = "darkgrey", add = TRUE)
  invisible(NULL)
}

#' @name plot_tiles
#' @export
tiles_to_polygon <- function(x) {
  spex::polygonize(tiles_to_raster(x))
}
tiles_to_raster <- function(x) {
  ex <- raster::extent(min(x$xmin), max(x$xmax), min(x$ymin), max(x$ymax))
  pts <- x[c("tile_x", "tile_y")] %>% dplyr::transmute(x = tile_x - min(tile_x), y = max(tile_y) - tile_y) %>% dplyr::distinct()
  r <- raster::setExtent(raster::rasterFromXYZ(pts), ex)
  cells <- raster::cellFromRowCol(r, pts$y + 1, pts$x + 1)
  r[cells] <- cells
  r
}
