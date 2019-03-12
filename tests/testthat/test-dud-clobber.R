context("test-dud-clobber")

dudfile <- file.path(slippy_cache(),
 "api.mapbox.com/v4/mapbox.satellite/13/7440/5149.jpg")
unlink(dudfile)
writeLines("{\"message\":\"Tile does not exist\"}",
           dudfile)
sz <- fs::file_info(dudfile)$size
test_that("dud file gets clobbered", {
  expect_true(sz < 100)
  ## that bad file should be replaced
 im <-   cc_location(cbind(147, -42))

  expect_true(fs::file_info(dudfile)$size > 101)
})
