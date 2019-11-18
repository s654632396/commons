#!/bin/bash

arr=()
declare -A notify=()

readCronData() {
    file=./datas/cron_data
    ln=0
    while IFS= read -r line
    do
        # echo $ln
        tmp=$(echo "$line" | awk -F '|' '$1!="" {printf "%s",$1}')

        arr[$ln]=$tmp
        tmp="time${tmp/\:/}"
        if [ $tmp != "time" ];then
            notify["$tmp"]=$(echo "$line" | awk -F '|' '$2!="" {printf "%s",$2}')
        fi

        ln=$[ln+1]
    done < "$file"
}


check() {
    cur_h=$(date +%H)
    cur_m=$(date +%M)
    echo ${cur_h}:$cur_m

    for el in ${arr[@]};do
        h=${el%:*}
        m=${el##*:}

        if [[ $h = $cur_h && $m = $cur_m ]]; then
            if [[ ${notify["time$h$m"]} ]]; then
                msg=${notify["time$h$m"]}
            else
                msg="`date`"
            fi
            notify-send "${h}点${m}分啦" "$msg"
            sleep 30
        fi

    done
}

while :
do
    readCronData
    check
    sleep 10
done
