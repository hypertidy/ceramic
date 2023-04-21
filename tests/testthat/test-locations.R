
context("test-locations")

dm <- function() sample(3:10, 2L)

test_that("built in locations works", {
  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
  expect_silent(lc <- cc_location(cbind(147, -42), buffer = 555, dimension = dm0 <- dm(), debug = TRUE))
  expect_s4_class(lc, "SpatRaster")
  ## we now use a colour table in terra, not 3 layers
  expect_that(dim(lc), equals(c(rev(dm0), 1L)))

  expect_s4_class(mac <- cc_macquarie(dimension = dm1 <- dm()), "SpatRaster")

  hrd <- cc_heard(dimension = dm1)
  ele <- cc_elevation(cbind(147, -42), dimension = dm1)
  expect_equal(dim(mac)[3L], 1L)
  expect_equal(dim(hrd)[3L], 1L)
  expect_equal(dim(ele)[3L], 1L)

  expect_error(cc_mawson())
  expect_error(cc_davis())
  expect_error(cc_casey())
  
  expect_s4_class(cc_location(terra::rast(terra::ext(100, 120, -30, -20)), dimension = dm()), "SpatRaster")
  expect_s4_class(cc_heard(terra::rast(terra::ext(100, 120, -30, -20), nrows = 5, ncols = 6), dimension = dm()), "SpatRaster")
  expect_s4_class(cc_kingston(terra::rast(terra::ext(100, 120, -30, -20), nrows = 5, ncols = 6), dimension = dm()), "SpatRaster")
  
})


test_that("max_tiles and zoom work", {
  
  skip_on_cran()
  skip_if(is.null(get_api_key()))
  

  expect_message(cc_location(cbind(0, 0), max_tiles = 24, zoom = 5, dimension = dm()), "'zoom' and 'max_tiles' are ignored")

  ## we get something for nothing
  expect_s4_class(cc_location(dimension = c(4, 3)), "SpatRaster")
  
  ## this is the slowest one
  
  expect_s4_class(cc_elevation(cbind(147, -42), buffer = 500, dimension = c(4, 3), type = "aws"), "SpatRaster")
  
  
  im <- expect_s4_class(cc_location(cbind(0, 53), dimension = c(4, 6), verbose = FALSE), "SpatRaster")
  expect_that(dim(im), equals(c(6,  4, 1L)))


  im <- expect_s4_class(cc_elevation(cbind(0, 53), dimension = c(3, 2), verbose = FALSE),
                        "SpatRaster")
  expect_that(dim(im), equals(c(2, 3, 1)))

})
