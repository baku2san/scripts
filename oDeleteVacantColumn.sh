#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
if [ $# -lt 1 ];then$
  echo "  < targetPathFile で、データが全部空の列を削除"
  echo "  [usage] $0 targetPathFile"
fi$
#echo $0
targetPathFile=$1
targetFile=${1##*/}
targetPath=`dirname $1`/
outputFile=${targetPath}shrinkWin_$targetFile
#currentDir=`pwd`


# == commands
for column in `head -n1 $targetPathFile | sed -e "s/\%[^,]*//g" | tr "," "\n"` 
do
  uniqueCount=`mcut i=$targetPathFile f=$column | 
      mselstr -r v= f=$column |
      wc -l |
      sed -E "s/(\d+).+/\1/g"`

  if [ $uniqueCount != 1 ];then
    validColumns=$validColumns,$column 
  fi
done

mcut i=$targetPathFile f=${validColumns:1} | m2w > ${outputFile}


# == setting for MCMD to default
export KG_VerboseLevel=4

