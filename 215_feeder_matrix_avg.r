setwd("out/210_feeder_matrix_avg/")

# データの読み込み
data_noabs <- read.csv("avg_feeder_noabs.csv")
data_abs   <- read.csv("avg_feeder_abs.csv")

# 相関に意味のないconfiguration%0列、FAdd%1列、FSAdd%2列を削除する
data_noabs <- data_noabs[, !(colnames(data_noabs) %in% c("configuration%0", "FAdd%1", "FSAdd%2"))]
data_abs <- data_abs[, !(colnames(data_abs) %in% c("configuration%0", "FAdd%1", "FSAdd%2"))]

# すべて0になっているMPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MPosiRecL列を削除する
data_noabs <- data_noabs[, !(colnames(data_noabs) %in% c("MPosiRecX_", "MPosiRecY_", "MPosiRecA_","MPosiRecZ_","MPosiRecL"))]
data_abs <- data_abs[, !(colnames(data_abs) %in% c("MPosiRecX_", "MPosiRecY_", "MPosiRecA_","MPosiRecZ_","MPosiRecL"))]

# 同じパラメタのX,YとLは分ける
# errorRate列が最後になるようにする
avg_noabs_xy <- data_noabs[, (colnames(data_noabs) %in% c("RCGX_","RCGY_","TCX_","TCY_","MNTCX_","MNTCY_","TLX_","TLY_","RCGA_","MNTCA_","errorRate"))]
avg_noabs_l <- data_noabs[, (colnames(data_noabs) %in% c("RCGL", "TCL", "MNTCL","TLL","RCGA_","MNTCA_","errorRate"))]

avg_abs_xy <- data_abs[, (colnames(data_abs) %in% c("RCGX_","RCGY_","TCX_","TCY_","MNTCX_","MNTCY_","TLX_","TLY_","RCGA_","MNTCA_","errorRate"))]
avg_abs_l <- data_abs[, (colnames(data_abs) %in% c("RCGL", "TCL", "MNTCL","TLL","RCGA_","MNTCA_","errorRate"))]

# 外れ値の処理
# 各列について平均mと標準偏差sを計算し、m-3*s < x < m+3*s に入らない数を除外する
remove.outliers <- function(x)
{
    m<-mean(x)
    s<-sd(x)
    l<-length(x)
    i<- 10
    for (i in 1:l){
        if((m-3*s>=x[i])||(x[i]>=m+3*s)){
            x[x == x[i]] <- NA
        }
    }
    return(x)
}

#すべての列に上の関数を適用する
avg_noabs_xy_ro <- apply(avg_noabs_xy,2,remove.outliers)
avg_noabs_l_ro <- apply(avg_noabs_l,2,remove.outliers)
avg_abs_xy_ro <- apply(avg_abs_xy,2,remove.outliers)
avg_abs_l_ro <- apply(avg_abs_l,2,remove.outliers)

# 相関行列の作成・保存
# 相関の無向グラフ
# 相関の散布図行列
library(qgraph)
library(psych)


#files <- c("avg_noabs_xy","avg_noabs_xy_ro","avg_noabs_l","avg_noabs_l_ro","avg_abs_xy","avg_abs_xy_ro","avg_abs_l","avg_abs_l_ro")
#datas <- list(avg_noabs_xy,avg_noabs_xy_ro,avg_noabs_l,avg_noabs_l_ro,avg_abs_xy,avg_abs_xy_ro,avg_abs_l,avg_abs_l_ro)

dir.create("avg_noabs_xy")
y <- data.frame(cor(avg_noabs_xy,use="pairwise"))
write.csv(y,file=paste("avg_noabs_xy","/cormatrix.csv", sep = ""))
png(paste("avg_noabs_xy","/qgraph.png", sep = ""))
qgraph(cor(avg_noabs_xy,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_noabs_xy","/matrixgraph.png", sep = ""))
pairs.panels(avg_noabs_xy,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_noabs_xy_ro")
y <- data.frame(cor(avg_noabs_xy_ro,use="pairwise"))
write.csv(y,file=paste("avg_noabs_xy_ro","/cormatrix.csv", sep = ""))
png(paste("avg_noabs_xy_ro","/qgraph.png", sep = ""))
qgraph(cor(avg_noabs_xy_ro,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_noabs_xy_ro","/matrixgraph.png", sep = ""))
pairs.panels(avg_noabs_xy_ro,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_noabs_l")
y <- data.frame(cor(avg_noabs_l,use="pairwise"))
write.csv(y,file=paste("avg_noabs_l","/cormatrix.csv", sep = ""))
png(paste("avg_noabs_l","/qgraph.png", sep = ""))
qgraph(cor(avg_noabs_l,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_noabs_l","/matrixgraph.png", sep = ""))
pairs.panels(avg_noabs_l,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_noabs_l_ro")
y <- data.frame(cor(avg_noabs_l_ro,use="pairwise"))
write.csv(y,file=paste("avg_noabs_l_ro","/cormatrix.csv", sep = ""))
png(paste("avg_noabs_l_ro","/qgraph.png", sep = ""))
qgraph(cor(avg_noabs_l_ro,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_noabs_l_ro","/matrixgraph.png", sep = ""))
pairs.panels(avg_noabs_l_ro,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_abs_xy")
y <- data.frame(cor(avg_abs_xy,use="pairwise"))
write.csv(y,file=paste("avg_abs_xy","/cormatrix.csv", sep = ""))
png(paste("avg_abs_xy","/qgraph.png", sep = ""))
qgraph(cor(avg_abs_xy,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_abs_xy","/matrixgraph.png", sep = ""))
pairs.panels(avg_abs_xy,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_abs_xy_ro")
y <- data.frame(cor(avg_abs_xy_ro,use="pairwise"))
write.csv(y,file=paste("avg_abs_xy_ro","/cormatrix.csv", sep = ""))
png(paste("avg_abs_xy_ro","/qgraph.png", sep = ""))
qgraph(cor(avg_abs_xy_ro,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_abs_xy_ro","/matrixgraph.png", sep = ""))
pairs.panels(avg_abs_xy_ro,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_abs_l")
y <- data.frame(cor(avg_abs_l,use="pairwise"))
write.csv(y,file=paste("avg_abs_l","/cormatrix.csv", sep = ""))
png(paste("avg_abs_l","/qgraph.png", sep = ""))
qgraph(cor(avg_abs_l,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_abs_l","/matrixgraph.png", sep = ""))
pairs.panels(avg_abs_l,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()

dir.create("avg_abs_l_ro")
y <- data.frame(cor(avg_abs_l_ro,use="pairwise"))
write.csv(y,file=paste("avg_abs_l_ro","/cormatrix.csv", sep = ""))
png(paste("avg_abs_l_ro","/qgraph.png", sep = ""))
qgraph(cor(avg_abs_l_ro,use="pairwise"),edge.labels=T)
dev.off()
png(paste("avg_abs_l_ro","/matrixgraph.png", sep = ""))
pairs.panels(avg_abs_l_ro,hist.col="white",rug=F,ellipses=F,lm=T)
dev.off()


