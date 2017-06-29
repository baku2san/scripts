#!/bin/bash
source ~/.bash_profile
shopt -s expand_aliases

# == setting for MCMD
# default 4 as output all level for debug
export KG_VerboseLevel=0


# == initial variables
# !!! 現状は順序依存だが、せめてOption判定とかはした方がいいかもね
if [ $# -lt 2 ];then$
  echo "  < targetPathFile 内で searchWord に合致するデータを持つcolumn のみに削除"
  echo "  [usage] `basename $0` targetPathFile searchWord"
fi$
#echo $0
targetPathFile=$1
targetFile=${1##*/}
targetPath=`dirname $1`/
#targetPath=${1%/*}/  これだと、Pathがない場合に"/"のみついて問題になったので修正
searchWord=$2
outputFile=${targetPath}matchedBy${searchWord}_$targetFile

#currentDir=`pwd`

# == commands
for column in `head -n1 $targetPathFile | sed -e "s/\%[^,]*//g" | tr "," "\n"` 
do
  matchCount=`mcut i=$targetPathFile f=$column | 
      mselstr -sub v=$searchWord f=$column |
      wc -l |
      sed -E "s/(\d+).+/\1/g"`

# sys はほぼ同じだが、user/real で４割ぐらい速度差が生じた。 mselstr のが速い？
#msel c='regexs($s{'$column'}, "'$searchWord'")' | 
# 単一の方が速い？この程度だとPipeで動いても意味がないのかもね
#      grep -oE "\d+" |
#      head -n1`
# これも微妙だが更に重くなった。やっぱり、コマンドは少ない方がいいのかもね
#      mcount a=COUNT | $
#      mcut f=COUNT | $
#      tail -n1`$


  # null 時 "" となるように '"' 追加した  けど、結局COUNT比較やめたんで取り消し
  if [ $matchCount != 1 ];then
    validColumns=$validColumns,$column 
  fi

done

# 先頭に',' が残っているので削って使用
mcut i=$targetPathFile f=${validColumns:1} |
muniq k=${validColumns:1} o=$outputFile
m2w $outputFile > ${outputFile%.*}_win.csv


# == setting for MCMD to default
export KG_VerboseLevel=4

