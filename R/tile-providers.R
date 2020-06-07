aws_string <- function() {
  baseurl <- "https://s3.amazonaws.com/elevation-tiles-prod/geotiff"
  #  "https://s3.amazonaws.com/elevation-tiles-prod/geotiff/12/1227/1500.tif"
  sprintf("%s/{zoom}/{x}/{y}.tif", baseurl)
}

## https://api.mapbox.com/styles/v1/mapbox/dark-v10/tiles/{zoom}/{x}/{y}
## mapbox/streets-v11
##       /outdoors-v11
##       /light-v10
##       /dark-v10
##       /satellite-v9
##       /satellite-streets-v11
## what about "mapbox.terrain-rgb  (seems to work the old way still so special-cased)
mapbox_string <- function(baseurl = "https://api.mapbox.com/styles/v1", type, format, user = "mapbox") {

  tok <- ""
  if (type == "mapbox.terrain-rgb") {
    ## was this deprecated too ...
    baseurl <- "https://api.mapbox.com/v4"
    format <- "pngraw"
    user <- ""
    tok <- ".pngraw"  ## no more @2x by default
  }
  ## Not ideal but gives us some breathing room: FIXME
  if (type %in% c("mapbox.light",  "mapbox.satellite"))  {
    warning("mapbox.light or mapbox.satellite are now replaced by 'light-v10' and 'satellite-v9' - \n get in touch if problems: \n https://github.com/hypertidy/ceramic")
    if (type == "mapbox.light") {
      type <- "light-v10"
    }
    if (type == "mapbox.satellite") {
      type <- "satellite-v9"
    }
  }
  paste0(sprintf("%s/%s/%s/tiles/{zoom}/{x}/{y}%s", baseurl, user, type, tok),
         "?access_token=",
         get_api_key("mapbox"))
}

mk_query_string_custom <- function(baseurl) {
  paste0(baseurl,
         "?access_token=",
         get_api_key())
}
