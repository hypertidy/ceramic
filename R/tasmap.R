tasmap_layers <- tibble::tribble(
  ~Name, ~ServiceUrl,
  "TTSA", "https://services.thelist.tas.gov.au/arcgis/services/Raster/TTSA/MapServer/WMSServer?",
  "ESgisMapBookPUBLIC", "https://services.thelist.tas.gov.au/arcgis/services/Basemaps/ESgisMapBookPUBLIC/MapServer/WMSServer",
  "HillshadeGrey", "https://services.thelist.tas.gov.au/arcgis/services/Basemaps/HillshadeGrey/MapServer/WMSServer?",
  "Tasmap250K", "https://services.thelist.tas.gov.au/arcgis/services/Basemaps/Tasmap250K/MapServer/WMSServer?",
  "Topographic","https://services.thelist.tas.gov.au/arcgis/services/Basemaps/Topographic/MapServer/WMSServer?"
)


tasmap_ortho <- "WMS:https://services.thelist.tas.gov.au/arcgis/services/Basemaps/Orthophoto/MapServer/WmsServer?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&LAYERS=Data%20Boundaries&SRS=EPSG:4326&BBOX=111.848916,-54.849439,159.145536,-7.800454"
