#!/bin/sh

# 舞姫データ TraceReport/MountQualityTrace (装着1部品ごとのレコード)
# を用いて、フィーダごとに エラー率,RCGX/Y/A,TCX/Y,MPosiRecX/Y/A/Z,MNTCX/Y/A,TLX/Yの値を平均する

# 平均する前に絶対値をとるか、とらないかを選択できる

# 2017.5.30 maegawa@KSK → 2017.6.1hatanaka@ksk 編集 

# 入力ディレクトリ/ファイル
iDir=data/stage2/TraceReport
iFile=$iDir/MountQualityTrace.csv

# 出力ディレクトリ
oDir=out/216_feeder_matrix_sd
mkdir -p $oDir

#RCG,TCの絶対値を先に計算するか(true/false)
zettaichi=false

# MountQualityTrace からフィーダアドレス、同サブアドレス、ノズルヘッドアドレスを取り出す
# ヘッド番号はデータにないので、フィーダアドレスの先頭 1 桁を流用する
mcal i=$iFile c='mid($s{File},46,2)' a=configuration |
mcal c='left($s{FAdd},1)' a=Head |
mcut f=configuration,FAdd,FSAdd,Head,NHAdd,RCGX,RCGY,RCGA,TCX,TCY,MPosiRecX,MPosiRecY,MPosiRecA,MPosiRecZ,MNTCX,MNTCY,MNTCA,TLX,TLY o=xxx0

# RCG,TCについて絶対値を取る
if [ "_"$zettaichi = "_true" ]; then
    mcal    c='abs(${RCGX})' a=RCGX_ i=xxx0 |
    mcal    c='abs(${RCGY})' a=RCGY_ |
    mcal    c='abs(${RCGA})' a=RCGA_ |
    mcal    c='abs(${TCX})' a=TCX_ |
    mcal    c='abs(${TCY})' a=TCY_ |
    mcal    c='abs(${MPosiRecX})' a=MPosiRecX_ |
    mcal    c='abs(${MPosiRecY})' a=MPosiRecY_ |
    mcal    c='abs(${MPosiRecA})' a=MPosiRecA_ |
    mcal    c='abs(${MPosiRecZ})' a=MPosiRecZ_ |
    mcal    c='abs(${MNTCX})' a=MNTCX_ |
    mcal    c='abs(${MNTCY})' a=MNTCY_ |
    mcal    c='abs(${MNTCA})' a=MNTCA_ |
    mcal    c='abs(${TLX})' a=TLX_ |
    mcal    c='abs(${TLY})' a=TLY_ o=xx0.csv
else
    mcut i=xxx0 f=configuration,FAdd,FSAdd,Head,NHAdd,RCGX:RCGX_,RCGY:RCGY_,RCGA:RCGA_,TCX:TCX_,TCY:TCY_,MPosiRecX:MPosiRecX_,MPosiRecY:MPosiRecY_,MPosiRecA:MPosiRecA_,MPosiRecZ:MPosiRecZ_,MNTCX:MNTCX_,MNTCY:MNTCY_,MNTCA:MNTCA_,TLX:TLX_,TLY:TLY_ o=xx0.csv
fi

# フィーダごとの集計
# mc04を取り除く
# 100で出力されたエラー率のファイルと結合する
# configuration列を取り除く
mstats  i=xx0.csv k=configuration,FAdd,FSAdd f=RCGX_,RCGY_,RCGA_,TCX_,TCY_,MPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MNTCX_,MNTCY_,MNTCA_,TLX_,TLY_ c=sd|
mcut   f=configuration,FAdd,FSAdd,RCGX_,RCGY_,RCGA_,TCX_,TCY_,MPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MNTCX_,MNTCY_,MNTCA_,TLX_,TLY_ |
mselstr -r f=FAdd v=0 |
mselstr -r f=configuration v=04 |
msortf f=configuration,FAdd,FSAdd |
mnjoin k=configuration,FAdd,FSAdd f=errorRate m=out/100_countMountPickupFeeder/mpf_error_by_feeder.csv o=x0.csv

# ノズルごとの集計
#mavg   i=xx0.csv k=configuration,Head,NHAdd f=RCGX_,RCGY_,RCGA_,TCX_,TCY_,MPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MNTCX_,MNTCY_,MNTCA_,TLX_,TLY_ |
#mcut   f=configuration,Head,NHAdd,RCGX_,RCGY_,RCGA_,TCX_,TCY_,MPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MNTCX_,MNTCY_,MNTCA_,TLX_,TLY_ |
#msortf f=configuration,Head,NHAdd%n o=$oDir/rcgtc_nozzle.csv

# フィーダ x ノズルで集計
#mavg   i=xx0.csv k=configuration,FAdd,FSAdd,Head,NHAdd f=RCGX_,RCGY_,RCGA_,TCX_,TCY_,MPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MNTCX_,MNTCY_,MNTCA_,TLX_,TLY_|
#mcut   f=configuration,FAdd,FSAdd,Head,NHAdd,RCGX_,RCGY_,RCGA_,TCX_,TCY_,MPosiRecX_,MPosiRecY_,MPosiRecA_,MPosiRecZ_,MNTCX_,MNTCY_,MNTCA_,TLX_,TLY_ |
#msortf f=configuration,FAdd,FSAdd,Head,NHAdd%n o=$oDir/rcgtc_feeder_nozzle.csv

# 210：プラス方向とマイナス方向のズレが相殺される
# 211：相殺されずに積算される、ズレの方向は不明

# X,Yについて、√X^2+Y^2を計算する
mcal i=x0.csv c='sqrt(${RCGX_}^2+${RCGY_}^2)' a=RCGL |
mcal c='sqrt(${TCX_}^2+${TCY_}^2)' a=TCL |
mcal c='sqrt(${MPosiRecX_}^2+${MPosiRecY_}^2)' a=MPosiRecL |
mcal c='sqrt(${MNTCX_}^2+${MNTCY_}^2)' a=MNTCL |
mcal c='sqrt(${TLX_}^2+${TLY_}^2)' a=TLL o=$oDir/rcgtc_feeder_woabs.csv