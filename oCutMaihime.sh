#!/bin/bash

source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=4


# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
  sourceDir=../../../data/maihime
if [ $# -lt 2 ];then
  echo "  < "$sourceDir" is converted by inputDir into outputDir"
  echo "  [usage] `basename $0` inputDir outputDir"
  echo "  inputDir : output of oResearchUniqueAll.sh"
  echo "  outputDir : output for this"
fi
exit

  inputResearchUniqueDir=$1 # oResearchUniqueAll.sh 実行結果格納folder
  inputFiles=*.csv
  outputDirM=$2 # folder for cut source data 
  output=
  if ! [ -e ${outputDirM} ]; then
    mkdir -p ${outputDirM}
  fi
  
for source in `find $sourceDir -name $inputFiles`
do
    parentDir=`dirname $source`
    parentDirName=${parentDir##*/}
    outputDir=${outputDirM}/${parentDirName}
    output=${outputDir}/${source##*/}
    sourceBaseName=`basename $source`
    sourceBaseName=${sourceBaseName%.*}
  if ! [ -e ${outputDir} ]; then
    mkdir -p ${outputDir}
  fi

  inputDir=${inputResearchUniqueDir%/}/${parentDirName}/${sourceBaseName}
  validColumns=
  invalidColumns=
  for input in `find $inputDir -name "$inputFiles"`
  do
      filename=`basename $input`
      outputBase=${outputDir}/${filename%.*}
  
    lineCount=`wc -l $input | grep -oE "^\s*([0-9]+)"`
  
  #echo $lineCount, $input
    if [ $lineCount  -gt 2 ]; then
      validColumns=$validColumns,${filename%.*}
    else
      invalidColumns=$invalidColumns,${filename%.*}
    fi
    
  done
  outputColumnsDir=${outputDir}/${sourceBaseName}
  if ! [ -e ${outputColumnsDir} ]; then
    mkdir -p ${outputColumnsDir}
  fi
  echo $validColumns > ${outputColumnsDir}/valid
  echo $invalidColumns > ${outputColumnsDir}/invalid

#  echo ${validColumns:1}, $output
  mcut i=$source f=${validColumns:1} o=$output

  
  #  for column in `head -n1 $input | sed -e "s/\%[^,]*//g" | tr "," "\n"` 
  #  do
  #    mcut i=$input f=$column |
  #    msortf f=$column | 
  #    muniq k=$column o=${outputBase}/${column}.csv
  #  done
  
done

# == setting for MCMD to default
export KG_VerboseLevel=4

