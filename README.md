# 🔄 SYNCRONIZE.bat

![Platform](https://img.shields.io/badge/platform-Windows-blue)
![Language](https://img.shields.io/badge/language-Batch%20Script-lightgrey)
![Status](https://img.shields.io/badge/status-Stable-success)


---

## 📄 Description

`SYNCRONIZE.bat` is a Windows batch script that enables users to quickly and efficiently **mirror their personal directories** onto a USB drive.  
It performs a **one-way synchronization** from the local PC to the USB drive, meaning:

- 🟢 New and updated files on the PC are copied to the USB drive.  
- 🔴 Files deleted from the PC are also removed from the USB drive.  

> **Note:** This process is intended for **data mirroring**, not for backup purposes.  
> It ensures that the USB directories remain identical to the user’s Windows personal folders.

---

## ⚙️ Operation Overview

### 1. User and Host Verification
- On the first execution, the script records the current **username** and **hostname** to the USB drive.  
- On subsequent runs, it verifies that the current user and host match the stored values.  
- If the verification fails, the script halts execution and displays an error message to prevent accidental data deletion or unauthorized synchronization.

### 2. Storage Space Validation
- Before synchronization, the script checks the available storage space on the USB drive.  
- Synchronization proceeds only if there is sufficient free space to accommodate all new or modified data.  
- If space is insufficient, the script stops and notifies the user.

### 3. Synchronization Process
- The script mirrors the contents of the user’s **Documents**, **Pictures**, **Videos**, and **Music** directories to corresponding directories on the USB drive.  
- Additions, modifications, and deletions are replicated to maintain an exact mirror of the local Windows directories.

---

## 💾 Directory Structure on the USB Drive

The script automatically creates a parent directory named after the script itself.  
Within that parent directory, the following subdirectories are generated:

| Directory | Description |
|------------|-------------|
| **Data** | Contains the synchronized user data. |
| **Logs** | Stores log files generated during synchronization. |
| **User** *(hidden)* | Stores the username for validation. |
| **PC** *(hidden)* | Stores the hostname for validation. |

---

## 👥 Multi-User Synchronization on a Shared USB Drive

To synchronize multiple users on the same USB drive:

1. Copy and rename the batch script for each user (e.g., `John_SYNC.bat`, `Alice_SYNC.bat`).  
2. Each renamed script automatically creates a **unique parent directory** named after the script.  
3. Each user’s data is stored in an isolated directory, preventing conflicts and maintaining a clear, organized workspace.

---

## 🧭 Usage Instructions

1. Place the `SYNCRONIZE.bat` file in the **root directory** of the USB drive.  
2. Execute the script by double-clicking it or running it from the Command Prompt.

---

## 🧩 Important Notes

- The initial synchronization performs a **full data transfer** and may take some time.  
- Subsequent synchronizations are faster because only **changed or updated files** are processed.  
- The script is designed for **mirroring**, not versioned backups.

---

## ⚠️ Warning

> **Deleted files on the local system will also be deleted from the USB drive during synchronization.**  
> Ensure that you intend to maintain a mirrored copy, not a backup archive.

---

## 🛠️ Example Directory Layout
```
USB_DRIVE_ROOT/
└── SYNCRONIZE/          📁 Created automatically by the script
    ├── Data/            🗄️ Mirrored user files (Documents, Pictures, Videos, Music)
    ├── Logs/            📄 Synchronization logs
    ├── User/            🔒 Hidden, stores username for validation
    └── PC/              🔒 Hidden, stores hostname for validation
```
---

## 🧑‍💻 Version Information
- **Script Name:** `SYNCRONIZE.bat`  
- **Compatibility:** Windows 10 and later  
- **Operation Mode:** One-way file mirroring (PC → USB)

---

*Created for users who need a fast, reliable way to mirror Windows personal folders to external drives.*














