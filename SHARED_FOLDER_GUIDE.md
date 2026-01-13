# Waydroid Shared Folder Setup Guide

Complete guide for sharing a folder between your Linux host and Waydroid Android container.

---

## 🎯 Goal

Share a host folder with Waydroid so files copied on Linux appear instantly inside Android.

**Host folder:** `~/waydroid-sharedFolder`  
**Android path:** `Internal storage/waydroid-sharedFolder`

---

## 📋 Quick Setup (Automated)

The installation script handles this automatically if you choose "Setup file sharing folder" during installation.

**Or run these manual steps:**

---

## 🛠️ Manual Setup Steps

### Step 1: Create the host folder

```bash
mkdir -p ~/waydroid-sharedFolder
```

This is where you'll place files on your Linux system.

---

### Step 2: Create the Waydroid mount point

Waydroid exposes Android "Internal storage" at:
```
~/.local/share/waydroid/data/media/0/
```

Create a folder there that will appear inside Android:

```bash
sudo mkdir -p ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder
```

---

### Step 3: Bind-mount the folders

Use a **bind mount** to make both paths point to the same files:

```bash
sudo mount --bind ~/waydroid-sharedFolder \
  ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder
```

---

### Step 4: Set permissions (optional)

Allow your user to access the folder without sudo:

```bash
sudo chmod o+rx ~/.local/share/waydroid/data/media/0
sudo chmod o+rx ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder
```

---

### Step 5: Verify the mount

Check as root (normal users won't have permission):

```bash
sudo ls ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder
```

---

### Step 6: Make it persistent (survive reboots)

Add to `/etc/fstab`:

```bash
echo "/home/$USER/waydroid-sharedFolder /home/$USER/.local/share/waydroid/data/media/0/waydroid-sharedFolder none bind 0 0" | sudo tee -a /etc/fstab
```

---

### Step 7: Restart Waydroid

Android needs a restart to see the new folder:

```bash
waydroid session stop
sleep 2
sudo waydroid container restart
sleep 3
waydroid session start
```

---

## 📱 Using the Shared Folder

### Inside Android (Waydroid)

1. Open **Files** app
2. Navigate to: **Internal storage**
3. You'll see: **waydroid-sharedFolder**
4. All files appear instantly!

### On Linux Host

Simply place files in:
```bash
~/waydroid-sharedFolder
```

They appear immediately in Android - no sync needed!

---

## 🔍 Permission Behavior (Important)

| Command | Result | Why |
|---------|--------|-----|
| `ls ~/waydroid-sharedFolder` | ✅ Works | Your folder, your permissions |
| `ls ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder` | ❌ Permission denied | Owned by Android (root/media_rw) |
| `sudo ls ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder` | ✅ Works | Root can access |
| Android Files app | ✅ Works | Android's media layer handles it |

**This is expected behavior!** Android apps access files via Android's media layer, not Linux permissions.

---

## 🗑️ Undo Everything

If you want to remove the shared folder:

```bash
# Unmount
sudo umount ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder

# Remove mount point
sudo rmdir ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder

# Remove from fstab (optional)
sudo sed -i '/waydroid-sharedFolder/d' /etc/fstab

# Optionally remove host folder
rm -rf ~/waydroid-sharedFolder
```

---

## 🐛 Troubleshooting

### Folder doesn't appear in Android

**Solution:** Restart Waydroid
```bash
waydroid session stop
sudo waydroid container restart
waydroid session start
```

### "Permission denied" when accessing on host

**This is normal!** Android owns the mount point. Use:
```bash
sudo ls ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder
```

Or add permissions:
```bash
sudo chmod o+rx ~/.local/share/waydroid/data/media/0
sudo chmod o+rx ~/.local/share/waydroid/data/media/0/waydroid-sharedFolder
```

### Mount doesn't survive reboot

**Check fstab:**
```bash
grep waydroid-sharedFolder /etc/fstab
```

Should show:
```
/home/username/waydroid-sharedFolder /home/username/.local/share/waydroid/data/media/0/waydroid-sharedFolder none bind 0 0
```

### Files not syncing

**Bind mounts are instant!** If files don't appear:
1. Verify mount: `mount | grep waydroid-sharedFolder`
2. Check host folder: `ls ~/waydroid-sharedFolder`
3. Restart Waydroid

---

## 💡 Key Takeaways

✅ Use `mount --bind` for folder sharing  
✅ Target directory must exist before mounting  
✅ "Permission denied" on host ≠ failure  
✅ Android access works regardless of Linux permissions  
✅ Files sync instantly (it's the same folder!)  
✅ Restart Waydroid to see new folders  

---

## 📚 Technical Details

### How it works

A **bind mount** makes two directory paths point to the same underlying filesystem location. Changes in one location appear instantly in the other because they're literally the same files.

### Mount command breakdown

```bash
sudo mount --bind <source> <target>
```

- **source:** Your Linux folder (`~/waydroid-sharedFolder`)
- **target:** Waydroid's internal storage path
- **--bind:** Creates a bind mount (directory to directory)
- **sudo:** Required because target is in Waydroid's protected space

### Why permissions are "denied"

The target path (`~/.local/share/waydroid/data/media/0/`) is owned by Android's user (`root` or `media_rw`). Your user doesn't have permission to access Android's internal directories directly.

However:
- Android apps can access it normally
- You can access via `sudo`
- The source folder (`~/waydroid-sharedFolder`) remains fully accessible

---

## 🔗 Related Documentation

- [Waydroid Official Docs](https://docs.waydro.id/)
- [Linux Bind Mounts](https://man7.org/linux/man-pages/man8/mount.8.html)
- [Main Installation Guide](README.md)
- [Changelog](CHANGELOG.md)

---

**Last Updated:** January 2026
