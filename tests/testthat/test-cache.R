context("test-cache")

##   https://account.mapbox.com/access-tokens/
if (identical(Sys.getenv("APPVEYOR"), "True")) {
  #Sys.setenv(MAPBOX_API_KEY="pk.eyJ1IjoibWRzdW1uZXIiLCJhIjoiY2p0bDI1aGY1MTRiNDQ0bWR2djh4dzgxOSJ9.zPM71aZwRWHc9U5kvDQDIA")
  #print("attempt print key on APPVEYOR")
  #print(ceramic:::get_api_key())
}
if (identical(Sys.getenv("TRAVIS"), "true")) {
  #Sys.setenv(MAPBOX_API_KEY="pk.eyJ1IjoibWRzdW1uZXIiLCJhIjoiY2p0bDI1aGY1MTRiNDQ0bWR2djh4dzgxOSJ9.zPM71aZwRWHc9U5kvDQDIA")
  print("attempt print key on TRAVIS")
  print(ceramic:::get_api_key())
}


test_that("caching is sensible", {
  ## this hits zoom 13 and should give 16 tiles
  x <- cc_location(cbind(0, 0), debug = TRUE)
  expect_s3_class(f <- ceramic_tiles(zoom = 13), "tbl_df")
  expect_true(nrow(f) > 15)

  ## turn off temporarily
  # ## clobber the cache
  if (identical(Sys.getenv("TRAVIS"), "true") || identical(Sys.getenv("APPVEYOR"), "True")) {
     clear_ceramic_cache(clobber = TRUE)
     f2 <- fs::dir_ls(slippy_cache(), recursive = TRUE)
     expect_length(f2, 0L)
  }
})
