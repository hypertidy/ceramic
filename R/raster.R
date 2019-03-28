make_raster <- function(loc_data) {
  files <- loc_data$files
  tile_grid <- loc_data$tiles
  user_extent <- loc_data$extent

  br <- lapply(files, raster_brick)

  for (i in seq_along(br)) {
    br[[i]] <- raster::setExtent(br[[i]],
                                 mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = tile_grid$zoom))
  }

  out <- fast_merge(br)
  projection(out) <- "+proj=merc +a=6378137 +b=6378137"
  if (!is.null(user_extent)) out <- raster::crop(out, user_extent , snap = "out")
  out
}

raster_brick <- function(x) {
  out <- NULL
  if (find_format(x) == "tif") {
    ## jump out now
    if (!requireNamespace("rgdal", quietly = TRUE)) {
      stop(sprintf("rgdal is required (by raster) for reading GeoTIFF files: %s", x))
    }
    out <-  raster::brick(x)
    return(raster::setExtent(out, raster::extent(0, nrow(out), 0, ncol(out))))
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
  raster::setExtent(raster::brick(out), raster::extent(0, nrow(out), 0, ncol(out)))
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



fast_merge <- function(x) {
  ## about 3 times faster than reduce(, merge)
  out <- raster::raster(purrr::reduce(purrr::map(x, raster::extent), raster::union), crs = raster::projection(x[[1]]))
  raster::res(out) <- raster::res(x[[1]])
  cells <- unlist(purrr::map(x, ~raster::cellsFromExtent(out, .x)))
  vals <- do.call(rbind, purrr::map(x, ~raster::values(raster_readAll(.x))))
  raster::setValues(raster::brick(out, out, out), vals[order(cells), ])
}
