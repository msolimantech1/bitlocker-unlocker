#!/bin/bash

LOGFILE="/var/log/unlock_bitlocker.log"
USERLOG="$HOME/unlock_bitlocker.log"

# Logging
log() {
    local msg="[$(date '+%F %T')] $1"
    echo "$msg" | tee -a "$USERLOG"
    if [ "$(id -u)" -eq 0 ]; then
        echo "$msg" >> "$LOGFILE"
    fi
}

# Check sudo
if ! command -v sudo &> /dev/null; then
    log "❌ 'sudo' is required but not installed."
    exit 1
fi

# Install Dislocker
install_dislocker() {
    log "🔍 Installing Dislocker..."
    if command -v apt &> /dev/null; then
        sudo apt update && sudo apt install -y software-properties-common
        sudo add-apt-repository universe -y 2>/dev/null
        sudo apt install -y dislocker
    elif command -v dnf &> /dev/null; then
        sudo dnf install -y dislocker
    elif command -v pacman &> /dev/null; then
        sudo pacman -Sy --noconfirm dislocker
    elif command -v apk &> /dev/null; then
        log "❌ Alpine not supported natively. Manual Dislocker install needed."
        exit 1
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y dislocker
    else
        log "❌ Unsupported distro. Install Dislocker manually."
        exit 1
    fi
}

# Check dislocker
if ! command -v dislocker &> /dev/null; then
    install_dislocker
else
    log "✅ Dislocker already installed."
fi

# Mount points
sudo mkdir -p /media/bitlocker
sudo mkdir -p /media/mount

# Drive selection
echo "💽 Available drives:"
lsblk -dpno NAME,SIZE | grep -v "loop" | nl
echo
read -p "🔢 Enter the number of the drive to unlock: " drive_number
drive_path=$(lsblk -dpno NAME | grep -v "loop" | sed -n "${drive_number}p")

if [ -z "$drive_path" ]; then
    log "❌ Invalid drive selection."
    exit 1
fi

# Unlock choice
echo "🔐 Choose unlock method:"
select option in "Password" "Recovery Key"; do
    case $option in
        Password)
            read -s -p "Enter BitLocker password: " user_password
            echo
            log "🔓 Unlocking $drive_path using password..."
            sudo dislocker -v -V "$drive_path" -u"$user_password" -- /media/bitlocker
            ;;
        "Recovery Key")
            read -p "Enter BitLocker recovery key: " recovery_key
            log "🔓 Unlocking $drive_path using recovery key..."
            sudo dislocker -v -V "$drive_path" --recovery-password="$recovery_key" -- /media/bitlocker
            ;;
        *)
            log "❌ Invalid unlock option."
            exit 1
            ;;
    esac
    break
done

# Check unlock
if [ ! -e /media/bitlocker/dislocker-file ]; then
    log "❌ Unlock failed. Incorrect password or recovery key."
    exit 1
fi

# Mount decrypted drive
sudo mount -o loop,rw /media/bitlocker/dislocker-file /media/mount
if [ $? -eq 0 ]; then
    log "✅ Drive mounted successfully at /media/mount"
else
    log "❌ Mount failed."
    exit 1
fi

# Ask to clean up after
read -p "🚪 Do you want to unmount and clean up after you're done? (y/n): " cleanup_choice
if [[ "$cleanup_choice" =~ ^[Yy]$ ]]; then
    read -p "Press ENTER when you're done accessing the mounted volume to unmount..."
    sudo umount /media/mount
    sudo rm -rf /media/bitlocker/*
    log "✅ Volume unmounted and temporary files removed."
else
    log "ℹ️ Remember to run 'sudo umount /media/mount' and clean /media/bitlocker manually when finished."
fi