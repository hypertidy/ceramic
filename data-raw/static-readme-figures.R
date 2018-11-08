png("man/figures/README-tile-plot.png")
ceramic::plot_tiles(ceramic_tiles(zoom = c(7, 9)))
dev.off()

png("man/figures/README-tile-add-plot.png")
plotRGB(im)
ceramic::plot_tiles(ceramic_tiles(zoom = 7), add = TRUE)
dev.off()
