m <- rworldmap::countriesLow
#library(spbabel)
#sptable(m) <- sptable(m) %>% dplyr::filter(y_ > -88)
sf::sf_use_s2(FALSE)
merc_world <- sf::as_Spatial(sf::st_transform(
  sf::st_crop(sf::st_set_crs(sf::st_as_sf(m), "OGC:CRS84"), sf::st_bbox(c(xmin = -180,  ymin = -88, xmax = 180, ymax = 90), crs = sf::st_crs("OGC:CRS84")))
  
  , .merc()))



oz <- oz::ozRegion()
d <- purrr::map(oz["lines"],
                ~purrr::map_df(.x, tibble::as_tibble, .id = "branch_"))[[1L]]
library(dplyr)
library(raster)
sp <- d %>% dplyr::transmute(x_ = x, y_ = y, branch_, object_ = 1, order_ = row_number()) %>%  spbabel::sp(crs = "+proj=longlat +datum=WGS84")
ozdata <- list(ll = list(
  sp = sp,
  sf = sf::st_as_sf(sp),
  raster = setValues(raster::raster(sp), 1)))

prj <- "+proj=laea +lon_0=130 +lat_0=-30 +datum=WGS84"
ozdata$proj <- list(sp = sp::spTransform(ozdata$ll$sp, prj),
                    sf = sf::st_transform(ozdata$ll$sf, prj),
                    raster = raster::projectExtent(ozdata$ll$raster, prj))




usethis::use_data(merc_world, ozdata, internal = TRUE, overwrite = T, compress = "xz")

