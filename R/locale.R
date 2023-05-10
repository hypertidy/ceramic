

#' Obtain tiled imagery by location query
#'
#' Obtain imagery or elevation data by location query. The first argument
#' `loc` may be a spatial object (sp, raster, sf) or a 2-column matrix with a single
#' longitude and latitude value. Use `buffer` to define a width and height to pad
#' around the raw longitude and latitude in metres. If `loc` has an extent, then
#' `buffer` is ignored.
#'
#' `cc_elevation` does extra work to unpack the DEM tiles from the RGB format.
#'
#' Available types are 'elevation-tiles-prod' for AWS elevation tiles, and 'mapbox.satellite',
#' and 'mapbox.terrain-rgb', 'tasmap' or one of 'tasmap_street' (TTSA), 'tasmap_aerialphoto2020', 'tasmap_aerialphoto2021', 'tasmap_aerialphoto2022', 
#' 'tasmap_aerialphoto2023', 'tasmap_esgismapbookpublic', 'tasmap_hillshadegrey', 'tasmap_hillshade', 'tasmap_orthophoto', 
#' 'tasmap_simplebasemap', 'tasmap_tasmap100k', 'tasmap_tasmap250k', 'tasmap_tasmap25k', 'tasmap_tasmap500k', 'tasmap_tasmapraster', 'tasmap_topographicgrayscale', 'tasmap_topographic'. 
#'
#' Note that arguments `max_tiles` and `zoom` are mutually exclusive. One or both must be `NULL`. If
#' both are NULL then `max_tiles = 16L`.
#'
#'
#' @param loc a longitude, latitude pair of coordinates, or a spatial object
#' @param buffer with in metres to extend around the location, ignored if 'loc' is a spatial object with extent
#' @param type character string of provider imagery type (see Details)
#' @param ... deprecated arguments that _used_to_be_ passed to internal function now ignored since v 0.8.0 (see [get_tiles()])
#' @param zoom deprecated (use `dimension`)
#' @param max_tiles deprecated
#' @param debug deprecated
#' @param dimension one or two numbers, used to determine the number of pixels width, height - set one to zero to let GDAL figure it out, or leave as NULL to get something suitable
#'
#' @return A [terra::rast()] object, either with three layers (Red, Green, Blue) or with
#' a single layer in the case of [cc_elevation()].
#' @export
#' @name cc_location
#' @aliases cc_elevation
#' @examples
#' if (!is.null(get_api_key())) {
#'
#'  img <- cc_location(cbind(147, -42), buffer = 1e5)
#'
#'  ## this source does not need the Mapbox API, but we won't run the example unless it's set
#'  dem <- cc_kingston(buffer = 1e4, type = "elevation-tiles-prod")
#'  terra::plot(dem, col = grey(seq(0, 1, length = 94)))
#'
#'  ## Mapbox imagery
#'  im <- cc_macquarie()
#'  plotRGB(im)
#'  }
cc_location <- function(loc = NULL, buffer = 5000,
                        type = "mapbox.satellite", ..., zoom = NULL, max_tiles = NULL,  debug = FALSE, dimension = NULL) {
  if (!is.null(zoom) || !is.null(max_tiles)) message("'zoom' and 'max_tiles' are ignored")
  if (!is.null(list(...)$base_url)) message("'base_url' is ignored for data loading, use 'get_tiles(, base_url= <>)'")
  #if (is.null(zoom) && is.null(max_tiles)) max_tiles <- 16L
  #locdata <- get_tiles(x = loc, buffer = buffer, type = type, ..., zoom = zoom, max_tiles = max_tiles, debug = debug)

  if (is.null(loc)) {
    loc <- as.matrix(cities_n(1L, fields = FALSE))
  }
 locdata <- loc_extent(loc, buffer, dimension)

  #if (debug) {
  #  return(invisible(NULL))
  #}

    if (type == 'mapbox.satellite') d<-  gdal_mapbox(extent = locdata[1:4], dimension = as.integer(locdata[5:6]), projection = "EPSG:3857")
    if (type == "elevation-tiles-prod") d <- gdal_aws(extent = locdata[1:4], dimension = as.integer(locdata[5:6]), projection = "EPSG:3857") 
    if (type == "mapbox.terrain-rgb") d <- gdal_terrainrgb(extent = locdata[1:4], dimension = as.integer(locdata[5:6]), projection = "EPSG:3857") 
    if (grepl("tasmap", type)) {
      if (type == "tasmap") type <- "tasmap_orthophoto"
      d <- gdal_tasmap(extent = locdata[1:4], dimension = as.integer(locdata[5:6]), projection = "EPSG:3857", type = gsub("tasmap_", "", type))
    }
  d
}

#' @name cc_location
#' @export
cc_macquarie <- function(loc = c(158.93835,-54.49871), buffer = 5000,
                         type = "mapbox.satellite", ..., zoom = NULL, max_tiles = NULL, debug = FALSE, dimension = NULL) {
 cc_location(loc, buffer, type = type, ..., zoom = zoom, max_tiles = max_tiles, debug = debug, dimension = dimension)
}

#' @name cc_location
#' @export
cc_davis <- function(loc = c(77 + 58/60 + 3/3600,
                              -(68 + 34/60 + 36/3600)),
                     buffer = 5000, type = "mapbox.satellite", ..., zoom = NULL, max_tiles = NULL, debug = FALSE, dimension = NULL) {
.Defunct(msg = "removed, no longer works with mapbox")
}
#' @name cc_location
#' @export
cc_mawson <- function(loc = c(62 + 52/60 + 27/3600,
                                  -(67 + 36/60 + 12/3600)), buffer = 5000, type = "mapbox.satellite", ..., zoom = NULL, max_tiles = NULL, debug = FALSE, dimension = NULL) {
  # 67 36 12 S 62 52 27 E
  .Defunct(msg = "removed, no longer works with mapbox")
}

#' @name cc_location
#' @export
cc_casey <- function(  loc = cbind(110 + 31/60 + 36/3600,
                                    -(66 + 16/60 + 57/3600)), buffer = 5000, type = "mapbox.satellite", ...,zoom = NULL, max_tiles = NULL,debug = FALSE, dimension = NULL) {
  #66 16 57 S 110 31 36 E
  .Defunct(msg = "removed, no longer works with mapbox")
}
#' @name cc_location
#' @export
cc_heard <- function(loc = c(73 + 30/60 + 30/3600,
                                 -(53 + 0 + 0/3600)), buffer = 5000, type = "mapbox.satellite",...,zoom = NULL, max_tiles = NULL, debug = FALSE, dimension = NULL) {
#  53 S 73 30 E.
  cc_location(loc, buffer, type = type, ..., zoom = zoom, max_tiles = max_tiles, debug = debug, dimension = dimension)
}
#' @name cc_location
#' @export
cc_kingston <- function(loc = c(147.2901,
                                    -42.98682), buffer = 5000, type = "mapbox.satellite", ...,zoom = NULL, max_tiles = NULL, debug = FALSE, dimension = NULL) {
  cc_location(loc, buffer, type = type, ..., zoom = zoom, max_tiles = max_tiles, debug = debug, dimension = dimension)
}
#' @name cc_location
#' @export
cc_elevation <- function(loc = NULL, buffer = 5000, type = NULL, ...,zoom = NULL, max_tiles = NULL, debug = FALSE, dimension = NULL) {
  if (is.null(loc)) {
   
      loc <- as.matrix(cities_n(1L, fields = FALSE))
   
  }
    locdata <- loc_extent(loc, buffer, dimension)
  
  if (is.null(type) || type == "mapbox.terrain-rgb") {
    dat <- gdal_terrainrgb(extent = locdata[1:4], dimension = as.integer(locdata[5:6]), projection = "EPSG:3857")
    
  } else {
    dat <- gdal_aws(extent = locdata[1:4], dimension = as.integer(locdata[5:6]), projection = "EPSG:3857")
  }
  dat
  
}
