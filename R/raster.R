raster_brick <- function(x) {
  out <- NULL
  if (find_format(x)== "jpg") {
    out <- jpeg::readJPEG(x)
  }
  if (find_format(x) == "png") {
    out <- png::readPNG(x)
  }
  if (is.null(out)) stop(sprintf("cannot read %s", x))
  out <- out*255
  mode(out) <- "integer"
  raster::setExtent(raster::brick(out), raster::extent(0, nrow(out), 0, ncol(out)))
}

raster_readAll <- function(x) {
  if (!raster::hasValues(x)) x <- raster::readAll(x)
  x
}

find_format <- function(x) {
  x <- basename(x)
  ## jpg or png
  if (grepl("jpg", x)) fmt <- "jpg"
  if (grepl("png", x)) fmt <- "png"
  if (is.null(fmt)) stop(sprintf("unknown format", x))
  fmt
}
