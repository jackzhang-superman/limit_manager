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
