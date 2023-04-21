#' @importFrom grDevices dev.size
loc_extent <- function(x, buffer, dimension = NULL) {
  if (missing(x) && missing(buffer)) {
    ## get the whole world at zoom provided, as a neat default
    x <- cbind(0, 0)
    buffer <- c(20037508, 20037508)
    
  }
  bbox_pair <- spatial_bbox(x, buffer)
 
  ext <- bbox_pair$extent

  ## widest 
  dx_dy <- diff(ext)[c(1, 3)]
  if (is.null(dimension)) {
    dimension <- rep(min(dev.size("px")), 2L)
    was_one <- TRUE
  } else {
    was_one <- length(dimension) == 1
  }
 # print(dimension)
  dimension <- rep(dimension, length.out = 2L)
if (was_one)  dimension[which.min(dx_dy)] <- 0L
  c(ext, dimension)
}


format_out <- function (x) 
{
  dimension <- x$dimension
  projection <- x$projection
  x <- x$extent

  if (inherits(x, "SpatRaster")) {
    if (!requireNamespace("terra")) 
      stop("terra package required but not available, please install it")
    x <- terra_out(x)
    if (is.na(x$projection) && x$lonlat) 
      x$projection <- "OGC:CRS84"
    x$type <- "terra"
  }
  if (inherits(x, "numeric")) {
    if (is.null(projection)) 
      projection <- "OGC:CRS84"
    if (is.null(dimension)) 
      dimension <- as.integer(256 * sort(c(1, diff(x[1:2])/diff(x[3:4])), 
                                         decreasing = FALSE))
    lonlat <- grepl("lonlat", projection) || grepl("4326", 
                                                   projection) || grepl("4269", projection) || grepl("OGC:CRS84", 
                                                                                                     projection) || grepl("GEOGCS", projection)
    x <- list(extent = x, dimension = dimension, projection = projection, 
              lonlat = lonlat, type = "matrix")
  }
  x$lonlat <- vapour::vapour_crs_is_lonlat(x$projection)

  x
}

terra_out <- function (x) 
{
  if (isS4(x) && inherits(x, "SpatRaster")) {
    x <- try(list(extent = c(terra::xmin(x), terra::xmax(x), 
                             terra::ymin(x), terra::ymax(x)), dimension = dim(x)[2:1], 
                  projection = terra::crs(x), lonlat = terra::is.lonlat(x), 
                  terra = TRUE), silent = TRUE)
    if (inherits(x, "try-error")) 
      stop("cannot use terra grid")
  }
  x
}
gdal_mapbox <- function (extent = c(-180, 180, -90, 90), ..., dimension = NULL, 
          projection = "OGC:CRS84", resample = "near", source = NULL) 
{
  xraster <- extent
  x <- format_out(list(extent = extent, dimension = dimension, 
                       projection = projection))
  src1 <- "<GDAL_WMS><Service name=\"TMS\"><ServerUrl>https://api.mapbox.com/v4/mapbox.satellite/${z}/${x}/${y}.jpg?access_token=%s</ServerUrl></Service><DataWindow><UpperLeftX>-20037508.34</UpperLeftX><UpperLeftY>20037508.34</UpperLeftY><LowerRightX>20037508.34</LowerRightX><LowerRightY>-20037508.34</LowerRightY><TileLevel>22</TileLevel><TileCountX>1</TileCountX><TileCountY>1</TileCountY><YOrigin>top</YOrigin></DataWindow><Projection>EPSG:3857</Projection><BlockSizeX>256</BlockSizeX><BlockSizeY>256</BlockSizeY><BandsCount>3</BandsCount>"
  src2 <- sprintf("<UserAgent>%s</UserAgent><Cache /></GDAL_WMS>", 
                 getOption("HTTPUserAgent"))
  src <- paste0(src1, src2)
                 
                 
  if (is.null(source)) {
    rso <- sprintf(src, get_api_key())
  }
  else {
    rso <- source
  }
  if (is.na(x$projection)) {
    message("no projection specified, calling warper without a target projection: results not guaranteed")
    x$projection <- ""
  }
  info <- vapour::vapour_raster_info(rso[1])
  bands <- 1:3
  if (info$bands < 3) {
      bands <- 1L
  }
  suppressWarnings(
  vals <- vapour::gdal_raster_image(rso, target_ext = x$extent, 
                                           target_dim = x$dimension, target_crs = x$projection, 
                                           resample = resample, ..., bands = bands)
)
  x$type <- "terra"
  xraster <- terra::rast(terra::ext(attr(vals, "extent")), 
                         ncol = attr(vals, "dimension")[1L], 
                         nrow =  attr(vals, "dimension")[2L], crs = "EPSG:3857", vals = vals[[1]])
  xraster
}




gdal_aws <- function (extent = c(-180, 180, -90, 90), ..., dimension = NULL, 
                         projection = "OGC:CRS84", resample = "near", source = NULL) 
{
  xraster <- extent
  x <- format_out(list(extent = extent, dimension = dimension, 
                       projection = projection))
  
  src <- sprintf("<GDAL_WMS>\n    <Service name=\"TMS\">\n        <ServerUrl>https://s3.amazonaws.com/elevation-tiles-prod/geotiff/${z}/${x}/${y}.tif</ServerUrl>\n    </Service>\n    <DataWindow>\n        <UpperLeftX>-20037508.340000</UpperLeftX>\n        <UpperLeftY>20037508.340000</UpperLeftY>\n        <LowerRightX>20037508.340000</LowerRightX>\n        <LowerRightY>-20037508.340000</LowerRightY>\n        <TileLevel>15</TileLevel>\n        <TileCountX>1</TileCountX>\n        <TileCountY>1</TileCountY>\n        <YOrigin>top</YOrigin>\n    </DataWindow>\n    <Projection>EPSG:3857</Projection>\n    <BlockSizeX>512</BlockSizeX>\n    <BlockSizeY>512</BlockSizeY>\n    <BandsCount>1</BandsCount>\n    <UserAgent>%s</UserAgent>\n</GDAL_WMS>", 
          getOption("HTTPUserAgent"))
  

  
  if (is.null(source)) {
    rso <- src
  } else {
    rso <- source
  }
  if (is.na(x$projection)) {
    message("no projection specified, calling warper without a target projection: results not guaranteed")
    x$projection <- ""
  }
  
 
  suppressWarnings(
    
  vals <- vapour::gdal_raster_data(rso, target_ext = x$extent, 
                                    target_dim = x$dimension, target_crs = x$projection, 
                                    resample = resample, ..., bands = 1L)
)
  
  xraster <- terra::rast(terra::ext(attr(vals, "extent")), 
                         ncol = attr(vals, "dimension")[1L], 
                         nrow =  attr(vals, "dimension")[2L], crs = "EPSG:3857", vals = vals[[1]])
  xraster
}


gdal_terrainrgb <- function (extent = c(-180, 180, -90, 90), ..., dimension = NULL, 
                      projection = "OGC:CRS84", resample = "near", source = NULL) 
{
  xraster <- extent
  x <- format_out(list(extent = extent, dimension = dimension, 
                       projection = projection))
  
  src1 <- "<GDAL_WMS><Service name=\"TMS\"><ServerUrl>https://api.mapbox.com/v4/mapbox.terrain-rgb/${z}/${x}/${y}.png?access_token=%s</ServerUrl></Service><DataWindow><UpperLeftX>-20037508.34</UpperLeftX><UpperLeftY>20037508.34</UpperLeftY><LowerRightX>20037508.34</LowerRightX><LowerRightY>-20037508.34</LowerRightY><TileLevel>22</TileLevel><TileCountX>1</TileCountX><TileCountY>1</TileCountY><YOrigin>top</YOrigin></DataWindow><Projection>EPSG:3857</Projection><BlockSizeX>256</BlockSizeX><BlockSizeY>256</BlockSizeY><BandsCount>3</BandsCount>"
  src2 <- sprintf("<UserAgent>%s</UserAgent><Cache /><ZeroBlockHttpCodes>404</ZeroBlockHttpCodes></GDAL_WMS>", 
                  getOption("HTTPUserAgent"))
  
  src <- paste0(src1, src2)
  if (is.null(source)) {
    rso <- sprintf(src, get_api_key())
  } else {
    rso <- source
  }
  if (is.na(x$projection)) {
    message("no projection specified, calling warper without a target projection: results not guaranteed")
    x$projection <- ""
  }
  suppressWarnings(
    
  vals <- vapour::gdal_raster_data(rso, target_ext = x$extent, 
                                   target_dim = x$dimension, target_crs = x$projection, 
                                   resample = resample, ..., bands = 1:3)
  )
  
  ##height = -10000 + ((R * 256 * 256 + G * 256 + B) * 0.1)
  d  <-  -10000 + ((vals[[1]] * 256 * 256 + vals[[2]] * 256 + vals[[3]]) * 0.1)
  
  xraster <- terra::rast(terra::ext(attr(vals, "extent")), 
                         ncol = attr(vals, "dimension")[1L], 
                         nrow =  attr(vals, "dimension")[2L], crs = "EPSG:3857", vals = d)
  xraster
}
