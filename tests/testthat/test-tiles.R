context("test-tiles")

test_that("creating virtual tiles works", {

  skip_on_cran()

  z0 <- virtual_tiles() %>% expect_s3_class("tile_grid")
  expect_true(nrow(z0$tiles) == 1L)
  z5 <- virtual_tiles(zoom = 5) %>% expect_s3_class("tile_grid")
  expect_true(nrow(z5$tiles) == 1024L)

  ze <- virtual_tiles(zoom = 5, extent = raster::extent(-1e5, 1e4, -1, 1e6)) %>% expect_s3_class("tile_grid")
  expect_true(nrow(ze$tiles) == 416L)
})


# test_that("creating vector tiles works", {
#   #cc_location(cbind(0, 0), buffer = 1e6)
#  #ct <- ceramic_tiles(zoom = 6)
# })
