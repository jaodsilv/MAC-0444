n <- 10000

f1 <- 20000 + 10*100*10
f2 <- 25000 + 10*50*10
f3 <- 30000 + 10*12*10
f4 <- 38000 + 5*10*10

gera_pedido <- function(fato) {  
  if(fato %in% c('Horas Extras','Nada')) {
    p1 <- 20000 + 10*rgamma(1, shape=100, scale=10)
    p <- p1
  }
  if(fato %in% c('Insalubridade','Nada')) {
    p2 <- 25000 + 10*rgamma(1, shape=50, scale=10)
    p <- p2
  }
  if(fato %in% c('Periculosidade','Nada')) {
    p3 <- 30000 + 10*rgamma(1, shape=12, scale=10)
    p <- p3
  }
  if(fato %in% c('Danos morais','Nada')) {
    p4 <- 38000 + 5*rgamma(1, shape=10, scale=10)
    p <- p4
  }
  if(fato %in% 'Nada') {
    p0 <- (p1+p2+p3+p4)/4  
    p <- p0
  }
  return(p)
}


adv <- rep(c('briga','concilia'),each=n/2)
fato <- rep(rep(c('Horas Extras','Insalubridade','Periculosidade','Danos morais','Nada'),each=n/10),2)
vl_fato <- rep(rep(c(f1,f2,f3,f4,0),each=n/10),2)
pedido <- sapply(fato, gera_pedido)
bd <- data.frame(id=1:n, fato=fato, vl_fato=vl_fato, pedido=pedido, adv=adv)
pf <- rep(c(.8,.5,.5,.5,.2), each=n/10)
bd$acordo <- ifelse(bd$adv == 'briga', NA, bd$pedido*8/10 * ifelse(runif(n/2) > pf,1,NA))
bd$decisao <- ifelse(is.na(bd$acordo), bd$vl_fato, bd$acordo)
bd$gasto_tot <- 1000 + 1000 * (bd$adv %in% 'concilia') + 1000 * (bd$adv %in% 'concilia' & is.na(bd$acordo)) + bd$decisao


ddply(bd, .(adv,fato),summarise,gasto=mean(gasto_tot),pedido=mean(pedido))

require(ggplot2)
require(plyr)

ggplot(bd, aes(x=pedido,group=fato)) +
  geom_histogram(binwidth=200) +
  facet_grid(.~fato) +
  theme_bw()

ggplot(bd, aes(x=gasto_tot,group=fato)) +
  geom_histogram(binwidth=100) +
  facet_grid(adv~fato,scales='free') +
  theme_bw()