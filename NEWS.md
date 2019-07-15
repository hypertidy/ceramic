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
