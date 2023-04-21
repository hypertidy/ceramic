context("test-get")

test_that("getting tiles works", {

  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
 expect_silent(ceramic_cache())

})
