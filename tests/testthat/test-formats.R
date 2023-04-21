

exll <- c(0, 10, 20, 30)
expr <- c(0, 100000, 20, 300000)

wkbll <- wk::as_wkb(wk::rct(exll[1], exll[3], exll[2], exll[4], crs = "OGC:CRS84"))
wkbpr <- wk::as_wkb(wk::rct(expr[1], expr[3], expr[2], expr[4], crs = "+proj=laea"))

grdll <- wk::grd_rct(matrix(1, 3, 4), wk::rct(exll[1], exll[3], exll[2], exll[4], crs = "OGC:CRS84"))
grdpr <- wk::grd_rct(matrix(1, 3, 4), wk::rct(expr[1], expr[3], expr[2], expr[4], crs = "+proj=laea"))


## we're avoid sp, sf, and raster because we can get their information without loading them
## with geos we get its info via wk
#.spatial_classes()


tre <- function() {
  terra::ext(exll)
}
tr <- function() {
  terra::rast(tre(), nrows = 4, ncols = 6, crs = "OGC:CRS84")
}
tv <- function() {
  terra::vect(matrix(exll, ncol = 2), crs = "OGC:CRS84")
}

classes <- list(tre(), tr(), tv(), wkbll, wkbpr, grdll, grdpr)
##for (i in seq_along(classes)) cc_location(classes[[i]])
test_that("formats work", {
  skip_on_cran()
  skip_if(is.null(get_api_key()))
  
  for (i in seq_along(classes)) {
  expect_s4_class(cc_location(classes[[i]], dimension = c(4, 4)), "SpatRaster")
  }
  
  
})

