

is_spatial <- function(x) {
  if (inherits(x, "Spatial") ||
      inherits(x, "sf") ||
      inherits(x, "sfc") ||
      inherits(x, "BasicRaster") ||
      inherits(x, "Extent")) {
    return(TRUE)
  }
  FALSE
}

spatial_bbox <- function(loc, buffer = NULL) {
  if (is_spatial(loc)) {
    ## turn loc into a longlat point
    ## and a buffer
    if (inherits(loc, "Extent")) {
      spx <- spex::spex(loc, crs = "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0")

      if (!raster::couldBeLonLat(spx)) {
        stop("raw extent 'loc' does not seem to be longitude/latitude (use object with CRS)")
      }
    } else {
      spx <- spex::spex(loc)
    }
    loc <- spex_to_pt(spx)
    buffer <- spex_to_buff(spx)/2
  }
  if (is.null(buffer)) buffer <- c(0, 0)
  ## handle case where loc had either no width or no height
  if (any(!buffer > 0)) {
    # one of the values is gt 0
    if (any(buffer > 0)) buffer <- rep(max(buffer, 2L))
    if (all(!buffer > 0)) {
      warning("input object has no width or height, using default buffer (5000m)")
      buffer <- c(5000, 5000)
    }
  }
  buffer <- rep(buffer, length.out = 2L)
  if (length(loc) > 2) {
    warning("'loc' should be a length-2 vector 'c(lon, lat)' or matrix 'cbind(lon, lat)'")
  }
  if (is.null(dim(loc))) {
    loc <- matrix(loc[1:2], ncol = 2L)
  }


  ## convert loc to mercator meters
  loc <- slippymath::lonlat_to_merc(loc)

  xp <- buffer[1] ## buffer is meant to be from a central point, so a radius
  yp <- buffer[2]

  ## xmin, ymin
  ## xmax, ymax
  bb_points <- matrix(c(loc[1,1] - xp, loc[1,2] - yp, loc[1,1] + xp, loc[1,2] + yp), 2, 2, byrow = TRUE)

  if (!slippymath::within_merc_extent(bb_points)){
    warning("The combination of buffer and location extends beyond the tile grid extent. The buffer will be truncated.")
    bb_points <- slippymath::merc_truncate(bb_points)
  }

  ## convert bb_points back to lonlat
  bb_points_lonlat <- slippymath::merc_to_lonlat(bb_points)

  tile_bbox <- c(xmin = bb_points_lonlat[1,1], ymin = bb_points_lonlat[1,2],
               xmax = bb_points_lonlat[2,1], ymax = bb_points_lonlat[2,2])
  user_points <- bb_points

  list(tile_bbox = tile_bbox, user_points = user_points)
}
spex_to_pt <- function(x) {
  pt <- cbind(mean(c(raster::xmax(x), raster::xmin(x))),
              mean(c(raster::ymax(x), raster::ymin(x))))
  srcproj <- raster::projection(x)
  if (is.na(srcproj)) {
    if (raster::couldBeLonLat(x, warnings = FALSE)) {
      warning("loc CRS is not set, assuming longlat")
      raster::projection(x) <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0 "
    }
  }

  if (!raster::isLonLat(x)) {
    pt <- reproj::reproj(pt, "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0 ", source = raster::projection(x))[, 1:2, drop = FALSE]
  }
  pt
}
#' @importFrom stats approx
project_spex <- function(x, crs) {
  ex <- c(raster::xmin(x), raster::xmax(x), raster::ymin(x), raster::ymax(x))
  idx <- c(1, 1, 2, 2, 1,
           3, 4, 4, 3, 3)
  xy <- matrix(ex[idx], ncol = 2L)
  afun <- function(aa) stats::approx(seq_along(aa), aa, n = 180L)$y
  srcproj <- raster::projection(x)
  if (is.na(srcproj)) {
    if (raster::couldBeLonLat(x, warnings = FALSE)) {
      warning("loc CRS is not set, assuming longlat")
      srcproj <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs +towgs84=0,0,0 "
    } else {
      stop("loc CRS is not set, and does not seem to be longitude/latitude data")
    }
  }
  raster::extent(reproj::reproj(cbind(afun(xy[,1L]), afun(xy[,2L])), target = crs, source = srcproj)[, 1:2])
}
spex_to_buff <- function(x) {
  ex <- project_spex(x, "+proj=merc +a=6378137 +b=6378137")
  c(raster::xmax(ex) - raster::xmin(ex),
    raster::ymax(ex) - raster::ymin(ex))
}
