#' Clear ceramic cache
#'
#' Delete all downloaded files in the [ceramic_cache()].
#' @param clobber set to `TRUE` to avoid checks and delete files
#' @param ... reserved for future arguments, currently ignored
#' @export
#' @return This function is called for its side effect, but also returns the file paths as a
#' character vector whether deleted or not, or NULL if the user cancels.
clear_ceramic_cache <- function(clobber = FALSE, ...){
 files <- fs::dir_ls(ceramic_cache(), all = FALSE, recurse = TRUE)
 if (length(files) < 1) {
   message("No files in cache. Nothing to do.")
   return(invisible(NULL))
 }
 if (!clobber) {
   if (!interactive()) stop("Cannot delete cache without interactive mode, unless 'clobber = TRUE'")
   answer <- utils::askYesNo(sprintf("Delete all downloaded ceramic tiles? (%i files in cache)", length(files)))
 } else {
   answer <- TRUE
 }
 if (is.na(answer)) {message("Cancelled."); return(invisible(NULL))}
 if (!answer) {message("Cache not removed.")}
 if (answer) {
   tst <- fs::dir_delete(ceramic_cache())
   message(sprintf("%i cache files removed.", length(files)))
   return(invisible(files))
 }
 invisible(files)
}

#' Download tool for image tiles
#'
#' Tiles are cached with the native name of the source.
#'
#' This function is not for direct use
#' @param x tiles object
#' @param query_string an api query template (see Details)
#' @param clobber if `TRUE` re download any existing tiles
#' @param ... ignored
#' @param debug simple debugging info printed if `TRUE`
#' @param verbose print messages
#' @return A list with data frame of tiles, zoom level and file paths.
#' @noRd
#' @keywords internal
#' @importFrom curl curl_download
#' @importFrom fs dir_exists dir_create file_info
#' @importFrom glue glue
#' @importFrom rappdirs user_cache_dir
#' @importFrom purrr pmap
down_loader <- function(x, query_string, clobber = FALSE, ..., debug = FALSE, verbose = TRUE) {
  if (verbose) {
    provider <- strsplit(query_string, '\\{')[[1]][1]
    message(glue::glue("Preparing to download: {nrow(x$tiles)} tiles at zoom = {x$zoom} from \n {provider}"))
  }
  purrr::pmap(x$tiles,
              function(x, y, zoom){
                api_query <- glue::glue(query_string)

                outfile <- url_to_cache(api_query)

                if (debug) {
                  #print(outfile)
                  return(outfile)
                }
                if (!file.exists(outfile) || clobber || fs::file_info(outfile)$size < 35) {
                  cachedir <- fs::path_dir(outfile)

                  if (!fs::dir_exists(cachedir)) fs::dir_create(cachedir, recurse = TRUE)
                ## FIXME: need to error on no API_KEY present

                  zup <- curl::curl_download(url = api_query,
                                       outfile)
                }
                outfile
              },
              zoom = x$zoom)
}


#' Tile files
#'
#' Find existing files in the cache. Various options can be controlled, this is
#' liable to change pending generalization across providers.
#'
#' @param zoom zoom level
#'
#' @param type imagery type
#' @param source imagery source
#' @param glob see `fs::dir_ls`
#' @param regexp see `fs::dir_ls`
#' @return A data frame of tile file paths with tile index, zoom, type, version,
#' source and spatial extent.
#' @export
#' @importFrom rlang .data
#' @importFrom stringr str_extract
#' @examples
#' if (interactive() && !is.null(get_api_key())) {
#'  tiles <- ceramic_tiles(zoom = 0)
#' }
ceramic_tiles <- function(zoom = NULL, type = "mapbox.satellite",
                          source = "api.mapbox.com", glob = NULL, regexp = NULL) {

  ## FIXME: assert that zoom, type, source, all are length 1
  bfiles <-
    fs::dir_ls(ceramic_cache(), recurse = TRUE, type = "file",
               glob = glob, regexp = regexp)

  tile_index <- strsplit(str_extract(bfiles, "[0-9]+/[0-9]+/[0-9]+"), "/")
  ok <- lengths(tile_index) == 3L
  if (sum(ok) < 1) stop("no tile files found")
  
  if (!all(ok)) {
    tile_index <- tile_index[ok]
    bfiles <- bfiles[ok]
  }
  tile_index <- do.call(rbind, tile_index)
  
  tile_x <- as.numeric(tile_index[,2L, drop = TRUE])
  tile_y <- as.numeric(tile_index[,3L, drop = TRUE])
  zooms <- as.numeric(tile_index[,1L, drop = TRUE])
  bad <- is.na(tile_x) | is.na(tile_y) | is.na(zoom) 
  bad <- bad | (tile_x < 0) | (tile_y < 0) | (zoom < 0)
  bad <- bad | (tile_x > .Machine$integer.max) | (tile_y > .Machine$integer.max) | (zoom >   .Machine$integer.max)
  if (any(bad)) {
    if (all(bad)) stop("could not parse tile index for any files from cache")
    tile_x <- tile_x[!bad]
    tile_y <- tile_y[!bad]
    zooms <- zooms[!bad]
    bfiles <- bfiles[!bad]
  }
  files <- tibble::tibble(tile_x = as.integer(tile_x), 
                          tile_y = as.integer(tile_y), 
                          zoom = as.integer(zooms), 
                          type = tile_type(bfiles),
                          version = tile_version(bfiles),
                          source = tile_source(bfiles), fullname = bfiles)

  ## filter type first, then zoom
  atype <- type
  if (!is.null(type)) files <- dplyr::filter(files, .data$type %in% atype)
  if (nrow(files) < 1) stop(sprintf("no tiles at 'type = %s'", atype))

  if (is.null(zoom)) {
    zoom <- min(files$zoom)
    message(sprintf("no zoom selected, choosing 'zoom =  %i'", zoom))
  }

  azoom <- zoom

 files <- dplyr::filter(files, .data$zoom %in% azoom)
  if (nrow(files) < 1) stop(sprintf("no tiles at 'zoom = %i'", azoom))
  #browser()

  add_extent(files )
}

tile_source <- function(x) {
  basename(dirname(dirname(dirname(dirname(dirname(x))))))

}
tile_version <- function(x) {
  basename(dirname(dirname(dirname(dirname(x)))))
}
tile_type <- function(x) {
  basename(dirname(dirname(dirname(x))))
}


#' Ceramic file cache
#'
#' File system location where ceramic stores its cache.
#'
#' If allowed, the cache will be created at \code{file.path(rappdirs::user_cache_dir(), ".ceramic")},
#' which corresponds to '~/.cache/.ceramic' for a given user.
#'
#' If the file cache location does not exist, the user will be asked in interactive mode
#' for permission. For non-interactive mode use the `force` argument.
#'
#' It is not currently possible to customize the cache location. To clear the cache (completely)
#' see `clear_ceramic_cache()`.
#'
#' @param force set to `TRUE` to create the location without asking the user
#' @return A character vector, the file path location of the cache.
#' @export
#' @importFrom utils askYesNo
#' @examples
#' if (interactive()) {
#'  ceramic_cache()
#' }
ceramic_cache <- function(force = FALSE) {
  ## normalize else gdal creates ./~/<cache>
  cache <- file.path( normalizePath(rappdirs::user_cache_dir()), ".ceramic")
  if (!fs::dir_exists(cache)) {
    if (!force) {
      val <- TRUE
      if (interactive()) val <- utils::askYesNo(sprintf("Create file cache for storing tiles in%s? ", cache))
      if (is.na(val) || !val) stop("No cache available, set up cache by running 'ceramic_cache()'")
    }
    fs::dir_create(cache)
  }
  gdalwmspath <- file.path(cache, "ceramic.gdalwmscache")
  curr <- vapour::vapour_get_config("GDAL_DEFAULT_WMS_CACHE_PATH")
  if (!nzchar(curr)) {
    fs::dir_create(gdalwmspath)
    vapour::vapour_set_config("GDAL_DEFAULT_WMS_CACHE_PATH", gdalwmspath)
  }
  cache
}


url_to_cache <- function(x) {
  base_filepath <- file.path(ceramic_cache(), gsub("^//", "", gsub("^https\\:", "", gsub("^https\\:", "", x))))
  ## chuck off any ? junk
  out <- unlist(lapply(strsplit(base_filepath, "\\?"), "[", 1L))
  ## also append the default image format if it's not present
  ## .jpg90 is ok but 9293893 is not
  ## why is this needed???
  #bad <- grepl("/[0-9]", out) & !grepl("jpg", out)
  #out[bad] <- sprintf("%s.jpg", out[bad])
  out
}
