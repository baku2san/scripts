#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=4


# if -d:directoryExist, -f:fileExist, -s:hasAnyByteInTheFile, -e:exist
#    -r:canReadFile, -w:canWriteFile, -x:canExecuteFile
#    -z:stringLengthIs0, -n:stringHasAny, 
#    "$! = 0":直前のコマンド正常終了

# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
  sourceDir=../../../data/maihime
if [ $# -lt 1 ];then
  echo "  [usage]"`basename $0`" input"
  echo "  input : inputFilePath or inputPath which includes inputFiles"
  echo "  outputDir : output for this, default is "`dirname $0`
fi
# 1. column filter : unique count 2<= c <= 50% ?
# 2. column loop
#  a. read csv as each column 
#  b. hist()

  scriptBaseEx=`basename $0`
  scriptDir=`dirname $0`
  arg1=$1   # file or directory as input
  arg2=$2   # directory as output

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
    outputDir=out/${scriptBase}
  else
    outputDir=$arg2
  fi
  mkdir -p ${outputDir}
  
  echo $inputDir $inputFiles $outputDir
#  cou=50897
#  hoge=`bc <<< "scale=1; $cou * 0.45"`

  #if [ hoge -gt 20000 ];then
#    echo $hoge
  #  fi
  
#=== do
for source in `find $inputDir -name $inputFiles`
do
  echo $source .
#  parentDir=`dirname $source`
#  parentDirName=${parentDir##*/}
#  outputDir=${outputDirM}/${parentDirName}
#  output=${outputDir}/${source##*/}
#  sourceBaseName=`basename $source`
#  sourceBaseName=${sourceBaseName%.*}
#  mkdir -p ${outputDir}
  totalCount=`wc -l $source | grep -oE "^\s*([0-9]+)"`
  threshold=$((totalCount / 2))
  #echo $threshold / $totalCount

  validColumns=
  invalidColumns=
# Column毎に抽出するかの判定を行う
  for column in `head -n1 $source | sed -e "s/\%[^,]*//g" | tr "," "\n"`
  do
    #echo $column
    columnCountFile=$outputDir/count/${column}.csv
    mcut i=$source f=$column | 
    msortf f=$column | 
    muniq k=$column o=$columnCountFile

    uniqueCount=`wc -l $columnCountFile | grep -oE "^\s*([0-9]+)"`

  #echo $uniqueCount, $source
    if [ $uniqueCount -ge 2 && $uniqueCount -le $threshold ]; then
      validColumns=$validColumns,$column
    else
      invalidColumns=$invalidColumns,$column
    fi
    
  done
  echo $validColumns as valid
  echo $invalidColumns as invalid
# R用にColumn修正
  inputForR=$outputDir/`basename $source`
  ${scriptDir}/oNormalizeField.sh $source $inputForR

# do at R
  columnCountFile=$outputDir/count/${column}.csv
  output=${outputDir}/hist/${column}.png
  ${scriptDir}/hist.r $columnCountFile $output
done

# == setting for MCMD to default
export KG_VerboseLevel=4

exit
