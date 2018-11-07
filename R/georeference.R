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
#' Currently only Mapbox spherical Mercator is supported.
#'
#' @param tile_x x coordinate of tile
#'
#' @param tile_y y coordinate of tile
#' @param zoom  zoo level
#' @param tile_size tile dimensions (assumed square atm, 256*256)
#'
#' @importFrom stats setNames
#' @export
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
