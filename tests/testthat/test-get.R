context("test-get")

test_that("getting tiles works", {
 skip_on_cran()

 expect_warning(dir <- slippy_cache())
 expect_silent(ceramic_cache())

 #f <- get_files(cbind(-100, 50), buffer = 5000, debug = FALSE)$files
 #expect_true(all(file.exists(f)))

 #for (i in seq_along(f)) {
 #expect_equal(c(256L, 256L, 3L), dim(raster_brick(f[i])))
 #}
 #fs <- list.files(dir, recursive = TRUE, full.names = TRUE)
 #im <- cc_location(cbind(0, 0), debug = TRUE)
 #fs <- list.files(dir, recursive = TRUE, full.names = TRUE)
 #expect_true(all(file.remove(fs)))

})
