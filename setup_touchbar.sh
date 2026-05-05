#!/bin/bash
# Comprehensive tiny-dfr Installer for Asahi Linux (Ubuntu/Debian)
set -e

echo "1. Installing Graphics & Input Libraries..."
sudo apt update
sudo apt install git curl pkg-config libinput-dev libxml2-dev \
libfontconfig1-dev libgdk-pixbuf-2.0-dev libcairo2-dev \
libpango1.0-dev librsvg2-dev libudev-dev -y

echo "2. Installing Official Rust (Required for Edition 2024)..."
# The -s -- -y flag automates the 'Press 1' part of the installer
curl --proto '=https' --tlsv1.2 -sSf https://rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"

echo "3. Cloning and Building tiny-dfr..."
if [ -d "tiny-dfr" ]; then rm -rf tiny-dfr; fi
git clone https://github.com
cd tiny-dfr
cargo build --release
sudo cp target/release/tiny-dfr /usr/bin/

echo "4. Installing Configuration and udev Rules..."
sudo mkdir -p /etc/tiny-dfr
sudo cp share/tiny-dfr/config.toml /etc/tiny-dfr/
sudo cp etc/udev/rules.d/60-tiny-dfr.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules && sudo udevadm trigger

echo "5. Creating the Service File..."
sudo bash -c 'cat <<EOF > /etc/systemd/system/tiny-dfr.service
[Unit]
Description=Tiny Apple Silicon Touch Bar daemon
After=dbus.service

[Service]
ExecStart=/usr/bin/tiny-dfr
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

echo "6. Starting Touch Bar Service..."
sudo systemctl daemon-reload
sudo systemctl enable --now tiny-dfr

echo "------------------------------------------------"
echo "DONE! Your Touch Bar should now be active."
echo "Hold 'Fn' to swap between F-keys and Media keys."
echo "------------------------------------------------"
