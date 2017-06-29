#!/bin/bash

source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0

set -f

# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
if [ $# -lt 2 ];then
  echo "  < inputDir 内の*.csv に対し一意のデータリストを作成"
  echo "  [usage] "`basename $0`" inputDir outputDir"
fi

  arg1=$1
  arg2=$2

  if [ -d $arg1 ]; then        # "path/file.ext" or "path/folder" or "path/folder/"
    inputDir=$arg1
    inputFiles=*.csv
  else
    inputDir=`dirname $arg1`      # path 
    inputFiles=`basename $arg1`   # file.ext
    if [ -z $inputDir ];then
      inputDir=.
    fi
  fi
  scriptBase=${scriptBaseEx%.*}
  if [ -z $arg2 ];then
    outputDirM=`basename $0`
  else
    outputDirM=$arg2
  fi

  mkdir -p ${outputDirM}

for input in `find $inputDir -name $inputFiles`
do
    filename=`basename $input`
    parentDir=`dirname $input`
    outputDir=${outputDirM}/${parentDir##*/}
    outputBase=${outputDir}/${filename%.*}
    mkdir -p ${outputDir}
    mkdir -p ${outputBase}

  for column in `head -n1 $input | sed -e "s/\%[^,]*//g" | tr "," " "` 
  do
    mcut i=$input f=$column |
    msortf f=$column | 
    muniq k=$column o=${outputBase}/${column}.csv
  done
done


# == setting for MCMD to default
export KG_VerboseLevel=4

