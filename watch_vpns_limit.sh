#!/bin/bash

RATE=${1:-50mbit}
LIMITED_FILE="/tmp/vpns_limited_list"
IFB_DEV="ifb0"

> $LIMITED_FILE

modprobe ifb 2>/dev/null
ip link set dev $IFB_DEV up 2>/dev/null

tc qdisc del dev $IFB_DEV root 2>/dev/null
tc qdisc add dev $IFB_DEV root handle 1: htb default 10
tc class add dev $IFB_DEV parent 1: classid 1:10 htb rate $RATE ceil $RATE

echo "🔍 正在持续监听 vpns+ 接口并自动限速为 $RATE..."

while true; do
    for IFACE in $(ip -o link show | awk -F': ' '{print $2}' | grep -E '^vpns[0-9]+$'); do
        if ! grep -q "$IFACE" "$LIMITED_FILE"; then
            echo "🆕 发现新接口 $IFACE，正在限速..."

            tc qdisc del dev $IFACE root 2>/dev/null
            tc qdisc add dev $IFACE root handle 1: htb default 10
            tc class add dev $IFACE parent 1: classid 1:10 htb rate $RATE ceil $RATE

            tc qdisc del dev $IFACE ingress 2>/dev/null
            tc qdisc add dev $IFACE ingress
            tc filter add dev $IFACE parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev $IFB_DEV

            echo "$IFACE" >> $LIMITED_FILE
        fi
    done
    sleep 1
done
