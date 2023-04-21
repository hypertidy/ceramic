context("test-locations")

test_that("built in locations works", {
  skip(message = "no test of location")
  skip_on_cran()
  expect_silent(lc <- cc_location(cbind(147, -42), buffer = 555, dimension = c(378, 378), debug = TRUE))
  expect_s4_class(lc, "SpatRaster")
  expect_that(dim(lc), equals(c(378L, 378L, 3L)))

  expect_s4_class(mac <- cc_macquarie(), "SpatRaster")

  hrd <- cc_heard()
  ele <- cc_elevation(cbind(147, -42))
  expect_equal(dim(mac)[3L], 3L)
  expect_equal(dim(hrd)[3L], 3L)
  expect_equal(dim(ele)[3L], 1L)

  expect_error(cc_mawson())
  expect_error(cc_davis())
  expect_error(cc_casey())
  
  expect_s4_class(cc_location(terra::rast(terra::ext(100, 120, -30, -20))), "SpatRaster")
})


test_that("max_tiles and zoom work", {
  skip_on_cran()


  expect_message(cc_location(cbind(0, 0), max_tiles = 24, zoom = 5), "'zoom' and 'max_tiles' are ignored")

  ## we get something for nothing
  expect_s4_class(cc_location(dimension = c(4, 3)), "SpatRaster")
  expect_s4_class(cc_elevation(dimension = c(4, 3), type = "aws"), "SpatRaster")
  
  im <- expect_s4_class(cc_location(cbind(0, 53), dimension = c(34, 26), verbose = FALSE), "SpatRaster")
  expect_that(dim(im), equals(c(26,  34, 3)))


  im <- expect_s4_class(cc_elevation(cbind(0, 53), dimension = c(128, 128), verbose = FALSE),
                        "SpatRaster")
  expect_that(dim(im), equals(c(128, 128, 1)))


  #expect_output(cc_location(cbind(0, 0), zoom = 13, debug = TRUE), "Preparing")
})
