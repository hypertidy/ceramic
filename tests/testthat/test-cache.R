
context("test-cache")
skip_if_offline()

test_that("caching is sensible", {
  
  ## this hits zoom 13 and should give 16 tiles
  x <- get_tiles(cbind(0, 0), buffer = 5000, dimension = c(15, 16))
  suppressWarnings(f <- ceramic_tiles(zoom = 13))
  expect_s3_class(f, "tbl_df")
  expect_true(nrow(f) > 15)


})
