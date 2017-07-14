#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=4

set -f
# == initial variables
  scriptBaseEx=`basename $0`
  scriptBase=${scriptBaseEx%.*}
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
  if [ -z $arg2 ];then
    outputDir=out/${scriptBase}
  else
    outputDir=$arg2
  fi
  
  mkdir -p ${outputDir}

### === functions
function divideColumnByUniqueValue() {
  _input=$1
  _outputD=$2
  _columnNames=`head -n1 $_input | sed -e "s/\%[^,]*//g"`
  _skipColumns=
# current is nothing to skip

  for _column in ${_columnNames//,/ } ;do
    _outputSubD=$_outputD/${_column}
    mkdir -p $_outputSubD
    echo [ $_column ]
    canSkip=false
    for skipColumn in ${_skipColumns//,/ };do
      echo $skipColumn
      if [ "$skipColumn" == "$_column" ];then
        canSkip=true
        break
      fi
    done
    if [ "$canSkip" == "true" ];then
      echo $_column is skipped
      continue
    fi
    _count=0
    for _value in `mcut f=${_column} i=$_input |muniq k=${_column} | tail -n+2|tr '\n' ' '`;do
      echo value $_value
      _output=$_outputSubD/${_value}.csv
      msel i=$_input c='$s{'${_column}'}=="'${_value}'"' o=$_output
      _count=$((_count + 1))
      if [ $_count -gt 100 ]; then
        touch moreThan100
        break
      fi
    done
  done
  return 0
}
#=== do
for source in `find $inputDir -name $inputFiles`; do
  sourceBaseEx=`basename $source`
  sourceBase=${sourceBaseEx%.*}
  sourceBaseEnd=${sourceBase#*_}
  sourceMac=${compareDir}/${sourceBaseEx}

  divideColumnByUniqueValue $input $outputDir
done
