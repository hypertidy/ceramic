context("test-locations")

test_that("built in locations works", {
  skip(message = "no test of location")
  skip_on_cran()
  expect_output(lc <- cc_location(cbind(147, -42), buffer = 555, debug = TRUE))
  expect_s4_class(lc, "RasterBrick")
  expect_that(dim(lc), equals(c(930L, 930L, 3L)))

  expect_s4_class(mac <- cc_macquarie(), "RasterBrick")

  dav <- cc_davis()
  maw <- cc_mawson()
  cas <- cc_casey()
  hrd <- cc_heard()
  ele <- cc_elevation(cbind(147, -42))
  expect_equal(dim(mac)[3L], 3L)
  expect_equal(dim(maw)[3L], 3L)
  expect_equal(dim(cas)[3L], 3L)
  expect_equal(dim(hrd)[3L], 3L)
  expect_equal(dim(ele)[3L], 1L)

})


test_that("max_tiles and zoom work", {
  skip_on_cran()


  expect_error(cc_location(cbind(0, 0), max_tiles = 24, zoom = 5), "'zoom' and 'max_tiles' cannot be both set, one must be NULL")
  im <- expect_silent(cc_location(cbind(0, 53), max_tiles = 16, verbose = FALSE))
  expect_that(dim(im), equals(c(524, 524, 3)))
  im <- expect_output(cc_location(cbind(0, 53), zoom = 13), "Preparing")
  expect_that(dim(im), equals(c(524, 524, 3)))

  expect_error(cc_elevation(cbind(0, 53), max_tiles = 24, zoom = 5), "'zoom' and 'max_tiles' cannot be both set, one must be NULL")
  im <- expect_silent(cc_elevation(cbind(0, 53), max_tiles = 16, verbose = FALSE))
  expect_that(dim(im), equals(c(1048, 1048, 1)))
  im <- expect_silent(cc_elevation(cbind(0, 53), zoom = 13, verbose = FALSE))
  expect_that(dim(im), equals(c(1048, 1048, 1)))


  #expect_output(cc_location(cbind(0, 0), zoom = 13, debug = TRUE), "Preparing")
})
