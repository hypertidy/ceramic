# This file is part of the standard setup for testthat.
# It is recommended that you do not modify it.
#
# Where should you do additional test configuration?
# Learn more about the roles of various files in:
# * https://r-pkgs.org/tests.html
# * https://testthat.r-lib.org/reference/test_package.html#special-files

library(testthat)
library(ceramic)

test <- get_api_key()

if (is.null(test) || !nzchar(test)) {
  ceramic:::.use_public_key()
  get_api_key()
}


test_check("ceramic")
