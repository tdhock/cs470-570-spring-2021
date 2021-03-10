library(data.table)
library(ggplot2)
loss.list <- list(
  cross.entropy=function(f, y)log(1+exp(-y*f)),
  mean.squared.error=function(f, y)(f-y)^2)
loss.dt.list <- list()
for(loss.name in names(loss.list)){
  loss.fun <- loss.list[[loss.name]]
  for(label in c(-1, 1)){
    prediction <- seq(-8, 8, l=101)
    loss.value <- loss.fun(prediction, label)
    loss.dt.list[[paste(loss.name, label)]] <- data.table(
      loss.name, label, prediction, loss.value)
  }
}
loss.dt <- do.call(rbind, loss.dt.list)

gg <- ggplot()+
  geom_line(aes(
    prediction, loss.value),
    data=loss.dt)+
  facet_grid(loss.name ~ label, labeller=label_both, scales="free")
png("figure-loss.png", width=5, height=5, res=200, units="in")
print(gg)
dev.off()
