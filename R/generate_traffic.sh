#!/usr/bin/env bash

# Usage: generate_traffic.sh WEF TIL MODEL
# 
# generate one SO6 file per day with trajectories of MODEL type for the interval [WEF, TIL)
# filename is 'TRAFFIC_<MODEL>_<WEF in YYYYMMDD>.so6'
# Note: TIL is _not_ included
# WEF/TIL can be date only or include partial time, like
#   "2019-05-27"                      --> "2019-05-27T00:00:00Z"
#   "2019-05-27 10"                   --> "2019-05-27T10:00:00Z"
#   "2019-05-27T11:22:33Z"
#
# Examples:
# * generate daily traffic for CTFM on 2019-05-27
#     generate_traffic.sh "2019-05-27" "2019-06-03" EVENT

start=$1
end=$2
model=$3

start=$(date -d $start +%Y%m%d)
next=$(date -d"$start + 1 day" +"%Y%m%d")
end=$(date -d $end +%Y%m%d)

while [[ $start -lt $end ]]
do
    # do domething interesting with
    Rscript $(dirname $(dirname $(realpath $0)) )/R/export_trajectories_so6.R \
	    -o TRAFFIC_${model}_${start}.so6 \
	    -m ${model} \
	    \"$(date -d"$start" +"%Y-%m-%d")\" \"$(date -d"$next" +"%Y-%m-%d")\" \
	    -b 1 -a 1

    # increment by 1 day
    start=$next
    next=$(date -d"$start + 1 day" +"%Y%m%d")
done

