provider_from_type <- function(type) {
  if (grepl("mapbox", type)) return("mapbox")
  if (grepl("elevation-tiles-prod", type)) return("aws")
  NULL
}


get_loc <- function(loc, buffer, type = "mapbox.satellite", crop_to_buffer = TRUE,
                    format = "jpg", ..., zoom = NULL, debug = FALSE, max_tiles = NULL, base_url = NULL) {
  if (!is.null(zoom)) max_tiles <- NULL
  if (!is.null(base_url)) {
    ## zap the type because input was a custom mapbox style (we assume)
    type <- ""
  }

  bbox_pair <- spatial_bbox(loc, buffer)

  my_bbox <- bbox_pair$tile_bbox
  bb_points <- bbox_pair$user_points


  tile_grid <- slippymath::bbox_to_tile_grid(my_bbox, max_tiles = max_tiles, zoom = zoom)
  zoom <- tile_grid$zoom

  if (is.null(base_url)) {
    provider <- provider_from_type(type)
    if (is.null(provider)) stop(sprintf("Provider for '%s' not known", type))
    query_string <- switch(provider,
                           mapbox = mapbox_string(type = type, format = format),
                           aws = aws_string())
  } else {  ## handle custom
    query_string <- mk_query_string_custom(baseurl = base_url)
  }


 files <- unlist(down_loader(tile_grid, query_string, debug = debug))
   bad <- file.info(files)$size < 35
  if (all(bad)) {
    mess <-paste(files, collapse = "\n")
    stop(sprintf("no sensible tiles found, check cache?\n%s", mess))
  }
   user_ex <- NULL
  if (crop_to_buffer) user_ex <- raster::extent(as.vector(bb_points))
  list(files = files[!bad], tiles = tile_grid, extent = user_ex)
}


