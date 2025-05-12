chmod +x ocserv_speed_manager.sh watch_vpns_limit.sh

# 将 systemd 服务文件移动到正确位置
mv vpns-limit.service /etc/systemd/system/

# 启用并启动自动限速服务
systemctl daemon-reexec
systemctl enable --now vpns-limit.service

# （可选）立即限速所有当前连接
./ocserv_speed_manager.sh
