

fast_merge <- function(x) {
  ## about 3 times faster than reduce(, merge)
  out <- raster::raster(purrr::reduce(purrr::map(x, raster::extent), raster::union), crs = raster::projection(x[[1]]))
  raster::res(out) <- raster::res(x[[1]])
  cells <- unlist(purrr::map(x, ~raster::cellsFromExtent(out, .x)))
  vals <- do.call(rbind, purrr::map(x, ~raster::values(raster_readAll(.x))))
  raster::setValues(raster::brick(out, out, out), vals[order(cells), ])
}

get_api_key <- function(...) {
  key <- Sys.getenv("MAPBOX_API_KEY")

  if (is.null(key)) warning("no mapbox key found")
  key
}
mk_query_string <- function(baseurl,
                            type,
                            tok = "", format = "jpg") {

  paste0(sprintf("%s%s/{zoom}/{x}/{y}%s.%s", baseurl, type, tok, format),
         "?access_token=",
         get_api_key())
}

mk_query_string_custom <- function(baseurl) {
  paste0(baseurl,
         "?access_token=",
         get_api_key())
}




get_loc <- function(loc, buffer, type = "mapbox.satellite", crop_to_buffer = TRUE, format = "jpg", ..., debug = debug, max_tiles = 16L,
                    base_url = NULL) {

  if (!is.null(base_url)) {
    ## zap the type because input was a custom mapbox style (we assume)
    type <- ""
  }

  custom <- TRUE
  if (is.null(base_url)) {
    custom <- FALSE
    base_url <-  "https://api.mapbox.com/v4/"
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

  my_bbox <- c(xmin = bb_points_lonlat[1,1], ymin = bb_points_lonlat[1,2],
               xmax = bb_points_lonlat[2,1], ymax = bb_points_lonlat[2,2])

  tile_grid <- slippymath::bbox_to_tile_grid(my_bbox, max_tiles = max_tiles)
  zoom <- tile_grid$zoom

  #slippymath::bbox_tile_query(my_bbox)

  tok <- ""
  if (type == "mapbox.terrain-rgb") {
    format <- "png"
    tok <- "@2x"
  }

  if (!custom) {
    mapbox_query_string <- mk_query_string(baseurl = base_url, type = type, tok = tok, format = format)
  } else {
    mapbox_query_string <- mk_query_string_custom(baseurl = base_url)
  }

  files <- down_loader(tile_grid, mapbox_query_string, debug = debug)

   bad <- file.info(files)$size < 35
  if (all(bad)) {
    mess <-paste(files, collapse = "\n")
    stop(sprintf("no sensible tiles found, check cache?\n%s", mess))
  }
# print(cbind(files, file.exists(files))[!bad, , drop = FALSE])
  br <- lapply(files[!bad], raster_brick)

  for (i in seq_along(br)) {
    br[[i]] <- raster::setExtent(br[[i]],
                                 mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = zoom))
  }

  out <- fast_merge(br)
  projection(out) <- "+proj=merc +a=6378137 +b=6378137"
  if (crop_to_buffer) out <- raster::crop(out, raster::extent(as.vector(bb_points)), snap = "out")
  out
}


