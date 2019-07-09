#' @keywords internal
"_PACKAGE"


#' Australian coastline
#'
#' The Australian coastline in simple features form, on a Lambert Azimuthal Equal Area projection.
#'
#' This data set was derived from the 'oz' package.
#' @name oz_laea
#' @docType data
NULL


#' Deprecated functions from ceramic
#'
#' @keywords internal
#' @NoRd
get_loc <- function(...) {
  .Deprecated("get_tiles")
  get_tiles(...)
}
