#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=4

# == initial variables
if [ $# -lt 1 ];then
  echo "  [usage]"`basename $0`" input output"
  echo "  input : inputFilePath"
  echo "  output : outputFilePath"
fi

  inputBaseEx=`basename $1`
  scriptDir=`dirname $0`
  arg1=$1   # file as input
  arg2=$2   # directory as output

  inputFile=$arg1
  inputBase=${inputBaseEx%.*}
  if [ -z $arg2 ];then
    outputFile=out/${inputBaseEx}
  else
    outputFile=$arg2
  fi
  mkdir -p ${outputDir}
  
#=== do
#  totalCount=`wc -l $source | grep -oE "^\s*([0-9]+)"`
  validColumns=
  invalidColumns=
  for column in `head -n1 $inputFile | sed -e "s/\%[^,]*//g" | tr "," "\n"`
  do
    validColumns=$validColumns,${column}:${column}
  done
# %系のだけでもいいけど、抽出するほど大層なものでもないので全部とした
  mfldname -q f=${validColumns:1} i=$inputFile o=$outputFile

    

# == setting for MCMD to default
export KG_VerboseLevel=4

exit
