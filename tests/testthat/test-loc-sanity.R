context("test-loc-sanity")

rpt <- cbind(147, -42)
ex <- raster::extent(rep(rpt, each = 2L) + c(-2, 2, -3, 3))

test_that("raw loc works", {
  skip_on_cran()


  cc_location(rpt, verbose = FALSE)
  cc_location(rpt, buffer = 1e5, verbose = FALSE)
  expect_output(cc_location(rpt, buffer = c(10, 0), verbose = TRUE))

  ## too many values, assumes first 2
  expect_warning(cc_location(c(rpt, 10), verbose = FALSE))
  ## flat vector ok
  expect_silent(cc_location(c(rpt), verbose = FALSE))
  expect_warning(expect_error(cc_location(raster::extent(-1e6, 1000, 0, 300000), verbose = FALSE)))

  expect_warning(cc_location(cbind(0, 0), buffer = 1e8, verbose = FALSE),
                 "The combination of buffer and location extends beyond the tile grid extent. The buffer will be truncated.")
  ## TODO out of range lonlat
})

test_that("Spatial loc works", {
  skip_on_cran()


  ## projected spdf, lines, points, mpoints
  expect_silent(cc_location(ozdata$ll$sp, verbose = FALSE))
  expect_output(cc_location(ozdata$proj$sp))

  ## degeneracy
  ## single point, no-width polygon, vert/horizontal line
  cc_location(sp::SpatialPoints(rpt, proj4string = sp::CRS("+proj=longlat +datum=WGS84")), verbose = FALSE)
  ## no CRS
  sp <- ozdata$ll$sp
  sp@proj4string <- sp::CRS(NA_character_)
  cc_location(sp, verbose = FALSE)
})



test_that("Raster loc works", {
  skip_on_cran()


  ## projected raster, longlat raster
  cc_location(ozdata$ll$raster, verbose = FALSE)
  cc_location(ozdata$proj$raster, verbose = FALSE)

  ## degeneracy
  ## ??

  ## extent, no CRS
  cc_location(extent(147, 150, -50, -30), verbose = FALSE)
  expect_error(cc_location(extent(-1e6, 1e6, 0, 2000), verbose = FALSE))
})
