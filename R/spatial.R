.spatial_classes <- function() {
  c("Spatial",
    "sf", "sfc",
    "BasicRaster", "Extent",
    "SpatRaster","SpatExtent", "SpatVector",
    "wk_vctr", "wk_rcrd", "wk_grd",
    "geos_geometry", 
    "stars")
}
is_spatial <- function(x) {
  inherits(x, .spatial_classes())
}

#' @importFrom terra is.lonlat
#' @importFrom wk wk_crs
.crs_crs <- function(x) {
  crs <- crsmeta::crs_wkt(x)
  if (is.na(crs)) {
    proj <- crsmeta::crs_proj(x)
    if (!is.na(proj)) {
      crs <- proj 
    }
  }

  if (is.na(crs)) {
    crs_maybe <- try(wk::wk_crs(x), silent = TRUE)
    if (!inherits(crs_maybe, "try-error") && is.character(crs_maybe) && !is.na(crs_maybe)) {
      crs <- crs_maybe
    } else {
      if (!inherits(crs_maybe, "try-error") && !is.null(crs_maybe$Wkt) && !is.na(crs_maybe$Wkt)) {
      crs <- crs_maybe$Wkt
      }
    }
  }
  if (is.na(crs) && (inherits(x, "SpatRaster") || inherits(x, "SpatVector"))) {
    #crs <- try(x@ptr$get_crs("wkt"), silent = TRUE)
    crs <- terra::crs(x)
	## This should never happen?
	#if (inherits(crs, "try-error")) {
    #  crs <- NA_character_
    #}
    
    if (is.na(crs)) {
#      if (x@ptr$isLonLat()) {
	  if (terra::is.lonlat(x, perhaps=FALSE, warn=FALSE)) {
		crs <- "+proj=longlat +datum=WGS84"
      }
    }
  }
  if (is.na(crs)) {
    if (inherits(x, "stars")) {
      dms <- attr(x, "dimension")
      crs <- try(dms[[1]]$refsys$wkt, silent = TRUE)
      if (inherits(crs, "try-error")) stop("cannot detemine crs from this stars object")
      
    }
    if (inherits(x, "Extent")) {
      ex <- c(x@xmin, x@xmax, x@ymin, x@ymax)
      if (ex[1] >= -180 && ex[2] <= 360 && ex[3] >= -90 && ex[4] <=90) {
        crs <- "+proj=longlat +datum=WGS84"
      }
    } 
    if (inherits(x, "SpatExtent")) {
      ex <- c(terra::xmin(x), terra::xmax(x), terra::ymin(x), terra::ymax(x))
      if (ex[1] >= -180 && ex[2] <= 360 && ex[3] >= -90 && ex[4] <=90) {
        crs <- "+proj=longlat +datum=WGS84"
      }
    } 
    
    if (is.na(crs)) stop("no valid crs found on input object")
  }
  if (crs == "NAD27") {
    crs <- "EPSG:4267"
    
  }
  if (crs == "WGS 84") {
    srcproj <- "+proj=longlat +datum=WGS84"
    
  }
  
  crs
}

#' @importFrom wk wk_bbox
.ext_ext <- function(x) {
  ex <- try(terra::ext(x), silent = TRUE)
  if (!inherits(ex, "try-error")) {
   out <-   c(terra::xmin(ex), terra::xmax(ex), terra::ymin(ex), terra::ymax(ex))
   return(out)
  }
  ex <- try(wk::wk_bbox(x), silent = TRUE) 
  if (!inherits(ex, "try-error")) {
    out <-  as.numeric(ex)[c(1L, 3L, 2L, 4L)] 
    return(out)
  }
  if (inherits(x, "stars")) {
   
    dms <- attr(x, "dimension")
    dm <- c(dms[[1]]$to - dms[[1]]$from + 1, dms[[2]]$to - dms[[2]]$from + 1)
    ex <- c(dms[[1]]$offset + c(1,1) * c(0, dm[1] * dms[[1]]$delta), 
           dms[[2]]$offset + c(1,1) * c(dm[2] * dms[[2]]$delta, 0))
    if (anyNA(ex)) stop("cannot determine extent from this stars object")
    return(ex)
  }
  stop("could not get an extent from input")
}





#' @importFrom stats approx
project_ex <- function(x, crs = .merc()) {
  
  ex <- .ext_ext(x)
  idx <- c(1, 1, 2, 2, 1,
           3, 4, 4, 3, 3)
  xy <- matrix(ex[idx], ncol = 2L)
  afun <- function(aa) stats::approx(seq_along(aa), aa, n = 180L)$y
  
  srcproj <- .crs_crs(x)
  
  xy <- cbind(afun(xy[,1L]), afun(xy[,2L]))
  rpj <- terra::project(xy, to = crs, from = srcproj)
  
  diff(as.vector(apply(rpj, 2, range)))[c(1L, 3L)]
}


spatial_bbox <- function(loc, buffer = NULL) {
  if (is_spatial(loc)) {

    buffer <- project_ex(loc)/2
    loc <- spex_to_pt(loc)
    
  } else {
    if (!is.numeric(loc)) stop(sprintf("unrecognized object 'loc', of type:\n %s\n", 
                                       class(loc)[1L]))
  }
  
  if (is.null(buffer)) buffer <- c(0, 0)
  ## handle case where loc had either no width or no height
  if (any(!buffer > 0)) {
    # one of the values is gt 0
    if (any(buffer > 0)) buffer <- rep(max(buffer, 2L))
    if (all(!buffer > 0)) {
      warning("input object has no width or height, using default buffer (5000m)")
      buffer <- c(5000, 5000)
    }
  }
  buffer <- rep(buffer, length.out = 2L)
  if (length(loc) > 2) {
    warning("'loc' should be a length-2 vector 'c(lon, lat)' or matrix 'cbind(lon, lat)'")
  }
  if (is.null(dim(loc))) {
    loc <- matrix(loc[1:2], ncol = 2L)
  }
  
  ## convert loc to mercator meters
  loc <- slippymath::lonlat_to_merc(loc)
  
  xp <- buffer[1] ## buffer is meant to be from a central point, so a radius
  yp <- buffer[2]
  
  ## xmin, ymin
  ## xmax, ymax
  bb_points <- matrix(c(loc[1,1] - xp, loc[1,2] - yp, loc[1,1] + xp, loc[1,2] + yp), 2, 2, byrow = TRUE)
  if (!slippymath::within_merc_extent(bb_points)){
    warning("The combination of buffer and location extends beyond the tile grid extent. The buffer will be truncated.")
    bb_points <- slippymath::merc_truncate(bb_points)
  }
  
  ## convert bb_points back to lonlat
  bb_points_lonlat <- slippymath::merc_to_lonlat(bb_points)
  
  tile_bbox <- c(xmin = bb_points_lonlat[1,1], ymin = bb_points_lonlat[1,2],
                 xmax = bb_points_lonlat[2,1], ymax = bb_points_lonlat[2,2])
  user_points <- bb_points
  
  list(tile_bbox = tile_bbox, user_points = user_points, extent = as.vector(bb_points))
}
spex_to_pt <- function(x) {
  ex <- .ext_ext(x)
  crs <- .crs_crs(x)
  pt <- cbind(mean(ex[1:2]), mean(ex[3:4]))
  is_ll <- terra::is.lonlat(crs)
  
  if (!is_ll) {
    suppressWarnings(
      pt <- terra::project(pt, to = .ll(), from  = crs)
    )
    
  }
  return(pt)
  
}



