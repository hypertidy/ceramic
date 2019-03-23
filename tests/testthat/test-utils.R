context("test-utils")

test_that("utilities work as expected", {
   expect_true(grepl("^https", token_url()))
  expect_output(instruct_on_key_creation())

  p <- Sys.getenv("MAPBOX_API_KEY")
  Sys.setenv(MAPBOX_API_KEY = "")
  expect_error(get_api_key())
  Sys.setenv(MAPBOX_API_KEY = p)
  expect_silent(get_api_key())

  expect_true(grepl(p, mk_query_string_custom("https://abc.com")))

  expect_error(token_url("google"), "api not known")


})
