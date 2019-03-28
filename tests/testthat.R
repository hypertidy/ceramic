library(testthat)
library(ceramic)
##   https://account.mapbox.com/access-tokens/
if (identical(Sys.getenv("APPVEYOR"), "True")) {
  #Sys.setenv(MAPBOX_API_KEY="pk.eyJ1IjoibWRzdW1uZXIiLCJhIjoiY2p0bDI1aGY1MTRiNDQ0bWR2djh4dzgxOSJ9.zPM71aZwRWHc9U5kvDQDIA")
  print(ceramic:::get_api_key())
}
test_check("ceramic")

# if (identical(Sys.getenv("TRAVIS"), "true")) {
#   clear_ceramic_cache(clobber = TRUE)
# }
