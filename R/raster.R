#' @importFrom terra rast
make_raster <- function(loc_data) {
  files <- loc_data$files
  tile_grid <- loc_data$tiles
  user_extent <- loc_data$extent
  files <- normalizePath(files)
  if (find_format(files[1]) == "tif") {
    out <- terra::merge(terra::sprc(lapply(files, terra::rast)))
    #terra::crs(out) <- "EPSG:3857"
    out <- raster::raster(out)
    raster::projection(out) <- "+proj=merc +a=6378137 +b=6378137"
    ## short circuit, the old way is not working
    return(out)
  }
  br <- lapply(files, raster_brick)

  for (i in seq_along(br)) {
    br[[i]] <- raster::setExtent(br[[i]],
                                 mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = tile_grid$zoom))
  }

  out <- fast_merge(br)
  raster::crs(out) <- sp::CRS(.merc(), doCheckCRSArgs = FALSE)
  if (!is.null(user_extent)) out <- raster::crop(out, user_extent , snap = "out")
  out
}

raster_brick <- function(x) {
  out <- NULL
  if (find_format(x) == "tif") {
    #out <-  raster::brick(terra::rast(x))
    #return(raster::setExtent(out, raster::extent(0, nrow(out), 0, ncol(out))))
    return(terra::rast(out))
  }
  if (find_format(x)== "jpg") {
    out <- jpeg::readJPEG(x)
  }
  if (find_format(x) == "png") {
    out <- png::readPNG(x)
  }

  if (is.null(out)) stop(sprintf("cannot read %s", x))
  out <- out*255
  mode(out) <- "integer"
  ## in case it's greyscale ...
  if (length(dim(out)) == 2L) out <- array(out, c(dim(out), 1L))
 # raster::setExtent(raster::brick(out), raster::extent(0, nrow(out), 0, ncol(out)))
 raster::brick(out)
}

raster_readAll <- function(x) {
  if (!raster::hasValues(x)) x <- raster::readAll(x)
  x
}

find_format <- function(x) {
  fmt <- NULL
  if (grepl("tif$", x)) return("tif")
  ## jpg or png
  if (is_jpeg(x)) fmt <- "jpg"
  if (is_png(x))  fmt <- "png"
  if (is.null(fmt)) stop(sprintf("unknown format", x))
  fmt
}


#' @importFrom raster cellsFromExtent
fast_merge <- function(x) {

  ## about 3 times faster than reduce(, merge
 crs <- raster::projection(x[[1]])

  out <- raster::raster(purrr::reduce(lapply(x, raster::extent), raster::union), crs = crs)
  raster::res(out) <- raster::res(x[[1]])
#  cells <- unlist(purrr::map(x, ~raster::cellsFromExtent(out, .x)))
  cells <- unlist(lapply(x, function(.x) cellsFromExtent(out, .x)), use.names = FALSE)
  vals <- do.call(rbind, lapply(x, function(.x) raster::values(raster_readAll(.x))))
  raster::setValues(raster::brick(out, out, out), vals[order(cells), ])
}
