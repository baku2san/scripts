#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
if [ $# -lt 3 ];then$
  echo "  < targetFile のtargetColumn の重複を除いた数を算出"
  echo "  [usage] $0 targetColumn targetFile isDisplay"$
  echo "  isDisplay: if "-d", head output"$
fi$

#echo $0
targetColumn=$1
targetFile=$2
isDisplay=$3
#currentDir=`pwd`
outputFolder=output
outputFile=$outputFolder/$targetColumn.csv

if ! [ -e $outputFolder ]; then
  mkdir -p $outputFolder
fi

# == commands
mcut i=$targetFile f=$targetColumn | msortf f=$targetColumn | muniq k=$targetColumn o=$outputFile
uniqueCount=`mcount i=$outputFile a=count | mcut f=count | tail -n1`

uniqueCountWithoutNull=`msel i=$outputFile -r c='$s{'$targetColumn'}=="" || $s{'$targetColumn'}=="null"' |mcount a=count | mcut f=count | tail -n1`

if [ $isDisplay = "-d" ]; then
  head $outputFile
fi
echo "output "$outputFile
echo "unique "$targetColumn" is "$uniqueCount"."
echo "unique "$targetColumn" is "$uniqueCountWithoutNull'. without null or "null"'




# == setting for MCMD to default
export KG_VerboseLevel=4

