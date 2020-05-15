MAXEXTENT <- 20037508
A <- 6378137
proj4 <- sprintf("+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +R=A +units=m +no_defs")

llproj4 <- .ll()
globalVariables(c("MAXETENT", "A", "proj4", "llproj4"), "ceramic", add = TRUE)

virtual_tiles <- function(zoom = 0, extent = NULL) {
  if (is.null(extent)) {
    ex <- c(xmin = -180, xmax = 180,
            ymin = -85.0511, ymax = 85.0511)
  } else {
    ex <- raster::extent(extent)
    ex <- c(xmin = raster::xmin(ex), xmax = raster::xmax(ex),
            ymin = raster::ymin(ex), ymax = raster::ymax(ex))
  }

  bb <- structure(ex, crs = structure(list(proj4string = llproj4,
                                                 epsg = NA_integer_), class = "crs"),
                  class = "bbox")
  slippymath::bbox_to_tile_grid(bb, zoom = zoom, max_tiles = Inf)
}

