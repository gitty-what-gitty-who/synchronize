# 🔄 SYNCHRONIZE.ps1

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![Language](https://img.shields.io/badge/language-PowerShell-5391FE)
![Status](https://img.shields.io/badge/status-Stable-success)


---

## 📄 Description

`SYNCHRONIZE.ps1` is a powershell script that enables users to quickly and efficiently **mirror their personal directories** onto a USB drive.  
It performs a **one-way synchronization** from the local PC to the USB drive, meaning:

- 🟢 New and updated files on the PC are copied to the USB drive.  
- 🔴 Files deleted from the PC are also removed from the USB drive.  

> **Note:** This process is intended for **data mirroring**, not for backup purposes.  
> It ensures that the USB directories remain identical to the user’s Windows personal folders.

---

## ⚙️ Operation overview

### 1. Unique user directory
- Generates a unique user directory.
- It combines the username, computer name and a short SHA-1 hash of the user’s SID to ensure the directory name is unique.

### 2. Storage space validation
- Before synchronization, the script checks the available storage space on the USB drive.  
- Synchronization proceeds only if there is enough free space to accommodate all new or modified data.  
- If space is insufficient, the script stops and notifies the user.

### 3. Synchronization process
- Mirrors the contents of the user’s **Documents**, **Pictures**, **Videos** and **Music** directories to corresponding directories on the USB drive.  
- Additions, modifications and deletions are replicated to maintain an exact mirror of the local Windows directories.

---

## 🛠️ Example directory layout
```
USB_DRIVE_ROOT/
└── JDOE_WORKPC_5A8C2E/  🔄 Unique user directory 
    ├── Data/            ✅ Mirrored user files (Documents, Pictures, Videos, Music)
    └── Logs/            🧾 Synchronization logs
```
---

## 🧭 Usage instructions

1. Copy the **`SYNCHRONIZE.ps1`** file to the **root directory** of your USB drive.

2. Select the script **Right-click → Open with → Choose another app**.

3. **Select PowerShell** (or browse to `C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe`).

4. *(Optional)* Check **Always use this app**.

5. **Double-click** the script to run it. If blocked, open PowerShell as Administrator and allow scripts:

```powershell
Set-ExecutionPolicy RemoteSigned
```
Tip: Right-click the script → Run with PowerShell for a quick run.
   
---

## 🧩 Important notes

- The initial synchronization performs a **full data transfer** and may take some time.  
- Subsequent synchronizations are faster because only **changed or updated files** are processed.  
- The script is designed for **mirroring**, not backups.

---

## ⚠️ Warning

> **Deleted files on the local system will also be deleted from the USB drive during synchronization.**  

---

## 🧑‍💻 Version information
- **Script name:** `SYNCHRONIZE.ps1`  
- **Compatibility:** Windows 10 and later  
- **Operation mode:** One-way file mirroring (PC → USB)

---

*Created for users who need a fast, reliable way to mirror Windows personal folders to external drives.*














