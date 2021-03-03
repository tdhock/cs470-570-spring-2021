units.per.layer.list <- list(
  fiveLayers=c(4, 10, 5, 3, 1),
  oneOut=c(12, 5, 1),
  tenOut=c(12,5,10))
for(units in c(2, 20)){
  units.per.layer.list[[paste0("reg", units)]] <- c(1, units, 1)
}
for(net.name in names(units.per.layer.list)){
  unit.dt.list <- list()
  units.per.layer.vec <- units.per.layer.list[[net.name]]
  for(layer.i in seq_along(units.per.layer.vec)){
    units <- units.per.layer.vec[[layer.i]]
    y <- 1:units - (units+1)/2
    unit.dt.list[[layer.i]] <- data.table(
      layer.i, y)
  }
  edge.dt.list <- list()
  for(layer.i in 1:(length(unit.dt.list)-1)){
    before <- data.table(unit.dt.list[[layer.i]])[, .(
      before.y=y, before.layer=layer.i)]
    before$b <- 1:nrow(before)
    after <- data.table(unit.dt.list[[layer.i+1]])[, .(
      after.y=y, after.layer=layer.i)]
    after$a <- 1:nrow(after)
    join.dt <- data.table(expand.grid(
      b=before$b, a=after$a
    ))[before, on="b"][after, on="a"]
    edge.dt.list[[layer.i]] <- data.table(layer.i, join.dt)
  }
  unit.dt <- do.call(rbind, unit.dt.list)
  edge.dt <- do.call(rbind, edge.dt.list)
  gg <- ggplot()+
    ggtitle(paste(
      "Number of units:",
      paste(units.per.layer.vec, collapse=",")))+
    geom_segment(aes(
      before.layer, before.y,
      xend=after.layer, yend=after.y),
      data=edge.dt)+
    geom_point(aes(
      layer.i, y),
      shape=21,
      size=4,
      fill="white",
      data=unit.dt)+
    scale_x_continuous("Layer", breaks=unique(unit.dt$layer.i))+
    scale_y_continuous("Units", breaks=NULL)
  png(
    sprintf("figure-architecture-%s.png", net.name),
    width=5, height=3, units="in", res=200)
  print(gg)
  dev.off()
}


