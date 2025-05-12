#!/bin/bash

# ========== 基础设置 ==========
IFB_DEV="ifb0"

function list_vpns_interfaces() {
    ip -o link show | awk -F': ' '{print $2}' | grep -E '^vpns[0-9]+$'
}

function setup_ifb() {
    modprobe ifb 2>/dev/null
    ip link set dev $IFB_DEV up 2>/dev/null
}

# ========== 设置限速 ==========
function set_speed_limit() {
    read -p "请输入限速值（例如 50mbit）: " RATE
    [ -z "$RATE" ] && echo "❌ 输入不能为空" && return

    setup_ifb
    echo "🔧 正在设置限速为 $RATE..."

    for IFACE in $(list_vpns_interfaces); do
        echo "➤ 配置接口 $IFACE"

        tc qdisc del dev $IFACE root 2>/dev/null
        tc qdisc del dev $IFACE ingress 2>/dev/null

        tc qdisc add dev $IFACE root handle 1: htb default 10
        tc class add dev $IFACE parent 1: classid 1:10 htb rate $RATE ceil $RATE

        tc qdisc add dev $IFACE ingress
        tc filter add dev $IFACE parent ffff: protocol ip u32 match u32 0 0 action mirred egress redirect dev $IFB_DEV
    done

    tc qdisc del dev $IFB_DEV root 2>/dev/null
    tc qdisc add dev $IFB_DEV root handle 1: htb default 10
    tc class add dev $IFB_DEV parent 1: classid 1:10 htb rate $RATE ceil $RATE

    echo "✅ 所有 VPN 用户限速为 $RATE 完成。"
}

function clear_speed_limit() {
    echo "🧹 正在清除限速规则..."
    for IFACE in $(list_vpns_interfaces); do
        echo "➤ 清除 $IFACE"
        tc qdisc del dev $IFACE root 2>/dev/null
        tc qdisc del dev $IFACE ingress 2>/dev/null
    done
    tc qdisc del dev $IFB_DEV root 2>/dev/null
    ip link set dev $IFB_DEV down 2>/dev/null
    echo "✅ 限速规则已清除。"
}

function show_status() {
    echo "📊 当前 tc 配置状态："
    for IFACE in $(list_vpns_interfaces); do
        echo "------ $IFACE ------"
        tc -s qdisc show dev $IFACE
    done
    echo "------ $IFB_DEV ------"
    tc -s qdisc show dev $IFB_DEV
}

function main_menu() {
    while true; do
        echo ""
        echo "========= ocserv VPN 用户限速管理 ========="
        echo "1. 设置限速"
        echo "2. 清除限速"
        echo "3. 查看限速状态"
        echo "0. 退出"
        echo "=========================================="
        read -p "请输入选项 [0-3]: " choice

        case "$choice" in
            1) set_speed_limit ;;
            2) clear_speed_limit ;;
            3) show_status ;;
            0) echo "退出"; exit 0 ;;
            *) echo "❌ 无效输入，请重新选择。" ;;
        esac
    done
}

main_menu
