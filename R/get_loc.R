get_mapbox <- function(x = NULL, ..., type = "mapbox.satellite", max_tiles = 4, debug = FALSE) {
  tile_grid <- x #; slippymath:::bb_to_tg(x, max_tiles = max_tiles)
  zoom <- x$zoom

  #slippymath::bb_tile_query(my_bbox)

  mapbox_query_string <-
    paste0(sprintf("https://api.mapbox.com/v4/%s/{zoom}/{x}/{y}.jpg90", type),
           "?access_token=",
           Sys.getenv("MAPBOX_API_KEY"))

  files <- down_loader(tile_grid, mapbox_query_string, debug = debug)
  br <- lapply(files, raster::brick)

  for (i in seq_along(br)) {
    br[[i]] <- raster::setExtent(br[[i]],
                                 mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = zoom))
  }

  out <- fast_merge(br)
  projection(out) <- "+proj=merc +a=6378137 +b=6378137"
  out
}


fast_merge <- function(x) {
  ## about 3 times faster than reduce(, merge)
  out <- raster::raster(purrr::reduce(purrr::map(x, raster::extent), raster::union), crs = raster::projection(x[[1]]))
  raster::res(out) <- raster::res(x[[1]])
  cells <- unlist(purrr::map(x, ~raster::cellsFromExtent(out, .x)))
  vals <- do.call(rbind, purrr::map(x, ~raster::values(raster::readAll(.x))))
  raster::setValues(raster::brick(out, out, out), vals[order(cells), ])
}


get_loc <- function(loc, buffer, type = "mapbox.outdoors", crop_to_buffer = TRUE, ..., debug = debug, max_tiles = 16L) {
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

  tile_grid <- slippymath:::bb_to_tg(my_bbox, max_tiles = max_tiles)
  zoom <- tile_grid$zoom

  #slippymath::bb_tile_query(my_bbox)

  mapbox_query_string <-
    paste0(sprintf("https://api.mapbox.com/v4/%s/{zoom}/{x}/{y}.jpg90", type),
           "?access_token=",
           Sys.getenv("MAPBOX_API_KEY"))

  files <- down_loader(tile_grid, mapbox_query_string, debug = debug)
  br <- lapply(files, raster::brick)

  for (i in seq_along(br)) {
    br[[i]] <- raster::setExtent(br[[i]],
                                 mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = zoom))
  }

  out <- fast_merge(br)
  projection(out) <- "+proj=merc +a=6378137 +b=6378137"
  if (crop_to_buffer) out <- raster::crop(out, raster::extent(as.vector(bb_points)), snap = "out")
  out
}


