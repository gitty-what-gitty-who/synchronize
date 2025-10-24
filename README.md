# SYNCRONIZE.BAT


## Description

This script synchronizes the contents of the Windows user’s personal folders with a connected USB drive. <br/>
It performs a one-way synchronization operation, not a backup. <br/> 
Any file deleted from your Windows folders will also be deleted from the USB drive during synchronization. <br/>
Use with caution!


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

4. Log files generated during the synchronization process will be stored on the connected USB drive.


## Usage Instructions

Place the batch script in the root directory of the USB drive and execute it.


## Important Notes

•	This script is designed for data mirroring, not for backups.

•	Deleted files on the local system will also be deleted from the USB drive upon synchronization.







