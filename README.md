# SYNCRONIZE.bat


## Description

This batch script allows Windows users to quickly and easily mirror their Windows personal directories  <br/> 
onto a USB drive. It performs a one-way synchronization from your PC to the USB drive, meaning:

- New and updated files on your PC will be copied to the USB.
- Files deleted from your PC will also be removed from the USB.

This is not a backup, but a fast way to keep your USB folders identical to your Windows personal folders. <br/>

## Operation overview

1. On the first execution, the script saves the current username and hostname to the USB drive. <br/>
On subsequent runs, it verifies that the current user and host match the stored values. <br/>
if the verification fails, the script will display an error message and halt execution protecting current user data from deletion.

2. Before synchronization, the script checks the available storage space on the USB drive. <br/>
The script will only proceed if sufficient free space is available to accommodate new or updated data <br/>
otherwise the script will display an error message and halt execution.

4. The script synchronizes the contents of the user’s Documents, Pictures, Videos, and Music directories <br/>
to corresponding created directories on the USB drive. <br/>
Additions, modifications, and deletions are replicated to maintain an exact copy of the local windows directories.

## Directory structure on the USB Drive

The script automatically creates a parent directory named after the script itself.  <br/>
Inside that parent directory, the following subdirectories are created:
- Data – Contains the synchronized user data.
- Logs – Stores log files generated during the synchronization process.
- User (hidden) – Stores the username for validation.
- PC (hidden) – Stores the hostname for validation. <br/>

## Multi-User synchronization on a shared USB Drive

If you want to synchronize multiple users on the same USB drive, simply copy the script, rename it, and run it.  <br/>
For example, use the user’s name as the script name.  <br/>
This way, each user automatically generates a unique parent directory, named after the script itself,  <br/> 
containing predefined subdirectories.  <br/>
This maintains a clear, isolated, and conflict-free workspace for every user.  <br/>

## Usage instructions

Place the batch script in the root directory of the USB drive and execute it.


## Important notes

- This script is designed for data mirroring, not for backups.  <br/>
- The first synchronization performs a full data transfer and may take some time. <br/>
  Later synchronizations are faster because only changed or updated files are synchronized.

> [!Warning]
>	Deleted files on the local system will also be deleted from the USB drive upon synchronization.







