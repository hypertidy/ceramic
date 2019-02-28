is_jpeg <- function(x) {
  if (!file.exists(x[1])) return(FALSE)
  if (file.info(x[1])$size <= 11L) return(FALSE)
  rawb <- readBin(x[1], "raw", n = 11L)
  all(rawb[1:2] == as.raw(c(0xff, 0xd8))) && rawToChar(rawb[7:11]) == "JFIF"
}

is_png <- function(x) {
  #"89 50 4e 47 0d 0a 1a 0a"
  if (!file.exists(x[1])) return(FALSE)
  if (file.info(x[1])$size <= 8L) return(FALSE)
  rawb <- readBin(x[1], "raw", n = 8L)
  all(rawb == as.raw(c(0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a)))
}
