#!/bin/sh

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
iDir=../../jmt_ohshima/Cut/ProductReport
iFile=$iDir/MountPickupFeeder.csv

# 出力ディレクトリ
oDir=out/100_countMountPickupFeeder
mkdir -p $oDir

# File 列(例)
# 20161107100124794_004_6_1_1~20161107100124282-04-1-1-759218-41611074000020-3.u01

# File 列から機械番号(configuration)、時刻、基板シリアル、基板IDを取得
#mcal i=$iFile c='mid($s{File},46,2)' a=configuration |
#mcal c='mid($s{File},28,17)' a=datetime |
#mcal c='mid($s{datetime},0,4)' a=year |
#mcal c='mid($s{datetime},4,2)' a=month |
#mcal c='mid($s{datetime},6,2)' a=day |
#mcal c='mid($s{datetime},8,2)' a=hour |
#mcal c='mid($s{datetime},10,2)' a=minute |
#mcal c='mid($s{File},53,6)'  a=boardSerial |
#mcal c='mid($s{File},60,14)' a=boardID |
#mcut f=File,No.:no,datetime,day,hour,minute,configuration,boardSerial,boardID,FAdd,FSAdd,Pickup,PMiss,ReelID,RMiss,DMiss,Mount |
#msortf f=configuration,FAdd,FSAdd,datetime o=xxout_mpf

# Index, Information からいくつかの列を結合
#mjoin  i=xxout_mpf m=$iDir/Index.csv       k=File f=Date |
#mjoin              m=$iDir/Information.csv k=File f=Serial,Code,ProductID,Rev,LotName,LotNumber o=xxout_mpf_joined

# configuration ごとに
# Pickup, PMiss, ..., Mount はその基板内ではなく累積、リセットタイミングがわからないので
# 前の行の Pickup との差分で基板ごとの Pickup 数(pickup_inc)を求める。
# Pickup の値が減っていればリセットされたと判断する。
#msortf  i=xxout_mpf_joined f=configuration,FAdd,FSAdd,datetime |
#mcal    c='if($s{configuration}==#s{configuration}&&$s{FAdd}==#s{FAdd}&&$s{FSAdd}==#s{FSAdd}&&${Pickup}>=#{Pickup},${Pickup}-#{Pickup},${Pickup})' a=pickup_inc |
#mcal    c='if($s{configuration}==#s{configuration}&&$s{FAdd}==#s{FAdd}&&$s{FSAdd}==#s{FSAdd}&&${Pickup}>=#{Pickup},${PMiss}-#{PMiss},${PMiss})' a=pmiss_inc |
#mcal    c='if($s{configuration}==#s{configuration}&&$s{FAdd}==#s{FAdd}&&$s{FSAdd}==#s{FSAdd}&&${Pickup}>=#{Pickup},${Mount}-#{Mount},${Mount})' a=mount_inc o=xxout_mpf_joined_inc
	
# ReelID連携
input=xxout_mpf_joined_inc

# フィーダごとに Pickup, PMiss, Mount の合計を求め、吸着エラー率も求める
#msum    i=$input k=configuration,FAdd,FSAdd f=pickup_inc,pmiss_inc,mount_inc |
#mcut    f=configuration,FAdd,FSAdd,pickup_inc,pmiss_inc,mount_inc |
#mcal    c='${pmiss_inc}/${pickup_inc}' a=errorRate o=$oDir/mpf_error_by_feeder.csv

input=../../jmt_ohshima/workM/out0707/tables/xxout_mpf_joined_inc_withPartsName.csv
output=$oDir/mpf_error_by_PartsName.csv

# PartsName ごとに Pickup, PMiss, Mount の合計を求め、吸着エラー率も求める
#msum    i=$input k=configuration,PartsName f=pickup_inc,pmiss_inc,mount_inc |
#mcut    f=configuration,PartsName,pickup_inc,pmiss_inc,mount_inc |
#mcal    c='${pmiss_inc}/${pickup_inc}' a=errorRate|
#msortf f=errorRate%nr o=$output

outpuTemp=`mktemp`
msel i=$output c='$s{PartsName}!=""' o=$outputTemp
../../../../scripts/kttest -i $outputTemp -o out/resultOfKttest.csv -m


