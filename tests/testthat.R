library(testthat)
library(ceramic)
## default public key  https://account.mapbox.com/access-tokens/
if (identical(Sys.getenv("APPVEYOR"), "True")) {
  Sys.setenv(MAPBOX_API_KEY="pk.eyJ1IjoibWRzdW1uZXIiLCJhIjoiY2lleHM3dDk5MDBzbHM4bTM1bjkyY2kwayJ9.IrUihishnOa8w0JFXhXqZA")
}
  test_check("ceramic")

# if (identical(Sys.getenv("TRAVIS"), "true")) {
#   clear_ceramic_cache(clobber = TRUE)
# }
