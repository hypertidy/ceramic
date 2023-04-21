
context("test-loc-sanity")

rpt <- cbind(147, -42)
ex <- ext(rep(rpt, each = 2L) + c(-2, 2, -3, 3))
dm <- function() sample(3:10, 2L)
test_that("raw loc works", {
  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
  expect_silent(cc_location(rpt, buffer = c(10, 0), dimension = dm(), verbose = TRUE))

  ## too many values, assumes first 2
  expect_warning(cc_location(c(rpt, 10), dimension = dm(),verbose = FALSE))
  ## flat vector ok
  expect_s4_class(cc_location(c(rpt), dimension = dm(),verbose = FALSE), "SpatRaster")
  expect_error(cc_location(ext(-1e6, 1000, 0, 300000), dimension = dm(),verbose = FALSE))

  expect_warning(cc_location(cbind(0, 0), buffer = 1e8,dimension = dm(), verbose = FALSE),
                 "The combination of buffer and location extends beyond the tile grid extent. The buffer will be truncated.")
  ## TODO out of range lonlat
})

test_that("Spatial loc works", {

  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
  ## projected spdf, lines, points, mpoints
  expect_s4_class(cc_location(ozdata$ll$sp, verbose = FALSE, dimension = dm(),), "SpatRaster")
  expect_silent(cc_location(ozdata$proj$sp, dimension = dm(),))

  ## no CRS
  sp <- ozdata$ll$sp
  sp@proj4string <- sp::CRS(NA_character_, doCheckCRSArgs = FALSE)
  ## warnings from spex
  expect_error(cc_location(sp, verbose = FALSE, dimension = dm()))
})



test_that("Raster loc works", {

  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
  ## projected raster, longlat raster
  cc_location(ozdata$ll$raster, verbose = FALSE, dimension = dm())
  cc_location(ozdata$proj$raster, verbose = FALSE, dimension = dm())

  ## degeneracy
  ## ??

  ## extent, no CRS
  cc_location(ext(147, 150, -50, -30), verbose = FALSE, dimension = dm())
  expect_error(cc_location(ext(-1e6, 1e6, 0, 2000), verbose = FALSE, dimension = dm()))
})
