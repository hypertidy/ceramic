library(testthat)
library(ceramic)

test <- get_api_key()

if (is.null(test) || !nzchar(test)) {
  .use_public_key()
}

test_check("ceramic")

## ceramic::clear_ceramic_cache(clobber = TRUE)
