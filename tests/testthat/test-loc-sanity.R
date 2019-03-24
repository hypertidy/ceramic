context("test-loc-sanity")

rpt <- cbind(147, -42)
ex <- raster::extent(rep(rpt, each = 2L) + c(-2, 2, -3, 3))

test_that("raw loc works", {
  cc_location(rpt)
  cc_location(rpt, buffer = 1e5)
  cc_location(rpt, buffer = c(10, 0))

  ## too many values, assumes first 2
  expect_warning(cc_location(c(rpt, 10)))
  ## flat vector ok
  expect_silent(cc_location(c(rpt)))
  expect_error(cc_location(raster::extent(-1e6, 1000, 0, 300000)))

  expect_warning(cc_location(cbind(0, 0), buffer = 1e8),
                 "The combination of buffer and location extends beyond the tile grid extent. The buffer will be truncated.")
  ## TODO out of range lonlat
})

test_that("Spatial loc works", {
  ## projected spdf, lines, points, mpoints
  cc_location(ozdata$ll$sp)
  cc_location(ozdata$proj$sp)

  ## degeneracy
  ## single point, no-width polygon, vert/horizontal line
  cc_location(sp::SpatialPoints(rpt, proj4string = sp::CRS("+proj=longlat +datum=WGS84")))
  ## no CRS
  sp <- ozdata$ll$sp
  sp@proj4string <- sp::CRS(NA_character_)
  cc_location(sp)
})

test_that("sf loc works", {
  ## projected sf, sfc, POINT, MULTIPOINT

  ## degeneracy
  ## single point, no-width polygon, vert/horizontal line

  ## no CRS

})

test_that("Raster loc works", {
  ## projected raster, longlat raster
  cc_location(ozdata$ll$raster)
  cc_location(ozdata$proj$raster)

  ## degeneracy
  ## ??

  ## extent, no CRS
  cc_location(extent(147, 150, -50, -30))
  expect_error(cc_location(extent(-1e6, 1e6, 0, 2000)))
})
