# BiglyBT + Gluetun
### Headless Torrenting with Auto-Port Forwarding & Tmux

This setup runs BiglyBT locked behind a **Gluetun** VPN tunnel. A watcher script grabs the dynamic forwarded port and injects it directly into BiglyBT via tmux so your connection stays green automatically. Works with any VPN provider that Gluetun supports.

---

## The Goods
* **Hardened Privacy:** BiglyBT shares Gluetun's network stack. If the VPN drops, the internet dies (killswitch enabled).
* **Auto-Port Sync:** No more manual port updates. The watcher handles the VPN port handshake automatically.
* **Live Console:** Attach to the full BiglyBT CLI anytime with `./attach.sh`.
* **Headless & Light:** Runs Java 25 with no desktop, no GUI, no web UI — console only via tmux.
* **Debloated:** Unwanted built-in plugins are disabled on first boot.

---

## Structure
* **`config/`** — Persistent BiglyBT settings and plugins.
* **`downloads/`** — Your downloaded files (mapped to `/downloads` inside the container).
* **`forwarded-port/`** — Shared folder where Gluetun drops the current forwarded port.
* **`gluetun/`** — Gluetun persistent data.

---

## Quick Start

**1. Create your `.env` file**
```bash
cp .env.example .env
```
Then fill in your WireGuard details from your VPN provider. See the [Gluetun wiki](https://github.com/qdm12/gluetun-wiki) for provider-specific setup.

**2. Start it up**
```bash
chmod +x start.sh
./start.sh
```

**3. Attach to the console**
```bash
./attach.sh
```
Inside tmux, `Ctrl+B 0` is the BiglyBT console and `Ctrl+B 1` is the port watcher. Detach with `Ctrl+B D`.

---

## Scripts

| Script | What it does |
|---|---|
| `start.sh` | Pulls latest images and starts the containers |
| `remake.sh` | Full wipe and rebuild — prompts to preserve WireGuard credentials |
| `attach.sh` | Attaches to the BiglyBT tmux session |
| `shutdown.sh` | Stops the containers |
