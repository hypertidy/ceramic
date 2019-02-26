context("test-get")

test_that("getting tiles works", {
 skip_on_cran()

 expect_silent(dir <- slippy_cache())


 f <- get_files(cbind(-100, 50), buffer = 5000, debug = FALSE)
 expect_true(all(file.exists(f)))

 expect_equal(dim(raster::brick(f[1])), dim(raster_brick(f[1])))
 #fs <- list.files(dir, recursive = TRUE, full.names = TRUE)
 #im <- cc_location(cbind(0, 0), debug = TRUE)
 #fs <- list.files(dir, recursive = TRUE, full.names = TRUE)
 #expect_true(all(file.remove(fs)))

})
