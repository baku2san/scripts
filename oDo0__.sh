#!/bin/bash

source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
if [ $# -lt 0 ];then$
  echo "  [usage] $0 inputDir outputDir"$
fi$
#echo $0

for file in `ls *.sh | grep -E "^0[0-9]{2}.*"`
do
  if [ $file != "" ]; then
#    if [ -z ${targetFiles} ];then   # true: if length of $value is zero 
#      targetFiles=$file
#    else
      targetFiles=${targetFiles},${file}
#    fi
  fi
done

# 非実行番号指定
exceptNumber=021
for deleting in `echo $exceptNumber | tr "," "\n"`
do
  targetFiles=`echo $targetFiles | sed -E "s/,${deleting}[^\.]+\.sh,*/,/g"`
done

# == commands
for executeFile in `echo ${targetFiles:1} | tr "," "\n"` 
do
  echo $executeFile
done



# == setting for MCMD to default
export KG_VerboseLevel=4

