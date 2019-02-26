context("test-get")

test_that("getting tiles works", {
 skip_on_cran()

 expect_silent(dir <- slippy_cache())
 fs <- list.files(dir, recursive = TRUE, full.names = TRUE)
#print(fs)
 im <- cc_location(cbind(0, 0))
 fs <- list.files(dir, recursive = TRUE, full.names = TRUE)
 #expect_true(all(file.remove(fs)))

})
