# tasmap_layers <- tibble::tribble(
#   ~Name, ~ServiceUrl,
#   "TTSA", "https://services.thelist.tas.gov.au/arcgis/services/Raster/TTSA/MapServer/WMSServer?",
#   "ESgisMapBookPUBLIC", "https://services.thelist.tas.gov.au/arcgis/services/Basemaps/ESgisMapBookPUBLIC/MapServer/WMSServer",
#   "HillshadeGrey", "https://services.thelist.tas.gov.au/arcgis/services/Basemaps/HillshadeGrey/MapServer/WMSServer?",
#   "Tasmap250K", "https://services.thelist.tas.gov.au/arcgis/services/Basemaps/Tasmap250K/MapServer/WMSServer?",
#   "Topographic","https://services.thelist.tas.gov.au/arcgis/services/Basemaps/Topographic/MapServer/WMSServer?"
# )
# 

## bases, gsub("/", "_", bases)
template <- "WMTS:https://services.thelist.tas.gov.au/arcgis/rest/services/%s/MapServer/WMTS/1.0.0/WMTSCapabilities.xml,layer=%s,tilematrixset=default028mm"
bases <- 
c("Basemaps/AerialPhoto2020", "Basemaps/AerialPhoto2021", "Basemaps/AerialPhoto2022", 
  "Basemaps/AerialPhoto2023", "Basemaps/ESgisMapBookPUBLIC", "Basemaps/HillshadeGrey", 
  "Basemaps/Hillshade", "Basemaps/Orthophoto", "Basemaps/SimpleBasemap", 
  "Basemaps/Tasmap100K", "Basemaps/Tasmap250K", "Basemaps/Tasmap25K", 
  "Basemaps/Tasmap500K", "Basemaps/TasmapRaster", "Basemaps/TopographicGrayScale", 
  "Basemaps/Topographic")

names <- unlist(lapply(strsplit(bases, "/"), "[", 2))

tasmap_sources <- sprintf(template, bases, gsub("/", "_", bases))
names(tasmap_sources) <- tolower(names)
## bit more work needed, there's a few more layer servers
tasmap_sources <- c(tasmap_sources, street = "https://services.thelist.tas.gov.au/arcgis/rest/services/Raster/TTSA/MapServer/WMTS/1.0.0/WMTSCapabilities.xml")
