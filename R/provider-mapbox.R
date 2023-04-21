
token_url <- function(api = "mapbox") {
  switch(api, mapbox = "https://account.mapbox.com/access-tokens/", stop("api not known"))
}
instruct_on_key_creation <- function(api = "mapbox") {
  if (api == "mapbox") {
    out <- paste(sprintf("To set your Mapbox API key obtain a key from %s\n", token_url()),
    sprintf("1) Run this to set for the session 'Sys.setenv(MAPBOX_API_KEY=<yourkey>)'\n\nOR,\n\n2) To set permanently store 'MAPBOX_API_KEY=<yourkey>' in ~/.Renviron\n\nSee 'help(ceramic::get_api_key)'"), sep = "\n")
  } else {
    message(sprintf("don't know if key is needed for %s", api))
  }
  out
}

#' Get API key for Mapbox service
#'
#' Mapbox tile providers require an API key. Other providers may not need a key and so this is ignored.
#'
#' The \href{https://CRAN.r-project.org/package=mapdeck/}{mapdeck package} has a more comprehensive tool for
#' setting the Mapbox API key, if this is in use ceramic will find it first and use it.
#'
#' To set your Mapbox API key obtain a key from \url{https://account.mapbox.com/access-tokens/}
#' \preformatted{
#' 1) Run this to set for the session 'Sys.setenv(MAPBOX_API_KEY=<yourkey>)'
#'
#' OR,
#'
#' 2) To set permanently store 'MAPBOX_API_KEY=<yourkey>' in '~/.Renviron'.
#' }
#'
#' There is a fairly liberal allowance for the actual name of the environment variable, any of
#' 'MAPBOX_API_KEY', 'MAPBOX_API_TOKEN', 'MAPBOX_KEY', 'MAPBOX_TOKEN', or 'MAPBOX' will work (and they are
#' sought in that order).
#'
#' If no key is available, `NULL` is returned, with a warning.
#'
#' @param api character string denoting which service ("mapbox" only)
#' @param silent run in completely silent mode, default is to provide a warning
#' @param ... currently ignored
#'
#' @return The stored API key value, see Details.
#' @export
#' @examples
#' get_api_key()
get_api_key <- function(api = "mapbox", ..., silent = FALSE) {
  key <- NULL
  if (api == "mapbox") {
    ## Try mapdeck first (why not)
    key <- getOption("mapdeck")[['mapdeck']][[api]]
    key_candidates <- c("MAPBOX_API_KEY", "MAPBOX_API_TOKEN", "MAPBOX_KEY", "MAPBOX_TOKEN", "MAPBOX")
    if(is.na(key) || is.null(key) || nchar(key) < 1) {
       key <- unlist(lapply(key_candidates, function(label) Sys.getenv(label)))[1L]
    }
    if (is.na(key) || is.null(key) || nchar(key) < 1) {
      mess <- instruct_on_key_creation()
      if (!silent) {
        warning(sprintf("no mapbox key found\n\n%s", mess))
      }
      key <- NULL
    }
  }
  key
}


