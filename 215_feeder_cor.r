#列の除去などはbash上でmコマンドで実施。Rは相関行列とグラフの作成のみ

# データの読み込みと相関行列の作成・保存
data <- read.csv("rcgtc_feeder_woabs_r.csv")
data2 <-read.csv("rcgtc_feeder_r.csv")
y <- data.frame(cor(data))
y2 <- data.frame(cor(data2))
write.csv(y,file="cor_woabs.csv")
write.csv(y2,file="cor.csv")

# 相関の無向グラフ
library(qgraph)
qgraph(cor(data),edge.labels=T)
qgraph(cor(data2),edge.labels=T)

# 相関の散布図行列
library(psych)
pairs.panels(data,hist.col="white",rug=F,ellipses=F,lm=T)
pairs.panels(data2,hist.col="white",rug=F,ellipses=F,lm=T)