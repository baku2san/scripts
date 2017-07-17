#!/bin/sh

#export KG_iSize=40960000	#default 4096000 KG_iSize=KG_MaxRecLen*i(i>=2) 
#export KG_oSize=20480000 	#default 2048000 KG_oSize=KG_MaxRecLen*i(i>=2)
#export KG_MaxRecLen=10240000

# ProductReport/MountPickupFeeder を用いて
# フィーダごとの失敗率(Mount/Pickup)を求める
# 2017.5.29 maegawa@KSK

# Pickup  吸着試行回数
# Mount   装着回数
# 
# PMiss   吸着ミス回数
# RMiss   認識ミス
# DMiss   落下ミス
# MMiss   装着ミス
# HMiss   厚みミス
# TRSMiss 転写ユニット部品落下ミス

# 入力ディレクトリ/ファイル
iDir=../../../data/maihime/ProductReport
iDir=../Cut/ProductReport
iFile=$iDir/MountPickupFeeder.csv

# 出力ディレクトリ
oDir=out/100_countMountPickupFeeder
mkdir -p $oDir

# File 列(例)
# 20161107100124794_004_6_1_1~20161107100124282-04-1-1-759218-41611074000020-3.u01

# File 列から機械番号(Node)、時刻、基板シリアル、基板IDを取得
mcal i=$iFile c='mid($s{File},28,17)' a=datetime |
mcut f=No.:no,Node,datetime,FAdd,FSAdd,Pickup,PMiss,ReelID,RMiss,DMiss,Mount |
msortf f=Node,FAdd,FSAdd,ReelID,datetime |
mcal c='${Node}!=#{Node}||${FAdd}!=#{FAdd}||${FSAdd}!=#{FSAdd}||$s{ReelID}!=#s{ReelID}' a=edge |
mslide -q f=edge |
msel c='${edge1}==1' |
mcut -r f=edge,edge1 o=xx2
exit

# ReelID連携
input=xxout_mpf_joined_inc

# フィーダごとに Pickup, PMiss, Mount の合計を求め、吸着エラー率も求める
msum    i=$input k=Node,FAdd,FSAdd f=pickup_inc,pmiss_inc,mount_inc |
mcut    f=Node,FAdd,FSAdd,pickup_inc,pmiss_inc,mount_inc |
mcal    c='${pmiss_inc}/${pickup_inc}' a=errorRate o=$oDir/mpf_error_by_feeder.csv

input=../../jmt_ohshima/workM/out0707/tables/xxout_mpf_joined_inc_withPartsName.csv
output=$oDir/mpf_error_by_PartsName.csv

# PartsName ごとに Pickup, PMiss, Mount の合計を求め、吸着エラー率も求める
#msum    i=$input k=Node,PartsName f=pickup_inc,pmiss_inc,mount_inc |
#mcut    f=Node,PartsName,pickup_inc,pmiss_inc,mount_inc |
#mcal    c='${pmiss_inc}/${pickup_inc}' a=errorRate|
#msortf f=errorRate%nr o=$output

outpuTemp=`mktemp`
#msel i=$output c='$s{PartsName}!=""' o=$outputTemp
#../../../../scripts/kttest -i $outputTemp -o out/resultOfKttest.csv -m


