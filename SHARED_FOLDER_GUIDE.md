# Waydroid File Sharing Guide (Symlink Method)

> **Note:** I use the symlink method for instant transfer between Linux and Waydroid. You can follow this symlink method below or set up a normal shared folder guide by yourself.

---

## 🎯 What This Does

Creates symbolic links to access Waydroid folders directly from your Linux home directory for instant file transfer.

---

## 🛠️ Setup Steps

### Step 1: Navigate to Waydroid data folder

```bash
cd ~/.local/share/waydroid/data
```

### Step 2: Check media folder permissions

```bash
ls -ld media
```

This will show the folder's group (typically 1023).

### Step 3: Check your current groups

```bash
groups
```

### Step 4: Add yourself to the Waydroid media group

Replace `username` with your actual username:

```bash
sudo echo "waydroid:x:1023:username" >> /etc/group
```

### Step 5: Reboot your system

```bash
reboot
```

### Step 6: Verify group membership

After rebooting, check that you're now in the group:

```bash
groups
```

### Step 7: Create symbolic links

Create a symlink to Waydroid's Download folder (or any other folder):

```bash
ln --symbolic ~/.local/share/waydroid/data/media/0/Download ~/WaydroidDownload
```

You can create links to other folders as needed:

```bash
# For Pictures
ln --symbolic ~/.local/share/waydroid/data/media/0/Pictures ~/WaydroidPictures

# For Documents
ln --symbolic ~/.local/share/waydroid/data/media/0/Documents ~/WaydroidDocuments

# For DCIM (Camera)
ln --symbolic ~/.local/share/waydroid/data/media/0/DCIM ~/WaydroidDCIM
```

---

## ✅ Usage

Now anything you put in `~/WaydroidDownload` from Linux will be instantly visible in Waydroid's Download folder, and vice versa.

No mounting or restarting required - changes appear instantly!

---

## 📱 Accessing Files

### From Linux

Access Waydroid files through the symlinks in your home directory:

```bash
# List files in Waydroid's Download folder
ls ~/WaydroidDownload

# Copy a file to Waydroid
cp myfile.pdf ~/WaydroidDownload/

# Open Waydroid's Downloads in file manager
xdg-open ~/WaydroidDownload
```

### From Android (Waydroid)

1. Open any **File Manager** app
2. Navigate to **Download**, **Pictures**, **Documents**, etc.
3. Files placed via the symlinks will be instantly visible!

---

## 🗑️ Undo Everything

If you want to remove the symlinks:

```bash
# Remove symlinks
rm ~/WaydroidDownload
rm ~/WaydroidPictures
rm ~/WaydroidDocuments
rm ~/WaydroidDCIM

# Remove yourself from the waydroid group (optional)
sudo sed -i '/waydroid:x:1023/d' /etc/group
```

---

## 🐛 Troubleshooting

### "Permission denied" when accessing symlinks

**Solution:** Make sure you completed Steps 4-6 to add yourself to the waydroid group and rebooted.

Verify you're in the group:
```bash
groups | grep waydroid
```

### Symlink shows red or broken in file manager

**Solution:** Make sure Waydroid is initialized and the folders exist:
```bash
ls -la ~/.local/share/waydroid/data/media/0/
```

If the folders don't exist, start Waydroid first:
```bash
waydroid session start
```

### Files not appearing in Android

**Solution:** Wait a few seconds or restart the Android app. Android sometimes needs to rescan media files.

Open **Files** app in Android and pull down to refresh.

---

## 💡 Key Takeaways

✅ Symlinks provide direct access to Waydroid folders  
✅ No mounting or bind mounts required  
✅ Changes appear instantly (it's the same folder!)  
✅ Works with any folder in Waydroid's internal storage  
✅ Simple, reliable Unix/Linux feature since the 1980s  
✅ No need to restart Waydroid  

---

## 📚 Technical Details

### How it works

A **symbolic link** (symlink) is a special file that points to another file or directory. When you access the symlink, the operating system transparently redirects you to the target location.

### Symlink command breakdown

```bash
ln --symbolic <target> <link_name>
```

- **target:** The Waydroid folder (`~/.local/share/waydroid/data/media/0/Download`)
- **link_name:** The symlink location (`~/WaydroidDownload`)
- **--symbolic:** Creates a symbolic link (can span filesystems)

### Why add to group 1023?

Waydroid's media storage uses Android's permission system. The `media` folder is owned by group 1023 (Android's `media_rw` group). Adding yourself to this group grants read/write access to Waydroid's internal storage folders.

---

## 🔗 Reference

Based on: https://github.com/waydroid/waydroid/discussions/2150

### Alternative Method

If you prefer the traditional bind mount approach, you can set it up yourself following the official Waydroid documentation at: https://docs.waydro.id/faq/setting-up-a-shared-folder

---

## 📝 Notes

- Replace `username` in Step 4 with your actual Linux username
- You can name the symlinks whatever you want (e.g., `~/WaydroidDownload`, `~/AndroidFiles`, etc.)
- The symlink method is simpler than bind mounts - no fstab configuration needed!
- Changes are instant - no manual syncing or delays

---

**Last Updated:** January 2026
