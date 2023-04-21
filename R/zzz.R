.onLoad <- function(libname, pkgname) {
  cache <- ceramic_cache()
  keytest <- get_api_key(silent = TRUE)
  if (is.null(keytest) || !nzchar(keytest)) {
    noise <- .use_public_key()
  }
  invisible(NULL)
}
