
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ceramic

The goal of ceramic is to obtain web map tiles for later re-use. Many
tools for imagery services treat the imagery as transient, but here we
take control over the raw data itself.

# Goals

Very much WIP.

  - control download of raw tiles (we have this\!)
  - generalize across providers
  - allow lazy read access to tile caches
  - provide interactive means to build access to imagery

## Installation

You can install the dev version of ceramic from Github.

``` r
devtools::install_github("hypertidy/ceramic")
```

## Example

This complete example gets tiled imagery that we can use as real data.

The code here

  - generates a bounding box in longitud-latitude
  - uses [slippymath](https://github.com/MilesMcBain/slippymath/) to
    find sensible tiles for the region
  - downloads them to a local cache
  - georeferences them and merges the tiles into a sensible raster
    object

<!-- end list -->

``` r
library(sf)     ## st_bbox, st_crs
#> Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3
#> Linking to GEOS 3.6.1, GDAL 2.2.3, PROJ 4.9.3
library(slippymath)
my_bbox <-
  st_bbox(c(xmin = 130,
            xmax = 146,
            ymin = -36,
            ymax = -28),
          crs = st_crs("+proj=longlat +ellps=WGS84"))

tile_grid <- bb_to_tg(my_bbox, max_tiles = 36)
zoom <- tile_grid$zoom

mapbox_query_string <-
  paste0("https://api.mapbox.com/v4/mapbox.satellite/{zoom}/{x}/{y}.jpg90",
         "?access_token=",
         Sys.getenv("MAPBOX_API_KEY"))

library(ceramic)
files <- unlist(down_loader(tile_grid, mapbox_query_string))
tibble::tibble(filename = gsub(normalizePath(rappdirs::user_cache_dir(), winslash = "/"), 
                               "", 
                               normalizePath(files, winslash = "/")))
#> # A tibble: 24 x 1
#>    filename                                                       
#>    <chr>                                                          
#>  1 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/110/74.jpg90
#>  2 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/111/74.jpg90
#>  3 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/112/74.jpg90
#>  4 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/113/74.jpg90
#>  5 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/114/74.jpg90
#>  6 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/115/74.jpg90
#>  7 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/110/75.jpg90
#>  8 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/111/75.jpg90
#>  9 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/112/75.jpg90
#> 10 /.slippymath1/api.mapbox.com/v4/mapbox.satellite/7/113/75.jpg90
#> # ... with 14 more rows

library(raster)
#> Loading required package: sp
br <- lapply(files, raster::brick)

for (i in seq_along(br)) {
  br[[i]] <- setExtent(br[[i]],  
                       mercator_tile_extent(tile_grid$tiles$x[i], tile_grid$tiles$y[i], zoom = zoom))
}

im <- purrr::reduce(br, raster::merge)
plotRGB(im)
# devtools::install_github("mdsumner/ozmaps")
dat <- sf::st_transform(ozmaps::ozmap_states, "+proj=merc +a=6378137 +b=6378137")
plot(dat$geometry, add = TRUE, lwd = 5, border = "dodgerblue")
```

<img src="man/figures/README-example-1.png" width="100%" />

Please note that the ‘ceramic’ project is released with a [Contributor
Code of Conduct](CODE_OF_CONDUCT.md). By contributing to this project,
you agree to abide by its terms.
