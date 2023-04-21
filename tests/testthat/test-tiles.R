
test_that("tiles works", {
  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
  expect_message(rgb <- read_tiles(cbind(147, -42), buffer = 5000, max_tiles = 1, type = "mapbox.terrain-rgb"))
  expect_silent(rng <- range(values(unpack_rgb(rgb))))
  expect_true(rng[1] < 0)
  expect_true(rng[2] > 1000)
  
  
  expect_message(get_tiles_zoom(zoom = 1))
  
  expect_message(get_tiles_dim(dim = c(256, 256)))
  expect_message(get_tiles_buffer(cbind(147, -42), 2000))
  
    expect_s3_class(tiles <- ceramic_tiles(zoom = 1), "tbl_df")
  	
  expect_silent(plot_tiles(tiles, add_coast = F))
})
