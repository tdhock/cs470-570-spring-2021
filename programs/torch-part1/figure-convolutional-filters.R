library(data.table)
d <- function(input.units, kernel.weights, n.filters){
  data.table(input.units, kernel.weights, n.filters)
}
figs.dt <- rbind(
  d(3, 2, 1),
  d(3, 2, 2),
  d(6, 3, 1),
  d(6, 3, 2))
getY <- function(u){
  u - (max(u)+1)/2
}
for(figs.i in 1:nrow(figs.dt)){
  figs.row <- figs.dt[figs.i]
  kernel.width <- figs.row$kernel.weights-1
  out.units.per.filter <- figs.row$input.units-kernel.width
  out.dt <- data.table(expand.grid(
    window.i=1:out.units.per.filter,
    filter.i=1:figs.row$n.filters))
  out.dt[, output.layer := 2L]
  out.dt[, output.row  := 1:.N]
  out.dt[, output.y := getY(window.i)+0.5*(filter.i-1)]
  out.dt[, output.name := sprintf(
    "h%d,%d", filter.i, window.i)]
  out.dt[, output.x := 2+0.2*(filter.i-1)]
  in.dt <- data.table(
    input.row=1:figs.row$input.units,
    input.layer=1L)
  in.dt[, input.x := as.numeric(input.layer)]
  in.dt[, input.y := getY(input.row)]
  in.dt[, input.name := paste0("x", input.row) ] 
  full.grid.dt <- data.table(expand.grid(
    input.row=in.dt$input.row,
    output.row=out.dt$output.row
  ))[out.dt, on="output.row"][in.dt, on="input.row"]
  tall.grid <- nc::capture_melt_multiple(
    full.grid.dt,
    layer.name="input|output",
    "[.]",
    column=".*")
  node.dt <- unique(tall.grid[, .(layer.name, layer, name, row, x, y)])
  node.counts <- node.dt[, .(units=.N), by=layer]
  full.grid.dt[, fully.connected := paste0(
    input.name, "->", output.name)]
  full.grid.dt[, diff := input.row-window.i]
  full.grid.dt[
    diff < 0 | diff > kernel.width,
    diff := NA]
  full.grid.dt[, convolutional := ifelse(
    is.na(diff), NA, sprintf(
      "v%d,%d", filter.i, diff+1))]
  edge.dt <- suppressWarnings(data.table::melt(
    full.grid.dt,
    measure=c("fully.connected", "convolutional"),
    variable.name="connectivity",
    value.name="subscript",
    na.rm=TRUE))
  meta.dt <- edge.dt[, .(
    connections=.N,
    weights=length(unique(subscript))
  ), by=connectivity]
  library(ggplot2)
  addMeta <- function(dt){
    dt[meta.dt, `:=`(
      n.parameters=weights,
      n.connections=connections
    ), on="connectivity"]
  }
  cc <- function(a,b,i){
    offset <- 0.4
    p <- 0.8-offset*(i %% 2)
    p*a+(1-p)*b
  }
  addMeta(edge.dt)
  gg <- ggplot()+
    figs.row[, ggtitle(paste(
      "Number of units:",
      paste(node.counts$units, collapse=","),
      "filters:", n.filters,
      "kernel.size:", kernel.weights))]+
    geom_segment(aes(
      input.x, input.y,
      xend=output.x, yend=output.y),
      data=edge.dt)+
    geom_segment(aes(
      input.x, input.y,
      color=subscript,
      xend=output.x, yend=output.y),
      data=edge.dt[connectivity=="convolutional"])+
    geom_label(aes(
      cc(input.x, output.x, filter.i),
      cc(input.y, output.y, filter.i),
      label=subscript),
      data=edge.dt)+
    geom_label(aes(
      cc(input.x, output.x, filter.i),
      cc(input.y, output.y, filter.i),
      color=subscript,
      label=subscript),
      data=edge.dt[connectivity=="convolutional"])+
    geom_point(aes(
      x, y),
      shape=21,
      size=15,
      fill="white",
      data=node.dt)+
    geom_text(aes(
      x, y, label=name),
      data=node.dt)+
    scale_x_continuous("Layer")+
    theme(legend.position="none")+
    scale_y_continuous("Units", breaks=NULL)+
    facet_grid(. ~ connectivity + n.parameters + n.connections, labeller=label_both)
  gg
  png(
    figs.row[, sprintf(
      "figure-convolutional-filters-%d-%d-%d.png",
      input.units, kernel.weights, n.filters
    )],
    width=10, height=6, units="in", res=200)
  print(gg)
  dev.off()
}

