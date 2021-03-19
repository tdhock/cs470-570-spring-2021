d <- function(input.units, kernel.weights){
  data.table(input.units, kernel.weights)
}
figs.dt <- rbind(
  d(3, 2),
  d(6, 3))
for(figs.i in 1:nrow(figs.dt)){
  figs.row <- figs.dt[figs.i]
  kernel.width <- figs.row$kernel.weights-1
  units.per.layer <- figs.row[, c(
    input=input.units,
    output=input.units-kernel.width
  )]
  g.args <- lapply(units.per.layer, function(N)1:N)
  full.grid.dt <- data.table(do.call(expand.grid, g.args))
  full.grid.dt[, fully.connected := paste0(output, ",", input)]
  full.grid.dt[, convolutional := input-output+1]
  full.grid.dt[
    convolutional <= 0 | convolutional-1 > kernel.width,
    convolutional := NA]
  node.dt.list <- list()
  for(layer.i in seq_along(units.per.layer)){
    col.name <- names(units.per.layer)[[layer.i]]
    layer.node.vec <- full.grid.dt[[col.name]]
    units <- units.per.layer[[layer.i]]
    unit.i <- 1:units
    y <- unit.i - (units+1)/2
    set(full.grid.dt, j=paste0(col.name, ".y"), value=y[layer.node.vec])
    set(full.grid.dt, j=paste0(col.name, ".layer"), value=layer.i)
    node.dt.list[[layer.i]] <- data.table(
      unit.i, layer.i, y)
  }
  (node.dt <- do.call(rbind, node.dt.list))
  edge.dt <- suppressWarnings(data.table::melt(
    full.grid.dt,
    measure=c("fully.connected", "convolutional"),
    variable.name="connectivity",
    value.name="subscript",
    na.rm=TRUE))
  meta.dt <- edge.dt[, .(
    weights=length(unique(subscript))
  ), by=connectivity]
  library(ggplot2)
  addMeta <- function(dt){
    dt[meta.dt, n.weights := weights, on="connectivity"]
  }
  cc <- function(a,b,s){
    i <- as.integer(substr(paste0(s), 1, 1))
    p <- 0.8-0.08*(i %% 2)
    p*a+(1-p)*b
  }
  addMeta(edge.dt)
  gg <- ggplot()+
    ggtitle(paste(
      "Number of units:",
      paste(units.per.layer, collapse=",")))+
    geom_segment(aes(
      input.layer, input.y,
      xend=output.layer, yend=output.y),
      data=edge.dt)+
    geom_label(aes(
      cc(input.layer, output.layer, subscript),
      cc(input.y, output.y, subscript),
      label=paste0("w", subscript)),
      data=edge.dt)+
    geom_point(aes(
      layer.i, y),
      shape=21,
      size=8,
      fill="white",
      data=node.dt)+
    geom_text(aes(
      layer.i, y, label=paste0(ifelse(
        layer.i==1, "x", "h"), unit.i)),
      data=node.dt)+
    scale_x_continuous("Layer", breaks=unique(node.dt$layer.i))+
    scale_y_continuous("Units", breaks=NULL)+
    facet_grid(. ~ connectivity + n.weights, labeller=label_both)
  png(
    figs.row[, sprintf(
      "figure-convolutional-%s-%s.png", input.units, kernel.weights
    )],
    width=10, height=6, units="in", res=200)
  print(gg)
  dev.off()
}

