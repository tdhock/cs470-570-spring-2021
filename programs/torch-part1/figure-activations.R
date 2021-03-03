library(data.table)
library(ggplot2)
input <- seq(-3, 3, by=0.1)
fun.list <- list(
  relu=function(x)ifelse(x>0, x, 0),
  sigmoid=function(x)1/(1+exp(-x)))

act.dt.list <- list()
for(activation.name in names(fun.list)){
  fun <- fun.list[[activation.name]]
  act.dt.list[[activation.name]] <- data.table(
    activation.name,
    input,
    activation=fun(input))
}
act.dt <- do.call(rbind, act.dt.list)

gg <- ggplot()+
  geom_line(aes(
    input, activation),
    data=act.dt)+
  facet_grid(. ~ activation.name)
png("figure-activations.png", width=5, height=3, units="in", res=200)
print(gg)
dev.off()
