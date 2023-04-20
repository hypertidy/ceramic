
# ceramic 0.7.0

* Functions `cc_location()` and friends now return terra SpatRaster. 

* Removed raster handling support. 

* Removed virtual tiles (see hypertidy/grout). 

* Begin move to use GDAL for the read, separate tile downloading from raster input. 

* Fixed `cc_kingston` location. 

* Removed all references to non-supported mapbox styles, we now have 'mapbox.satellite' and and 'mapbox.terrain-rgb'. Others can be used with a custom styles URL from your own mapbox account. 

* Removed unused LazyData in DESCRIPTION. 

* Removed dependency rgdal. 

* Standardized use of longlat and spherical mercator spec. 

* Tweaked behaviour of `debug` argument, thanks to prompt by Grant Williamson. 

* Fix bug in cc_elevation that prevent use of Amazon tiles. 

* Workaround for apparent loss of setMethod("couldBeLonLat", signature(x = "Extent")) in later raster versions. 

# ceramic 0.6.0

* Removed unused data set. 

* Added Value elements for several documentation pages. 

# ceramic 0.5.0

## Breaking changes

* Function `down_loader()` is no longer exported. 

* Function `slippy_cache()` is now deprecated, please use `ceramic_cache()`. 


## New features

* New focus on tile-downloading versus tile-loading (as a raster object). The function 
 `get_tiles()` does nothing but download the tiles. The functions `cc_location()` and
 `cc_elevation()` trigger `get_tiles()` to download if needed, and then merge tiles into the 
 appropriate raster object. 

* New function `ceramic_cache()` to replace deprecated older function. 

* Function `get_api_key()` is now exported. 

* In `debug` mode the files are only printed, not downloaded. In this case the tile object is returned invisibly. 

* `down_loader()` and higher level functions that use it will report on the download task about to occur. 

* Function `get_tiles()` will happily download tiles for any source at any zoom for the entire world. 

* Renamed internal `get_loc()` function to `get_tiles()`. 

* Imagery getter functions now accept `type = "elevation-tiles-prod"` for AWS terrain tiles. 

* Function `cc_location`, `cc_elevation` and friends now allow `loc` input to be sf, raster, sp types in any projection. 

* Function `cc_location` and `cc_elevation` and friends now allow input of either `max_tiles` or `zoom`. 

# ceramic 0.1.0

* Now aligned to `slippymath` 0.3.0. 

* Added function `cc_elevation`. 

* Early dev, with Miles McBain at FOSS4G Oceania 2018!  
