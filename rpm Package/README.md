## 🏗 Step-by-Step RPM Build Instructions

### 1. 🧱 Install RPM build tools

```bash
sudo dnf install rpm-build rpmdevtools -y
```

### 2. 📁 Set up build environment
```bash
rpmdev-setuptree
```
This creates:
```bash
~/rpmbuild/
├── BUILD
├── RPMS
├── SOURCES
├── SPECS
└── SRPMS
```
---
### 3. 🎯 Create the script and launcher files

Put the script (unlock-bitlocker) and desktop file in ~/rpmbuild/SOURCES/.

A. unlock-bitlocker script (same GUI script from before)

B. unlock-bitlocker.desktop

```ini
[Desktop Entry]
Name=Unlock BitLocker Drive
Comment=Unlock and mount BitLocker-encrypted drive
Exec=sudo /usr/local/bin/unlock-bitlocker
Icon=dialog-password
Terminal=false
Type=Application
Categories=Utility;
```
### 4. 📝 Write the .spec file: ~/rpmbuild/SPECS/bitlocker-unlocker.spec
```spec
Name:           bitlocker-unlocker
Version:        1.0
Release:        1%{?dist}
Summary:        GUI tool to unlock BitLocker-encrypted drives using Dislocker

License:        MIT
URL:            https://github.com/yourname/bitlocker-unlocker
Source0:        unlock-bitlocker
Source1:        unlock-bitlocker.desktop

Requires:       dislocker, zenity

BuildArch:      noarch

%description
This script provides a simple GUI-based utility for unlocking and mounting BitLocker-encrypted volumes using Dislocker and Zenity.

%prep

%build

%install
mkdir -p %{buildroot}/usr/local/bin
mkdir -p %{buildroot}/usr/share/applications

install -m 755 %{SOURCE0} %{buildroot}/usr/local/bin/unlock-bitlocker
install -m 644 %{SOURCE1} %{buildroot}/usr/share/applications/unlock-bitlocker.desktop

%files
/usr/local/bin/unlock-bitlocker
/usr/share/applications/unlock-bitlocker.desktop

%changelog
* Mon Apr 21 2025 You <you@example.com> - 1.0-1
- Initial release
```
---

### 5. 📦 Build the .rpm package
```bash
cd ~/rpmbuild/SPECS
rpmbuild -ba bitlocker-unlocker.spec
Output: ~/rpmbuild/RPMS/noarch/bitlocker-unlocker-1.0-1.noarch.rpm
```
