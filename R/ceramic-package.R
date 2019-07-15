#' Obtain imagery tiles
#'
#' The ceramic package provides tools to download and load imagery and raster tiles from online servers.
#'
#' Any process that can trigger downloads will first check the [ceramic_cache()] in case the tile already exists.
#'
#'
#' The main functions are for downloading tiles and loading them as raster objects, and each accepts a spatial
#'   object for the first argument, alternatively a raster extent, or location:
#'
#'
#'   \tabular{ll}{
#'   \code{\link{get_tiles}}\tab Download tiles for a given service for an extent and resolution\cr
#'   \code{\link{get_tiles_buffer}}\tab Download tiles based on location and buffer (width, height) in metres\cr
#'   \code{\link{get_tiles_dim}}\tab Download tiles based on extent and output dimension in pixels\cr
#'   \code{\link{get_tiles_zoom}}\tab Download tiles base on extent and zoom level \cr
#'   }
#'
#'   Two helper functions will trigger the download of tiles and also collate the result into a raster object:
#'
#'
#'   \tabular{ll}{
#'   \code{\link{cc_location}}\tab Download tiles and build a raster object of imagery\cr
#'   \code{\link{cc_elevation}}\tab Download tiles and build a raster object of elevation data\cr
#'   }
#'
#'
#'
#'
#'  Administration functions for handling the file cache and required API key for on online service:
#'
#'
#'   \tabular{ll}{
#'   \code{\link{get_api_key}}\tab Return the stored key for online API, or NULL \cr
#'   \code{\link{ceramic_cache}}\tab Report the location of the tile cache \cr
#'   \code{\link{clear_ceramic_cache}}\tab Delete all files in the tile cache (use with caution!) \cr
#'   }
#'
#'   Other functions that are either rarely used or considered subject to change:
#'
#'   \tabular{ll}{
#'   \code{\link{ceramic_tiles}}\tab Find particular tiles from the cache \cr
#'   \code{\link{mercator_tile_extent}}\tab Abstract raster-extent form of the spherical Mercator tile system, expressed in tile-index and zoom \cr
#'   \code{\link{plot_tiles}}\tab Plot the tiles from \code{\link{ceramic_tiles}} \cr
#'   \code{\link{tiles_to_polygon}}\tab Convert \code{\link{ceramic_tiles}} to simple features format \cr
#'   \code{\link{cc_casey}}\tab Specific location hardcoded form of \code{\link{cc_location}} \cr
#'   \code{\link{cc_davis}}\tab Specific location hardcoded form of \code{\link{cc_location}} \cr
#'   \code{\link{cc_heard}}\tab Specific location hardcoded form of \code{\link{cc_location}} \cr
#'   \code{\link{cc_kingston}}\tab Specific location hardcoded form of \code{\link{cc_location}} \cr
#'   \code{\link{cc_macquarie}}\tab Specific location hardcoded form of \code{\link{cc_location}} \cr
#'   \code{\link{cc_mawson}}\tab Specific location hardcoded form of \code{\link{cc_location}} \cr
#'   }
#'
#' @name ceramic-package
#' @aliases ceramic
#' @docType package
NULL



#' Deprecated functions from ceramic
#'
#' @keywords internal
#' @noRd
get_loc <- function(...) {
  .Deprecated("get_tiles")
  get_tiles(...)
}
