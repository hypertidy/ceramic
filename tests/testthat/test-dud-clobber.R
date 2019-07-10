context("test-dud-clobber")



test_that("dud file gets clobbered", {
  skip_on_cran()



  dudfile <- file.path(ceramic_cache(),
                       "api.mapbox.com/v4/mapbox.satellite/13/7440/5149.jpg")
  if (fs::file_exists(dudfile)) fs::file_delete(dudfile)
  ## the first 11 bytes of this message is
  ## rawToChar(as.raw(c(0x7b, 0x22, 0x6d, 0x65, 0x73,
  ##             0x73, 0x61, 0x67, 0x65, 0x22, 0x3a)))

  cachedir <- fs::path_dir(dudfile)
  if (!fs::dir_exists(cachedir)) fs::dir_create(cachedir, recurse = TRUE)

  writeLines("{\"message\":\"Tile does not exist\"}",
             dudfile)
  sz <- fs::file_info(dudfile)$size

  expect_true(sz < 100)
  ## that bad file should be replaced
  im <-   cc_location(cbind(147, -42), debug = FALSE)

  expect_true(fs::file_info(dudfile)$size > 101)
})



