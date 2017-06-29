#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
if [ $# -lt 2 ];then$
  echo "  < targetFile に対し、xColumn,yColumn のCountを算出"
  echo "  [usage] `basename $0` xColumn yColumn targetFile"
fi$
#echo $0
xColumn=$1
yColumn=$2
targetFile=$3
#currentDir=`pwd`
outputFolder=outputChart
outputFile=$outputFolder/X${xColumn}_Y$yColumn.csv
echo $xColumn,$yColumn,$outputFile

if ! [ -e $outputFolder ]; then
  mkdir -p $outputFolder
fi

# == commands
mcut i=$targetFile f=$xColumn,$yColumn | mcount k=$xColumn,$yColumn a=count | muniq k=$xColumn,$yColumn o=$outputFile

#echo "finished at "$outputFile


# == setting for MCMD to default
export KG_VerboseLevel=4

