context("test-utils")

test_that("utilities work as expected", {
  
  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
   expect_true(grepl("^https", token_url()))
  expect_silent(instruct_on_key_creation())

  p <- Sys.getenv("MAPBOX_API_KEY")
  Sys.setenv(MAPBOX_API_KEY = "")
  expect_warning(getted <- get_api_key(), "no mapbox key found")
  expect_equivalent(getted, NULL)
  Sys.setenv(MAPBOX_API_KEY = p)
  get_api_key()

  expect_true(grepl(p, mk_query_string_custom("https://abc.com")))

  expect_error(token_url("google"), "api not known")


})
