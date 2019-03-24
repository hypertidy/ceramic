context("test-cache")

test_that("caching is sensible", {
  x <- cc_location(cbind(0, 0), debug = TRUE)

  expect_s3_class(f <- ceramic_tiles(zoom = 13), "tbl_df")
  expect_true(nrow(f) > 40)

  ## clobber the cache
  if (identical(Sys.getenv("TRAVIS"), "true")) {
    clear_ceramic_cache(clobber = TRUE)
    f2 <- fs::dir_ls(slippy_cache(), recursive = TRUE)
    expect_length(f2, 0L)
  }
})
