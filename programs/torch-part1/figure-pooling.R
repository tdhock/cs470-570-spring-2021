library(ggplot2)
library(data.table)
d <- function(input.units, kernel.weights){
  data.table(input.units, kernel.weights)
}
figs.dt <- rbind(
  d(20, 4),
  d(10, 3))
for(figs.i in 1:nrow(figs.dt)){
  figs.row <- figs.dt[figs.i]
  kernel.width <- figs.row$kernel.weights-1
  units.per.layer <- figs.row[, c(
    input=input.units,
    output=input.units-kernel.width
  )]
  g.args <- lapply(units.per.layer, function(N)1:N)
  full.grid.dt <- data.table(do.call(expand.grid, g.args))
  full.grid.dt[, d := input-output+1]
  full.grid.dt[
    d <= 0 | d-1 > kernel.width,
    d := NA]
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
  full.conv.dt <- full.grid.dt[is.finite(d)]
  edge.dt.list <- list()
  for(stride in 1:figs.row$kernel.weights){
    edge.dt.list[[paste(stride)]] <- data.table(
      stride, full.conv.dt[output %% stride == 0])
  }
  edge.dt <- do.call(rbind, edge.dt.list)
  node.dt[, node.label := paste0(ifelse(
    layer.i==1, "x", "h"), unit.i)]
  edge.dt[, output.label := paste0("h", output)]
  out.labels <- edge.dt[, .(node.label=unique(output.label)), by=stride]
  out.nodes <- node.dt[out.labels, on="node.label"]
  in.nodes <- do.call(
    rbind, lapply(
      unique(out.nodes$stride),
      function(stride)data.table(node.dt[layer.i==1], stride)))
  show.nodes <- rbind(in.nodes, out.nodes)
  gg <- ggplot()+
    ggtitle(paste(
      "Number of units:",
      paste(units.per.layer, collapse=",")))+
    geom_segment(aes(
      1, input.y,
      xend=2, yend=output.y),
      data=edge.dt)+
    geom_point(aes(
      layer.i, y),
      shape=21,
      size=8,
      fill="white",
      data=show.nodes)+
    geom_text(aes(
      layer.i, y, label=node.label),
      data=show.nodes)+
    scale_x_continuous("Layer", breaks=unique(node.dt$layer.i))+
    scale_y_continuous("Units", breaks=NULL)+
    facet_grid(. ~ stride, labeller=label_both)
  print(gg)
  png(
    figs.row[, sprintf(
      "figure-pooling-%s-%s.png", input.units, kernel.weights
    )],
    width=10, height=6, units="in", res=200)
  print(gg)
  dev.off()
}

