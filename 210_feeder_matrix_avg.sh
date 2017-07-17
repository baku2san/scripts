#!/bin/sh

# 舞姫データ TraceReport/MountQualityTrace (装着1部品ごとのレコード)
# を用いて、フィーダごとに エラー率,RCGX/Y/A,TCX/Y,MPosiRecX/Y/A/Z,MNTCX/Y/A,TLX/Yの値を平均する

# 計算する前に絶対値をとるか、とらないかを選択できる

# 2017. 5.30 maegawa@KSK
# 2017. 6. 1 hatanaka@ksk 編集 
# 2017. 6. 6 maegawa@KSK 修正

# 入力ディレクトリ/ファイル
iDir=../Cut/TraceReport
iFile=$iDir/MountQualityTrace.csv

# 出力ディレクトリ
oDir=out0707/tables
mkdir -p $oDir

#RCG,TCの絶対値を先に計算するか(abs/noabs)
zettaichi=abs

columnsTarget=RCGX,RCGY,RCGA,TCX,TCY,MNTCX,MNTCY,MNTCA,TLX,TLY
columnsBase=Node,ReelID,datetime,File,FAdd,FSAdd,Head,NHAdd,$columnsTarget
isOutput=test
block1=do
block1=do
if [ $isOutput ];then
  xx1=xx1.csv
  xx2=xx2.csv
  xx3=xx3.csv
else
  xx1=`mktemp`
  xx2=`mktemp`
  xx3=`mktemp`
fi

# MountQualityTrace からフィーダアドレス、同サブアドレス、ノズルヘッドアドレスを取り出す
# ヘッド番号はデータにないので、フィーダアドレスの先頭 1 桁を流用する
if [ $block1 ];then
mcal i=$iFile c='left($s{FAdd},1)' a=Head |
  mcal c='regexsfx($s{File}, "~")' a=fileInfo |
  mcal c='regexpfx($s{fileInfo}, "(-[^-]+){6}\\.")' a=datetime |
  mcut f=$columnsBase o=$xx1
fi
# RCGA/MNTCA について、90°付近のものは-90する等
#mcal i=$xx1 c='if(${RCGA}>=80,${RCGA}-90,${RCGA})' a=RCGAf o=$xxx0
#mcal i=$xx1 c='if(${RCGA}>160,${RCGA}-180,if(${RCGA}>70,${RCGA}-90,if(${RCGA}<-160,${RCGA}+180,if(${RCGA}<-70,${RCGA}+90,${RCGA}))))' a=RCGAf |
#mcal          c='if(${MNTCA}>160,${MNTCA}-180,if(${MNTCA}>70,${MNTCA}-90,if(${MNTCA}<-160,${MNTCA}+180,if(${MNTCA}<-70,${MNTCA}+90,${MNTCA}))))' a=MNTCAf o=$xx2
xx2=$xx1

# RCG,TCについて絶対値を取る
if [ "$zettaichi" = "abs" ]; then
    columnsTarget=$columnsTarget
    columnsTargetCut=RCGA,MNTCA    # 距離計算時に無意味になるのでこれ以外は停止
    for column in ${columnsTargetCut//,/ }; do
      columnNames=${columnNames},${column}_:${column}
    done
    columnNames=${columnNames:1}
    echo $columnNames
#    mcal    c='abs(${RCGX})' a=RCGX_ |
#    mcal    c='abs(${RCGY})' a=RCGY_ |
    mcal    c='abs(${RCGA})' a=RCGA_ i=$xx2 |
#    mcal    c='abs(${TCX})' a=TCX_ |
#    mcal    c='abs(${TCY})' a=TCY_ |
#    mcal    c='abs(${MNTCX})' a=MNTCX_ |
#    mcal    c='abs(${MNTCY})' a=MNTCY_ |
    mcal    c='abs(${MNTCA})' a=MNTCA_ |
#    mcal    c='abs(${TLX})' a=TLX_ |
#    mcal    c='abs(${TLY})' a=TLY_ |
    mcut -r f=${columnsTargetCut} |
    mfldname f=${columnNames} o=$xx3

else
  xx3=$xx2
fi

# -- 結局、PartsNameと、Errorの両方を引っ張る必要があるので、それを考慮して最構築必要
#   mpf_error にdatetime 入れて、ここでErrorRateを弾けるようにするか
#   ReelID2ErrorsでError計算して、ここで引くか
#     そもそもなんでmpf_error 作ったんだ？？ datetime のR/T間での変換だっけか？
#     そこを考えれば解は見えるかな
# PartsName ごとの集計
# 100で出力されたエラー率のファイルと結合する
# mc04を取り除く
# X,Yについて、√X^2+Y^2を計算する
outputTable=${oDir}/ReelID2PartsName.csv
outputError=${oDir}/ReelID2Errors.csv
mjoin -n i=$xx3 m=$outputError k=Node,ReelID,datetime f=PartsName, |
mavg  k=Node,PartsName f=$columnsTarget |
mcut   f=Node,PartsName,$columnsTarget |
#mselstr -r f=FAdd v=0 |
mselstr -r f=Node v=04 |
msortf f=Node,PartsName |
mcal c='sqrt(${RCGX}^2+${RCGY}^2)' a=RCGL |
mcal c='sqrt(${TCX}^2+${TCY}^2)' a=TCL |
mcal c='sqrt(${MNTCX}^2+${MNTCY}^2)' a=MNTCL |
mcal c='sqrt(${TLX}^2+${TLY}^2)' a=TLL o=$oDir/avg_PartsName_${zettaichi}.csv
exit
mnrjoin -n i=$xx3 m=$outputTable r=datetime R=datetime,datetime1 k=Node,ReelID f=PartsName |
mavg  k=Node,PartsName f=$columnsTarget |
mcut   f=Node,PartsName,$columnsTarget |
#mselstr -r f=FAdd v=0 |
mselstr -r f=Node v=04 |
msortf f=Node,PartsName |
mcal c='sqrt(${RCGX}^2+${RCGY}^2)' a=RCGL |
mcal c='sqrt(${TCX}^2+${TCY}^2)' a=TCL |
mcal c='sqrt(${MNTCX}^2+${MNTCY}^2)' a=MNTCL |
mcal c='sqrt(${TLX}^2+${TLY}^2)' a=TLL o=$oDir/avg_PartsName_${zettaichi}.csv


# ノズルごとの集計
#mavg   i=$xx0 k=Node,Head,NHAdd f=RCGX,RCGY,RCGA,TCX,TCY,MPosiRecX,MPosiRecY,MPosiRecA,MPosiRecZ,MNTCX,MNTCY,MNTCA,TLX,TLY |
#mcut   f=Node,Head,NHAdd,RCGX,RCGY,RCGA,TCX,TCY,MPosiRecX,MPosiRecY,MPosiRecA,MPosiRecZ,MNTCX,MNTCY,MNTCA,TLX,TLY |
#msortf f=Node,Head,NHAdd%n o=$oDir/rcgtc_nozzle.csv

# フィーダ x ノズルで集計
#mavg   i=$xx0 k=Node,FAdd,FSAdd,Head,NHAdd f=RCGX,RCGY,RCGA,TCX,TCY,MPosiRecX,MPosiRecY,MPosiRecA,MPosiRecZ,MNTCX,MNTCY,MNTCA,TLX,TLY|
#mcut   f=Node,FAdd,FSAdd,Head,NHAdd,RCGX,RCGY,RCGA,TCX,TCY,MPosiRecX,MPosiRecY,MPosiRecA,MPosiRecZ,MNTCX,MNTCY,MNTCA,TLX,TLY |
#msortf f=Node,FAdd,FSAdd,Head,NHAdd%n o=$oDir/rcgtc_feeder_nozzle.csv





