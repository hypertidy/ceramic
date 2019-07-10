context("test-cache")



test_that("caching is sensible", {
  skip_on_cran()
  ## this hits zoom 13 and should give 16 tiles
  x <- cc_location(cbind(0, 0))
  expect_s3_class(f <- ceramic_tiles(zoom = 13), "tbl_df")
  expect_true(nrow(f) > 15)

  ## turn off temporarily
  # ## clobber the cache
  # if (identical(Sys.getenv("TRAVIS"), "true") || identical(Sys.getenv("APPVEYOR"), "True")) {
  #    clear_ceramic_cache(clobber = TRUE)
  #    f2 <- fs::dir_ls(ceramic_cache(), recurse = TRUE)
  #    expect_length(f2, 0L)
  # }
})
