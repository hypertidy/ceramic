

#' Miscellaneous places
#'
#' Visit some nice locales with web tiles.
#'
#' Available types are 'mapbox.satellite', 'mapbox.outdoors', 'mapbox.terrain-rgb' but any string
#' accepted by Mapbox services will be passed through.
#'
#' @param loc a longitude, latitude pair of coordinates
#' @param buffer with in metres to extend around the location
#' @param type character string of Mapbox service (see Details)
#' @param ... dots, ignored currently
#' @param debug optionally print out files that will be used
#'
#' @return RasterBrick, with RGB
#' @export
#' @importFrom raster projection<- crop extent
#' @name cc_location
#' @examples
#' ## requres Mapbox key set in env var 'MAPBOX_API_KEY'
#' \dontrun{
#' im <- cc_macquarie()
#' library(raster)
#' plotRGB(im)
#' }
cc_location <- function(loc = NULL, buffer = 5000,
                        type = "mapbox.satellite", ..., debug = FALSE) {
  get_loc(loc = loc, buffer = buffer, type = type, ..., debug = debug)
}
#' @name cc_location
#' @export
cc_macquarie <- function(loc = c(158.93835,-54.49871), buffer = 5000,
                         type = "mapbox.outdoors", ..., debug = FALSE) {
 cc_location(loc, buffer, type = type, ..., debug = debug)
}

#' @name cc_location
#' @export
cc_davis <- function(loc = c(77 + 58/60 + 3/3600,
                              -(68 + 34/60 + 36/3600)),
                     buffer = 5000, type = "mapbox.outdoors", ..., debug = FALSE) {
#  68 34 36 S 77 58 03 E
  cc_location(loc, buffer, type = type, ..., debug = debug)

}
#' @name cc_location
#' @export
cc_mawson <- function(loc = c(62 + 52/60 + 27/3600,
                                  -(67 + 36/60 + 12/3600)), buffer = 5000, type = "mapbox.outdoors", ..., debug = FALSE) {
  # 67 36 12 S 62 52 27 E

  cc_location(loc, buffer, type = type, ..., debug = debug)

}

#' @name cc_location
#' @export
cc_casey <- function(  loc = cbind(110 + 31/60 + 36/3600,
                                    -(66 + 16/60 + 57/3600)), buffer = 5000, type = "mapbox.outdoors", ..., debug = FALSE) {
  #66 16 57 S 110 31 36 E

  cc_location(loc, buffer, type = type, ..., debug = debug)

}
#' @name cc_location
#' @export
cc_heard <- function(loc = c(73 + 30/60 + 30/3600,
                                 -(53 + 0 + 0/3600)), buffer = 5000, type = "mapbox.outdoors",..., debug = FALSE) {
#  53 S 73 30 E.

  cc_location(loc, buffer, type = type, ..., debug = debug)

}
#' @name cc_location
#' @export
cc_kingston <- function(loc = c(-147.70837,
                                    -42.98682), buffer = 5000, type = "mapbox.outdoors", ..., debug = FALSE) {
  cc_location(loc, buffer, type = type, ..., debug = debug)

}
