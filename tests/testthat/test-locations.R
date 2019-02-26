context("test-locations")
skip()
test_that("built in locations works", {
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
