m <- rworldmap::countriesLow
library(spbabel)
sptable(m) <- sptable(m) %>% dplyr::filter(y_ > -88)

merc_world <-  sp::spTransform(m, "+proj=merc +a=6378137.0 +b=6378137.0")
usethis::use_data(merc_world, internal = TRUE)

