# JabiBot

JabiBot is a self-hosted Discord music bot forked from [Muse](https://github.com/museofficial/muse), redesigned to be easy to run on a Raspberry Pi — even for people who don’t code.

This project prioritizes:

- Ease of use for beginners  
- Raspberry Pi compatibility  
- Customization during install  
- Real data science integrations  

If you’ve never hosted a Discord bot before, JabiBot is a great place to start.

---

## Why JabiBot Is Worth Building

JabiBot makes sense for people who want control, privacy, and affordability:

### Cost Comparison: Raspberry Pi vs Cloud Hosting

| Platform             | Estimated Monthly Cost |
|----------------------|------------------------|
| AWS (t2.micro)       | $10–14                 |
| Google Cloud VM      | $7–12                  |
| DigitalOcean Droplet | $4–10                  |
| Raspberry Pi 4B      | ~$0.50–0.90 (energy)   |
| Raspberry Pi Zero 2W | ~$0.20–0.40            |

A Pi costs 5–10x less to run 24/7 than even the cheapest cloud hosts — and you own the hardware.

### Educational Value

- Learn Docker, Linux, SQLite, and the Discord API  
- Work with tokens, secrets, and secure environments  
- Apply data science skills to real bot behavior  
- Fully usable on a resume as a backend systems project  

### Platform Compatibility

Although JabiBot is designed with Raspberry Pi in mind, it runs on **any Linux-based device** that supports Docker, including:

- Desktop or laptop Linux machines  
- Linux VMs (e.g., on cloud providers)  
- ARM boards like Jetson Nano or Orange Pi  
- x86 servers or old computers repurposed for bot hosting

**NOTE**: We highlight the Pi because it's affordable, low-power, and an excellent tool for learning to code and work with real systems. However, it does come with limitations. Future features will be optimized for Raspberry Pi compatibility, but optional late-stage additions (like AI or real-time analytics) may require more powerful hardware. Where possible, lightweight alternatives will be explored.

JabiBot is built around:

- Simplicity and beginner access  
- Portability and Dockerized deployment  
- Modular, opt-in features  
- Customization based on available system resources  

---

## Features

### Core Functionality (inherited from Muse)

- Joins Discord voice channels  
- Plays music from YouTube and Spotify  
- Auto-ducks volume when people speak  
- Caches files for efficient replays  
- Dockerized and portable  

### Planned Features

- Bot usage dashboard (songs played, guilds, uptime, errors)  
- Plug-and-play feature modules during install  
- Queue + usage analytics (time-series, patterns, metadata)  
- Remote USB file server support  
- Web-based `.env` generator for easier onboarding  

---

## Recommended Hardware

- Raspberry Pi 4 Model B (4GB or 8GB)  
- 32GB+ A1-rated microSD card  
- Heatsinks, fan or case  
- Ethernet or Wi-Fi  
- Official Pi USB-C power adapter  

Optional:
- External USB hard drive for media cache or file sharing  
- USB microphone or sound card for future extensions  

---

## Installation

Install Docker + Docker Compose:

```bash
sudo apt update
sudo apt install docker.io docker-compose -y
sudo systemctl enable docker
```

Clone and run:

```bash
curl -O https://raw.githubusercontent.com/connoranastasio/JabiBot/main/install.sh
chmod +x install.sh
./install.sh
```

This will:

- Clone the latest repo  
- Create folders  
- Copy a template `.env`  
- Prompt for token entry  
- Launch the bot  

---

## Environment Configuration

Edit the `.env` file created during setup. These tokens are required:

| Key                  | Where to Get It |
|----------------------|-----------------|
| DISCORD_TOKEN        | [Discord Developer Portal](https://discord.com/developers/applications) |
| YOUTUBE_API_KEY      | [Google Cloud Console](https://console.cloud.google.com/) |
| SPOTIFY_CLIENT_ID    | [Spotify Developers](https://developer.spotify.com/dashboard/) |
| SPOTIFY_CLIENT_SECRET| [Spotify Developers](https://developer.spotify.com/dashboard/) |

Do not share this file or commit it to GitHub.

> A web-based `.env` generator is planned to help avoid editing on the Pi directly.

---

## Roadmap

- Optional install-time configuration  
- Analytics-ready database for queue + playback logs  
- Minimal web interface for admin/stats  
- SFTP or Samba server for media file access  
- Resume-focused modules to flex real backend skills  
- Experimental AI integration (likely not Pi-compatible)  

---

## Credit

JabiBot is a fork of [Muse Bot](https://github.com/museofficial/muse) — credit to them for the original music engine, cache logic, core functionality, and fantastic jumping-off point.

---

## License

MIT License. See `LICENSE`.
