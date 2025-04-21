## ✅ Build Instructions
---

```bash
# 1. Create structure
mkdir -p bitlocker-unlocker/usr/local/bin
mkdir -p bitlocker-unlocker/usr/share/applications
mkdir -p bitlocker-unlocker/DEBIAN

# 2. Copy script and control files
cp unlock_bitlocker_gui.sh bitlocker-unlocker/usr/local/bin/unlock-bitlocker
chmod +x bitlocker-unlocker/usr/local/bin/unlock-bitlocker

cat > bitlocker-unlocker/DEBIAN/control <<EOF
Package: bitlocker-unlocker
Version: 1.0
Section: utils
Priority: optional
Architecture: all
Depends: dislocker, zenity
Maintainer: You <you@example.com>
Description: GUI-based tool to unlock and mount BitLocker-encrypted drives using Dislocker.
EOF

# Optional: launcher
cat > bitlocker-unlocker/usr/share/applications/unlock-bitlocker.desktop <<EOF
[Desktop Entry]
Name=Unlock BitLocker Drive
Comment=Unlock and mount BitLocker-encrypted drive
Exec=sudo /usr/local/bin/unlock-bitlocker
Icon=dialog-password
Terminal=false
Type=Application
Categories=Utility;
EOF

# 3. Build the .deb
dpkg-deb --build bitlocker-unlocker
```