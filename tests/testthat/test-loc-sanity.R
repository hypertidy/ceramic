context("test-loc-sanity")

rpt <- cbind(147, -42)
ex <- raster::extent(rep(rpt, each = 2L) + c(-2, 2, -3, 3))

test_that("raw loc works", {
  cc_location(rpt)
  cc_location(rpt, buffer = 1e5)

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

  ## degeneracy
  ## ??

  ## extent, no CRS

})
