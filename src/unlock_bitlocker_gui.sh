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

# Use GUI if Zenity available
use_gui=false
if command -v zenity &> /dev/null; then
    use_gui=true
fi

# Show input or prompt depending on GUI availability
prompt() {
    local message=$1
    if $use_gui; then
        zenity --entry --title="BitLocker Unlocker" --text="$message"
    else
        read -p "$message: " reply
        echo "$reply"
    fi
}

prompt_secret() {
    local message=$1
    if $use_gui; then
        zenity --password --title="BitLocker Unlocker"
    else
        read -s -p "$message: " reply
        echo
        echo "$reply"
    fi
}

# Confirmation box
confirm() {
    local message=$1
    if $use_gui; then
        zenity --question --title="BitLocker Unlocker" --text="$message"
        return $?
    else
        read -p "$message (y/n): " confirm
        [[ "$confirm" =~ ^[Yy]$ ]]
    fi
}

# Check sudo
if ! command -v sudo &> /dev/null; then
    log "❌ 'sudo' is required."
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
        log "❌ Dislocker not available in Alpine repos. Manual install required."
        exit 1
    elif command -v zypper &> /dev/null; then
        sudo zypper install -y dislocker
    else
        log "❌ Unsupported distro. Install Dislocker manually."
        exit 1
    fi
}

# Ensure dislocker
if ! command -v dislocker &> /dev/null; then
    install_dislocker
else
    log "✅ Dislocker is already installed."
fi

# Create directories
sudo mkdir -p /media/bitlocker
sudo mkdir -p /media/mount

# List drives
drive_list=$(lsblk -dpno NAME,SIZE | grep -v loop)
drive_choices=$(echo "$drive_list" | awk '{print NR") "$1" ("$2")"}')

if $use_gui; then
    selected_drive=$(zenity --list --title="Select BitLocker Drive" --column="Drives" $drive_choices)
    drive_path=$(echo "$selected_drive" | awk '{print $2}')
else
    echo "$drive_choices"
    choice=$(prompt "Enter number of the drive")
    drive_path=$(echo "$drive_list" | sed -n "${choice}p" | awk '{print $1}')
fi

if [ -z "$drive_path" ]; then
    log "❌ Invalid selection."
    exit 1
fi

# Unlock method
if $use_gui; then
    method=$(zenity --list --title="Unlock Method" --radiolist \
        --column "Select" --column "Method" TRUE "Password" FALSE "Recovery Key")
else
    echo "1) Password"
    echo "2) Recovery Key"
    method_choice=$(prompt "Choose unlock method (1/2)")
    method=$([[ "$method_choice" == "2" ]] && echo "Recovery Key" || echo "Password")
fi

# Unlock the drive
if [[ "$method" == "Password" ]]; then
    password=$(prompt_secret "Enter BitLocker password")
    log "🔓 Unlocking $drive_path with password..."
    sudo dislocker -v -V "$drive_path" -u"$password" -- /media/bitlocker
else
    recovery_key=$(prompt "Enter 48-digit recovery key (no dashes/spaces)")
    log "🔓 Unlocking $drive_path with recovery key..."
    sudo dislocker -v -V "$drive_path" --recovery-password="$recovery_key" -- /media/bitlocker
fi

# Check unlock success
if [ ! -e /media/bitlocker/dislocker-file ]; then
    log "❌ Unlock failed."
    $use_gui && zenity --error --text="Failed to unlock the drive." || echo "Failed to unlock the drive."
    exit 1
fi

# Mount decrypted volume
sudo mount -o loop,rw /media/bitlocker/dislocker-file /media/mount
if [ $? -eq 0 ]; then
    log "✅ Drive mounted at /media/mount"
    $use_gui && zenity --info --text="Drive successfully mounted at /media/mount"
else
    log "❌ Mount failed."
    $use_gui && zenity --error --text="Failed to mount the volume." || echo "Failed to mount."
    exit 1
fi

# Ask for cleanup after use
if confirm "Unmount and clean up when done?"; then
    $use_gui && zenity --info --text="Click OK when done using the mounted volume."
    read -p "Press ENTER to unmount..."  # Safe fallback
    sudo umount /media/mount
    sudo rm -rf /media/bitlocker/*
    log "✅ Unmounted and cleaned up."
    $use_gui && zenity --info --text="Volume unmounted and cleaned up."
else
    log "ℹ️ Please manually run: sudo umount /media/mount"
fi