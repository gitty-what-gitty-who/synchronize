# SYNCRONIZE.bat


## Description

This Windows batch script uses Robocopy to synchronize the contents of the Windows user’s personal folders with a connected USB drive. <br/>
It performs a one-way synchronization operation, not a backup. <br/> 


## Operation overview

1. On the first execution, the script saves the current username and hostname to the USB drive. <br/>
On subsequent runs, it verifies that the current user and host match the stored values. <br/>
if the verification fails, the script will display an error message and halt execution. <br/>
Protecting current user data from deletion.

2. Before synchronization, the script checks the available storage space on the USB drive. <br/>
The process will only proceed if sufficient free space is available to accommodate new or updated data otherwise <br/>
the script will display an error message and halt execution.

3. The script synchronizes the contents of the user’s Documents, Pictures, Videos, and Music folders <br/>
to corresponding created folders on the USB drive. <br/>
Additions, modifications, and deletions are replicated to maintain an exact copy of the local windows folders.
  

## Folder Structure on the USB Drive

On the connected USB drive, the script automatically creates a parent folder named SYNCHRONIZE within this parent folder, <br/> the following subfolders are created:
- Data – Contains the synchronized user data.
- Logs – Stores log files generated during the synchronization process.
- User (hidden) – Stores the username for validation.
- PC (hidden) – Stores the hostname for validation. <br/>

These folders are automatically created and maintained by the script to support synchronization, logging, and system validation.


## Usage Instructions

Place the batch script in the root folder of the USB drive and execute it.


## Important Notes

This script is designed for data mirroring, not for backups.

> [!Warning]
>	Deleted files on the local system will also be deleted from the USB drive upon synchronization.







