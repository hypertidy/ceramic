
token_url <- function(api = "mapbox") {
  switch(api, mapbox = "https://account.mapbox.com/access-tokens/", stop("api not known"))
}
instruct_on_key_creation <- function(api = "mapbox") {
  if (api == "mapbox") {
    cat(sprintf("To set your Mapbox API key obtain a key from %s\n", token_url()))
    cat(sprintf("Run 'Sys.setenv(MAPBOX_API_KEY=<yourkey>)'\n"))
  } else {
    message(sprintf("don't know if key is needed for %s", api))
  }
}
get_api_key <- function(api = "mapbox", ...) {
  key <- ""
  if (api == "mapbox") {
    key <- Sys.getenv("MAPBOX_API_KEY")

    if (is.null(key) || nchar(key) < 1) {
      instruct_on_key_creation()
      stop("no mapbox key found")
    }
  }
  key
}


