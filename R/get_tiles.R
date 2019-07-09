get_tiles <- function(loc, zoom = NULL, type = "mapbox.satellite",
                      format = "png", max_tiles = NULL, base_url = NULL, ...) {
  if (!is.null(zoom) && !is.null(max_tiles)) {
    stop("cannot set both zoom and max_tiles")
  }
  get_loc(loc, buffer = NULL, type = type, crop_to_buffer = FALSE,
          format = format, ..., zoom = zoom, max_tiles = max_tiles, base_url = base_url)
}
