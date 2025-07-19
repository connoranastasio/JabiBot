#!/bin/bash

ENV_PATH=".env"
INSTALLER_DIR="./web-installer"
INSTALLER_PORT=3000

TOKENS=("DISCORD_TOKEN" "YOUTUBE_API_KEY" "SPOTIFY_CLIENT_ID" "SPOTIFY_CLIENT_SECRET")

# 1. Helper to check if required commands exist
check_command() {
  if ! command -v "$1" &> /dev/null; then
    echo "🔧 Installing $1..."
    sudo apt-get update && sudo apt-get install -y "$1"
  fi
}

# 2. Validate .env file
validate_env_file() {
  echo "🔍 Validating .env file..."

  if [ ! -f "$ENV_PATH" ]; then
    echo "⚠️  .env file not found."
    return 1
  fi

  missing=0
  malformed=0

  while IFS= read -r line; do
    key=$(echo "$line" | cut -d '=' -f1)
    val=$(echo "$line" | cut -d '=' -f2- | tr -d '"')
    case "$key" in
      DISCORD_TOKEN)
        [[ "$val" =~ ^[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+\.[A-Za-z0-9_\-]+$ ]] || malformed=$((malformed+1))
        ;;
      YOUTUBE_API_KEY)
        [[ "$val" =~ ^[A-Za-z0-9_-]{35,}$ ]] || malformed=$((malformed+1))
        ;;
      SPOTIFY_CLIENT_ID|SPOTIFY_CLIENT_SECRET)
        [[ "$val" =~ ^[A-Za-z0-9]{32,}$ ]] || malformed=$((malformed+1))
        ;;
      *)
        continue
        ;;
    esac
  done < "$ENV_PATH"

  if grep -q 'DISCORD_TOKEN=' "$ENV_PATH"; then
    echo "✅ .env file found."
  fi

  if [[ $malformed -gt 0 ]]; then
    echo "❌ One or more tokens appear malformed."
    return 1
  fi

  return 0
}

# 3. Check if port is free
check_and_free_port() {
  if lsof -i tcp:"$INSTALLER_PORT" > /dev/null; then
    echo "⚠️  Port $INSTALLER_PORT is already in use."
    read -p "👉 Do you want to free it for the installer? (y/n): " choice
    if [[ "$choice" =~ ^[Yy]$ ]]; then
      pid=$(lsof -ti tcp:"$INSTALLER_PORT")
      sudo kill -9 "$pid"
      echo "✅ Freed up port $INSTALLER_PORT."
    else
      echo "❌ Installer cannot continue while port 3000 is in use. Exiting."
      exit 1
    fi
  fi
}

# 4. Launch the web installer
launch_web_installer() {
  echo "🚀 Launching web installer on port $INSTALLER_PORT..."
  check_and_free_port
  node "$INSTALLER_DIR/server.js" &

  sleep 2
  if curl -s "http://localhost:$INSTALLER_PORT/get-ip" | grep -q 'ip'; then
    echo "✅ Installer is running. Open it in your browser!"
  else
    echo "❌ Installer failed to start or is not reachable. Check your firewall or config."
    exit 1
  fi
}

# 5. Install required dependencies
install_dependencies() {
  echo "🧰 Checking required dependencies..."
  check_command node
  check_command npm
  check_command docker
  check_command docker-compose
}

# 6. Build and start JabiBot via Docker
start_docker_bot() {
  echo "🐳 Starting JabiBot using Docker..."
  docker-compose up -d

  if [ $? -eq 0 ]; then
    echo "✅ JabiBot is running!"
  else
    echo "❌ Docker failed to launch JabiBot. Check your docker-compose file and logs."
    exit 1
  fi
}

# ------------------------
# 🏁 Begin Installer Flow
# ------------------------

echo "📦 JabiBot v1.1.0 Installer Starting..."

install_dependencies

if ! validate_env_file; then
  echo ""
  echo "⚙️  API tokens are missing or invalid."
  read -p "👉 Do you want to launch the web installer to fix this? (y/n): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    launch_web_installer
    exit 0
  else
    echo "❌ Installation aborted by user."
    exit 1
  fi
else
  echo "✅ All tokens look valid."
  read -p "🔁 Do you want to re-run the installer anyway? (y/n): " choice
  if [[ "$choice" =~ ^[Yy]$ ]]; then
    launch_web_installer
    exit 0
  fi
fi

start_docker_bot

echo ""
echo "🎉 All done! You can now use JabiBot on your network."
