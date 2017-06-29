#!/bin/bash

source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
if [ $# -lt 1 ];then$
  echo "  [usage] $0 targetFile"
fi$
#echo $0
targetFile=$1
#currentDir=`pwd`

initialColumns=`head -n1 $targetFile | sed -e "s/\%[^,]*//g"`

# Allにすると重すぎるので、ここに合致するものは削除することにしよう
exceptColumns=Date,Time,EventMainMessage,EventSubMessage,fileName,datetime,YYYYMMDD,YYYY,MM,DD,hh,mm,ss,__lineno,lineno

targetColumns=$initialColumns
for deletingWord in `echo $exceptColumns | tr "," "\n"`
do
  targetColumns=`echo $targetColumns | sed -e "s/${deletingWord},*//g"`
done
# == commands
for columnAsX in `echo $targetColumns | tr "," "\n"` 
do
  for columnAsY in `echo $targetColumns | tr "," "\n"`
  do
    if [ $columnAsX != $columnAsY ]; then
      #echo $columnAsX,$columnAsY
      bash ~/Bins/oMakeChart.sh $columnAsX $columnAsY $targetFile
    fi
  done
done



# == setting for MCMD to default
export KG_VerboseLevel=4

