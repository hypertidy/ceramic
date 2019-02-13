#' Downloader for tiles
#'
#' Tiles are cached with the native name of the source.
#'
#' `query_string` takes the form of a templae, see examples
#' @param x tiles object
#' @param query_string an api query template (see Details)
#' @param clobber if `TRUE` re download any existing tiles
#' @param ... ignored
#' @param debug simple debugging info printed if `TRUE`
#' @return WIP
#' @export
#'
#' @examples
#' mapbox_query_string <- paste0("https://api.mapbox.com/v4/mapbox.satellite/{zoom}/{x}/{y}.jpg90",
#' "?access_token=",
#' Sys.getenv("MAPBOX_API_KEY"))
#' @importFrom curl curl_download
#' @importFrom fs dir_exists dir_create
#' @importFrom glue glue
#' @importFrom rappdirs user_cache_dir
#' @importFrom purrr pmap
down_loader <- function(x, query_string, clobber = FALSE, ..., debug = FALSE) {
  purrr::pmap(x$tiles,
              function(x, y, zoom){
                api_query <- glue::glue(query_string)
                outfile <- url_to_cache(api_query)
                if (debug) {
                  print(outfile)
                }

                if (!file.exists(outfile) || clobber) {
                  cachedir <- fs::path_dir(outfile)

                  if (!fs::dir_exists(cachedir)) fs::dir_create(cachedir, recursive = TRUE)
                ## FIXME: need to error on no API_KEY present
                  curl::curl_download(url = api_query,
                                      destfile = outfile)
                }
                outfile
              },
              zoom = x$zoom)
}

#' Tile files
#'
#' Find existing files in the cache. Various options can be controlled, this is WIP
#' and due to change pending generalization across providers.
#'
#' @param zoom zoom level
#'
#' @param type imagery type
#' @param source imagery source
#' @param glob see `fs::dir_ls`
#' @param regexp see `fs::dir_ls`
#'
#' @export
#' @importFrom rlang .data
ceramic_tiles <- function(zoom = NULL, type = "mapbox.satellite",
                          source = "api.mapbox.com", glob = "*.jpg*", regexp = NULL) {

  ## FIXME: assert that zoom, type, source, all are length 1
  bfiles <-
    fs::dir_ls(slippy_cache(), recursive = TRUE, type = "file",
               glob = glob, regexp = regexp)
  strex <- function(x, y) regmatches(x, regexec(y, x))
  toks <- do.call(rbind, strex(bfiles, "([[:digit:]]+)/([[:digit:]]+)/([[:digit:]]+)\\.[^\\.]+$"))
  #print(dim(toks))
  files <- tibble::tibble(tile_x = as.integer(toks[,3]), tile_y = as.integer(toks[,4]),
                          zoom = as.integer(toks[, 2]),
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

  if (!is.null(zoom)) files <- dplyr::filter(files, .data$zoom %in% azoom)
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

tile_x <- function(x) {
  as.integer(basename(dirname(x)))
}
tile_y <- function(x) {
  #xbase <- basename(x)
  stop("not implemented")
}
tile_zoom <- function(x) {
  as.integer(basename(dirname(dirname(x))))
}

slippy_cache <- function() {
  cache <- file.path(rappdirs::user_cache_dir(), ".ceramic")
  if (!fs::dir_exists(cache)) fs::dir_create(cache)
  cache
}

url_to_cache <- function(x) {
  base_filepath <- file.path(slippy_cache(), gsub("^//", "", gsub("^https\\:", "", gsub("^https\\:", "", x))))
  ## chuck off any ? junk
  unlist(lapply(strsplit(base_filepath, "\\?"), "[", 1L))
}
