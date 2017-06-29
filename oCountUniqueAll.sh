#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
if [ $# -lt 1 ];then$
  echo "  < targetFile のすべてのColumn に対するuniqe value calculated"
  echo "  [usage] $0 targetFile"
fi$
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
#echo $0
targetFile=$1
#currentDir=`pwd`


# == commands
for column in `head -n1 $targetFile | sed -e "s/\%[^,]*//g" | tr "," "\n"` 
do
  bash ~/Bins/oCountUnique.sh $column $targetFile -d
done


