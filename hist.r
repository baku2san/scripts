#!/usr/local/bin/Rscript
#--default-packages=
#--slave --vanilla

#initial.options<- commandArgs(trailingOnly=FALSE)
#file.arg.name<- "--file="
#script.name<- sub(file.arg.name, "", initial.options[grep(file.arg.name, initial.options)])
#script.dirname<- dirname(script.name)
#print(script.name)
#print(script.dirname)

  # こんな感じでPackage入れるとOptionを簡単に作れるみたい 
  #res <- try(install.packages("optparse"))   Tryもできるっぽい
  #if(inherits(res, "try-error")) q(status=1) else q()
  library(optparse)
  # action: store_true : 引数省略?　-fのみでTRUEになる
  option_list <- list(
    make_option(c("-f", "--pdf"), default=FALSE, type="logical", action="store_true",
      help="output as pdf"),
    make_option(c("-j", "--jpg"), default=FALSE, type="logical", action="store_true",
      help="output as jpg"),
    make_option(c("-c", "--column"), default="", type="character",
      help="output as jpg")
#      help="Multiply output by this number [default %default]")
  )
  
  parser <- OptionParser(usage="%prog [options] input output", option_list=option_list)
  args <- parse_args(parser, positional_arguments = c(0,2), print_help_and_exit=TRUE)
  opt <- args$options
  files <- args$args  # input, output
 # if(opt$count_lines) {
 #   print(paste(length(readLines(file)) * opt$factor))
 # }
 print(opt)
if (length(files)!=2){
  print_help(parser)
  q()
}

# ls()      : get objects
# get(ls()) : get values
#print(typeof(opt[[1]]))  !! opt はListなので
isPdf<-opt[[1]]
isJpg<-opt[[2]]
#inputFile<-paste(script.dirname, files[1], sep="/")  Path 整形必要かなって時の名残
inputFile<-files[1]
outputFile<-files[2]

if (isPdf){
  pdf(outputFile)
}else if(isJpg){
  jpeg(outputFile)
}else{
  png(outputFile)
}
# 以下もあるよ
# tiff()
# bmp()
library(readr)
input<-read_csv(inputFile, col_names = FALSE)
columnName<-"X1"
#input<-scan(inputFile)
hist(cat(input, columnName, "$"))
#dev.off()

#cat("Hello")

#x <- seq(-3,3,length=50)     # x 方向の分点
#y <- x                       # y 方向の分点
#rho <- 0.9                   # 2次元正規分布の定数
#gauss3d <- function(x,y) {   # 2次元正規分布の関数
#1/(2*pi*sqrt(1-rho^2))*exp(-(x^2-2*rho*x*y+y^2) / (2*(1-rho^2)))
#}
#z <- outer(x,y,gauss3d)      # 外積をとって z 方向の大きさを求める
#z[is.na(z)] <- 1             # 欠損値を1で補う
#persp(x, y, z, theta = 30, phi = 30, expand = 0.5, col = "lightblue")
