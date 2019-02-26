library(testthat)
library(ceramic)
unlink(list.files(slippy_cache(), full.name = TRUE), recursive = TRUE)
test_check("ceramic")
