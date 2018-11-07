#' Downloader for tiles
#'
#' Tiles are cached with the native name of the source.
#'
#' `query_string` takes the form of a templae, see examples
#' @param x tiles object
#' @param query_string an api query template (see Details)
#' @param clobber if `TRUE` re download any existing tiles
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
down_loader <- function(x, query_string, clobber = FALSE) {
    purrr::pmap(x$tiles,
         function(x, y, zoom){
           api_query <- glue::glue(query_string)
           outfile <- url_to_cache(api_query)
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

slippy_cache <- function() {
  cache <- file.path(rappdirs::user_cache_dir(), ".slippymath1")
  if (!fs::dir_exists(cache)) fs::dir_create(cache)
  cache
}

url_to_cache <- function(x) {
  base_filepath <- file.path(slippy_cache(), gsub("^//", "", gsub("^https\\:", "", gsub("^https\\:", "", x))))
  ## chuck off any ? junk
  unlist(lapply(strsplit(base_filepath, "\\?"), "[", 1L))
}
