library(testthat)
library(ceramic)

##   https://account.mapbox.com/access-tokens/
ceramic_key <- "pk.eyJ1IjoibWRzdW1uZXIiLCJhIjoiY2p0bDI1aGY1MTRiNDQ0bWR2djh4dzgxOSJ9.zPM71aZwRWHc9U5kvDQDIA"
if (identical(Sys.getenv("APPVEYOR"), "True")) {
  Sys.setenv(MAPBOX_API_KEY=ceramic_key)
}
if (identical(Sys.getenv("TRAVIS"), "true")) {
  Sys.setenv(MAPBOX_API_KEY=ceramic_key)
}

test_check("ceramic")

