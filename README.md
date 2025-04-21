# 🔐 BitLocker Unlocker

**BitLocker Unlocker** is a simple graphical shell script designed to unlock and mount BitLocker-encrypted drives on Linux systems. It uses [Dislocker](https://github.com/Aorimn/dislocker) as a backend and provides a friendly GUI using [Zenity](https://help.gnome.org/users/zenity/).

Supports:
- ✅ Ubuntu / Debian / Linux Mint (.deb)
- ✅ Fedora / openSUSE / RHEL (.rpm)
- ⚠️ Alpine Linux (manual setup)
- ✅ Manual install via script

---

## 📸 Screenshots

> Coming soon!

---

## ✨ Features

- 🔍 Automatically lists available drives
- 🔑 Choose between password or recovery key
- 🖼️ Zenity-based GUI interface (with terminal fallback)
- 🔓 Mounts decrypted drive to `/media/mount`
- 🗂 Automatically creates required directories
- 🧼 Prompts to unmount and clean up
- 🪵 Logging to `~/unlock_bitlocker.log`

---

## 📦 Installation

### 🔧 Option 1: Prebuilt Packages

#### 📥 `.deb` (Ubuntu, Mint, Debian)
```bash
sudo dpkg -i bitlocker-unlocker_1.0_all.deb
```

#### 📥 `.rpm` (Fedora, openSUSE, RHEL)
```bash
sudo dnf install ./bitlocker-unlocker-1.0-1.noarch.rpm
```

> 🔧 Dependencies are installed automatically if using `dnf`. On Debian systems, you may need:
> ```bash
> sudo apt install dislocker zenity
> ```

---

### 🔧 Option 2: Manual Installation

```bash
# Download and install script manually
sudo cp unlock_bitlocker.sh /usr/local/bin/unlock-bitlocker
sudo chmod +x /usr/local/bin/unlock-bitlocker

# Optional desktop launcher
sudo cp unlock-bitlocker.desktop /usr/share/applications/
```

---

## 🚀 Usage

### 📂 From Terminal:
```bash
unlock-bitlocker
```

### 🖱️ From Desktop Menu:
Search for **"Unlock BitLocker Drive"** and click the launcher.

### 💬 Flow:
1. Select a BitLocker-encrypted partition
2. Choose to unlock via **Password** or **Recovery Key**
3. Enter credentials via GUI dialog
4. If successful, the decrypted drive is mounted to `/media/mount`

---

## 🧯 Unmounting

The script will ask if you want to unmount after you're done. If you need to unmount manually:

```bash
sudo umount /media/mount
sudo rm -rf /media/bitlocker /media/mount
```

---

## 🛠 Troubleshooting

- ❗ **No drives listed?** Make sure the drive is connected and not auto-mounted elsewhere.
- 🔐 **Wrong password/key?** You’ll be prompted again if unlocking fails.
- 🧰 **Missing dependencies?** Run:
  ```bash
  sudo apt install dislocker zenity    # Debian-based
  sudo dnf install dislocker zenity    # Fedora/openSUSE
  ```

---

## 🧪 Tested On

- ✅ Linux Mint 21.x
- ✅ Ubuntu 22.04+
- ✅ Fedora 39+
- ✅ openSUSE Tumbleweed
- ⚠️ Alpine Linux (requires building `dislocker` manually)

---

## 📤 Uninstall

### Debian/Ubuntu:
```bash
sudo apt remove bitlocker-unlocker
```

### Fedora/openSUSE:
```bash
sudo dnf remove bitlocker-unlocker
```

---

## 📁 Project Structure

```
bitlocker-unlocker/
├── src/
│   ├── unlock-bitlocker_gui.sh               # GUI Script
│   ├── unlock-bitlocker.sh                   # Manual Script
│   ├── unlock-bitlocker                      # Main script
│   └── unlock-bitlocker.desktop              # Launcher
├── deb Package/                              # .deb package build files
│   ├── DEBIAN
|   |   └── control
│   └── usr
|     |── local
│     |   └── bin
│     |       └── unlock-bitlocker
│     └── share
│         └── applications
│             └── unlock-bitlocker.desktop
├── rpm Package/                              # .rpm package build files
└── README.md
```

---

## 🙋 FAQ

**Q: Is this safe to use?**  
Yes — the script runs Dislocker with your credentials locally and doesn't send data anywhere.

**Q: Can I use this without GUI?**  
Yes — it falls back to terminal prompts if Zenity is unavailable.

**Q: Will it auto-mount on reboot?**  
No — this is an on-demand tool. Add it to `fstab` manually if needed.

---

## 🤝 Contributing

Pull requests are welcome! Especially for:

- 🌍 Language translations
- 🧪 Alpine support improvements
- 💡 UX improvements

---

## 🧾 License

MIT — free to use, share, and modify. Attribution appreciated!

---

## 💻 Author

Made with 💙 by [MSolimanTech](https://linktr.ee/msolimantech)