fast_merge <- function(x) {
  ## not actually faster ...
  out <- raster(purrr::reduce(purrr::map(x, raster::extent), raster::union), crs = raster::projection(x[[1]]))
  raster::res(out) <- res(x[[1]])
 # cells <- purrr::map(x, ~raster::cellFromXY(out, coordinates(.x)))
  cells <- purrr::map(x, ~raster::cellsFromExtent(out, .x))
  l <- replicate(nlayers(x[[1]]), out, simplify = FALSE)
  for (i in seq_along(l)) {
    l[[i]][unlist(cells)] <- unlist(purrr::map(x, ~raster::values(.x[[i]])))
  }
  raster::brick(l)
}

cc_macquarie <- function(buffer = 5000, ..., debug = FALSE) {


  loc <- cbind(158.93835,
               -54.49871)
  if (length(buffer) == 1) buffer <- rep(buffer, 2)
xp <- buffer[1] / (1852 * 60) * cos(loc[1, 2, drop = TRUE] * pi/180)
yp <- buffer[2] / (1852 * 60)

  my_bbox <- structure(c(xmin = loc[1] - xp, ymin = loc[2] - yp,
              xmax = loc[1] + xp, ymax = loc[2] + yp), crs = structure(list(epsg = 4326,
                                                                              proj4string = "+proj=longlat +ellps=WGS84 +no_defs"), class = "crs"), class = "bbox")
  tile_grid <- slippymath:::bb_to_tg(my_bbox, max_tiles = 36)
  zoom <- tile_grid$zoom

  mapbox_query_string <-
    paste0("https://api.mapbox.com/v4/mapbox.outdoors/{zoom}/{x}/{y}.jpg90",
           "?access_token=",
           Sys.getenv("MAPBOX_API_KEY"))

  files <- down_loader(tile_grid, mapbox_query_string, debug = debug)
  br <- lapply(files, raster::brick)

  for (i in seq_along(br)) {
    br[[i]] <- raster::setExtent(br[[i]],
                         mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = zoom))
  }
  fast_merge(br)
}
