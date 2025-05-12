# ocserv VPN Bandwidth Limiter

This tool includes:

- `ocserv_speed_manager.sh`: Manual traffic control (set, clear, view)
- `watch_vpns_limit.sh`: Automatically apply speed limits to all active vpns+ interfaces

---

## 🔧 Setup

### 1. Grant execute permissions

```bash
chmod +x ocserv_speed_manager.sh watch_vpns_limit.sh
```

### 2. Start with supervisord (recommended)

Install supervisor:

```bash
apt install -y supervisor
```

Create config file:

```bash
nano /etc/supervisor/conf.d/watch_vpns_limit.conf
```

Paste:

```ini
[program:watch_vpns_limit]
command=/bin/bash /root/watch_vpns_limit.sh 50mbit
autostart=true
autorestart=true
startsecs=3
stderr_logfile=/var/log/vpns_limit.err.log
stdout_logfile=/var/log/vpns_limit.out.log
```

Then reload:

```bash
supervisorctl reread
supervisorctl update
supervisorctl start watch_vpns_limit
```

---

## ⚙ Manual Control (Optional)

```bash
./ocserv_speed_manager.sh
```

Options:

- Set global rate limit (e.g. 50mbit)
- Clear all tc rules
- View current tc status

---

## 📂 Files

- `ocserv_speed_manager.sh` – Manual speed limit control
- `watch_vpns_limit.sh` – Auto limit for new vpns+ interfaces
- `watch_vpns_limit.conf` – Optional supervisord config (create manually)

---

## 📌 Notes

- Reconnects are automatically re-limited
- Works independently of user IP or session
- Systemd not required

## 🧪 One-line full setup (with supervisor install)

```bash
apt install -y supervisor && \
mkdir -p /etc/supervisor/conf.d/ && \
wget -O /root/watch_vpns_limit.sh https://raw.githubusercontent.com/jackzhang-superman/limit_manager/main/watch_vpns_limit.sh && \
wget -O /root/ocserv_speed_manager.sh https://raw.githubusercontent.com/jackzhang-superman/limit_manager/main/ocserv_speed_manager.sh && \
chmod +x /root/watch_vpns_limit.sh /root/ocserv_speed_manager.sh && \
echo -e "[program:watch_vpns_limit]\\ncommand=/bin/bash /root/watch_vpns_limit.sh 50mbit\\nautostart=true\\nautorestart=true\\nstartsecs=3\\nstderr_logfile=/var/log/vpns_limit.err.log\\nstdout_logfile=/var/log/vpns_limit.out.log" > /etc/supervisor/conf.d/watch_vpns_limit.conf && \
supervisorctl reread && supervisorctl update && supervisorctl start watch_vpns_limit
```

