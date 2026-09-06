# Ubuntu 22.04 in Termux - Quick Start Guide

## Installation

### Step 1: Copy the script to your phone
Transfer `termux-ubuntu-installer.sh` to your Termux home directory or download it in Termux.

### Step 2: Run the installer
```bash
cd ~
bash termux-ubuntu-installer.sh
```

The script will:
- ✓ Check your device and available space
- ✓ Download Ubuntu 22.04 rootfs (~500MB)
- ✓ Extract it (takes 2-5 minutes)
- ✓ Set up launcher scripts
- ✓ Check kernel compatibility
- ✓ Verify the installation

**Total time: 10-20 minutes** (depending on internet speed)

### Step 3: Launch Ubuntu
Once installation finishes, start Ubuntu with:
```bash
~/startubuntu.sh
```

You'll see a root prompt like:
```
root@localhost:~#
```

Congratulations! You're now in Ubuntu. 🎉

---

## First Time in Ubuntu

### Update packages
```bash
apt update && apt upgrade -y
```

### Install useful tools
```bash
# Development essentials
apt install build-essential git python3 python3-pip -y

# Text editors
apt install nano vim -y

# Network tools
apt install curl wget net-tools -y
```

### Create a regular user (recommended)
```bash
adduser ubuntu
# Follow the prompts, then exit and re-login
```

---

## Common Tasks

### Exit Ubuntu and return to Termux
```bash
exit
```

### Access files from both Termux and Ubuntu
Your home directory is at `/root` in Ubuntu. You can navigate to Android storage:
```bash
# View Termux files from Ubuntu
ls /root

# Files persist - changes in Ubuntu are saved
```

### Run a command in Ubuntu from Termux
```bash
~/startubuntu.sh -c "command here"
```

### Check Ubuntu installation size
```bash
du -sh ~/ubuntu-fs
```

---

## Troubleshooting

### Problem: "Kernel too old" error

**Solution:**
1. Open `~/startubuntu.sh` with a text editor
2. Find this line (around line 18):
   ```bash
   # PROOT_ARGS="-k 4.14.81"
   ```
3. Remove the `#` at the start:
   ```bash
   PROOT_ARGS="-k 4.14.81"
   ```
4. Save and try running Ubuntu again

**Why:** Very old Android devices have older kernels. This tells proot to emulate a newer kernel interface.

### Problem: "No space left on device"

**Solution:**
- Ubuntu needs at least 3GB free space
- Check available space: `df -h`
- Clean up: `rm -rf ~/ubuntu-fs` and reinstall

### Problem: Slow performance

**This is normal!** PRoot adds overhead because it:
- Intercepts system calls
- Translates between file systems
- Emulates a Linux environment on Android

**Tips:**
- Close other apps running in the background
- Don't run heavy processes simultaneously

### Problem: "proot: command not found"

**Solution:**
```bash
apt update
apt install proot -y
```

### Problem: Network not working in Ubuntu

Ubuntu can access the internet through Termux's network connection.

**Check if connected:**
```bash
ping -c 1 google.com
```

If it fails:
1. Exit Ubuntu and Termux
2. Check your Android device's internet connection
3. Return to Termux and try again

---

## Advanced Usage

### Mount additional directories
Edit `~/startubuntu.sh` and add bind mounts. For example, to access Termux packages:

```bash
proot -r "$UBUNTU_FS" \
    -b /dev \
    -b /sys \
    -b /proc \
    -b /data/data/com.termux/files/usr:/host_termux \  # Add this
    -w /root \
    /bin/bash --login
```

Then inside Ubuntu:
```bash
ls /host_termux  # Access Termux packages
```

### Run GUI applications (requires additional setup)
This requires X11 forwarding. It's complex but possible. Search "Termux X11" for guides.

### Use Ubuntu with SSH

1. Inside Ubuntu, install OpenSSH:
   ```bash
   apt install openssh-server -y
   ```

2. Start the SSH server:
   ```bash
   service ssh start
   ```

3. From another device, SSH into your phone:
   ```bash
   ssh root@your-phone-ip -p 2222
   ```

---

## Uninstalling Ubuntu

To free up space and remove Ubuntu completely:

```bash
bash ~/uninstall-ubuntu.sh
```

**Warning:** This deletes everything in `~/ubuntu-fs`. Make sure you've backed up any important files first!

---

## Important Limitations

⚠️ **Things that won't work in Ubuntu on Termux:**

- **Systemd/Systemctl**: Services don't auto-start
  - Solution: Start services manually (e.g., `service nginx start`)
  
- **Docker/Container tools**: Requires kernel features Ubuntu can't access
  - Alternative: Use chroot or proot directly

- **Kernel updates**: You can't update the kernel, Android controls it
  - The kernel is shared with Android

- **Some device drivers**: Hardware access is limited
  - USB, GPU, etc. may not be fully accessible

- **Cron/scheduled tasks**: Background tasks are limited by Android
  - Solution: Use Termux's `at` command or set alarms manually

---

## Resources

- **Termux Wiki - PRoot**: https://wiki.termux.com/wiki/PRoot
- **PRoot Documentation**: https://proot-me.github.io/
- **Ubuntu Base**: https://wiki.ubuntu.com/Base
- **Termux GitHub**: https://github.com/termux

---

## Tips & Tricks

✅ **Pro tips:**

1. **Speed up repeated starts**: Keep your terminal open between Ubuntu sessions
2. **Save bandwidth**: Run `apt autoremove` to clean up old package files
3. **Free disk space**: Use `apt autoclean && apt autoremove`
4. **Check system info**: Inside Ubuntu, run `cat /proc/version` to see kernel details
5. **Backup your setup**: Compress `~/ubuntu-fs` to save your customized environment

---

**Questions?** Check the Termux community or search "proot ubuntu" for additional guides!

Happy hacking! 🐧
