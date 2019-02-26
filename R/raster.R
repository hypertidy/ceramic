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
  ## in case it's greyscale ...
  if (length(dim(out)) == 2L) out <- array(out, c(dim(out), 1L))
  raster::setExtent(raster::brick(out), raster::extent(0, nrow(out), 0, ncol(out)))
}

raster_readAll <- function(x) {
  if (!raster::hasValues(x)) x <- raster::readAll(x)
  x
}

find_format <- function(x) {
  ## jpg or png
  if (is_jpeg(x)) fmt <- "jpg"
  if (is_png(x))  fmt <- "png"
  if (is.null(fmt)) stop(sprintf("unknown format", x))
  fmt
}
