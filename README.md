# BiglyBT + ProtonVPN (via Gluetun)
### Headless Torrenting with Auto-Port Forwarding & Tmux

This setup runs BiglyBT locked behind a **Gluetun** VPN tunnel. It uses a custom "Watcher" script to grab the dynamic port from ProtonVPN and inject it directly into BiglyBT via `tmux` so your connection stays "Green" automatically.

---

## 🚀 The Goods
* **Hardened Privacy:** BiglyBT shares Gluetun's network stack. If the VPN drops, the internet dies. (Killswitch enabled).
* **Auto-Port Sync:** No more manual port updates. The watcher script handles the ProtonVPN handshake for you.
* **Live Console:** Access the full BiglyBT CLI anytime using `tmux attach`.
* **Headless & Light:** Java 25 optimized for low overhead.

---

## 📁 Structure
* **`config/`**: Persistent settings and plugins.
* **`downloads/`**: Your actual files (mapped to `/downloads`).
* **`forwarded-port/`**: The bridge folder where Gluetun drops port info.

---

## ⚙️ Quick Start

**1. Update VPN Credentials**
Edit `docker-compose.yml` and add your ProtonVPN WireGuard details:
* `WIREGUARD_PRIVATE_KEY`
* `WIREGUARD_ADDRESSES`
* `SERVER_HOSTNAMES`

**2. Fire it up**
```bash
chmod +x start.sh
./start.sh
