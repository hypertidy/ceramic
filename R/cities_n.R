cities_n <- function(n = 1L, fields = FALSE) {
  idx <- sample(dim(cities)[1L], n)
  out <- if(fields) {
    cities[idx, c("long", "lat", "name", "country.etc", "pop",  "capital")] 
  } else {
    cities[idx, c("long", "lat")] 
  }
  out
}
