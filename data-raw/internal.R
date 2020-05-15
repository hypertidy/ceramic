m <- rworldmap::countriesLow
library(spbabel)
sptable(m) <- sptable(m) %>% dplyr::filter(y_ > -88)

merc_world <-  sp::spTransform(m, "+proj=merc +lon_0=0 +k=1 +x_0=0 +y_0=0 +R=6378137 +units=m +no_defs")


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




usethis::use_data(merc_world, ozdata, internal = TRUE, overwrite = T)

